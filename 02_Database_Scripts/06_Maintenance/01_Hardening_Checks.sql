/*
================================================================================
    01_Hardening_Checks.sql - فحوصات تأمين قاعدة البيانات
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF;

PROMPT ========================================
PROMPT فحوصات تأمين قاعدة البيانات
PROMPT ========================================

/*
================================================================================
    1. فحص الحسابات الافتراضية المفتوحة
================================================================================
*/

PROMPT [1] الحسابات الافتراضية:
SELECT USERNAME, ACCOUNT_STATUS, PROFILE
FROM DBA_USERS
WHERE USERNAME IN ('SCOTT','HR','OE','SH','PM','CTXSYS','MDSYS','ORDDATA')
AND ACCOUNT_STATUS != 'EXPIRED & LOCKED';

/*
================================================================================
    2. فحص صلاحيات خطيرة
================================================================================
*/

PROMPT [2] مستخدمون لديهم صلاحيات خطيرة:
SELECT GRANTEE, PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE PRIVILEGE IN ('ALTER SYSTEM','CREATE ANY PROCEDURE','DROP ANY TABLE','BECOME USER')
AND GRANTEE NOT IN ('SYS','SYSTEM','DBA')
ORDER BY GRANTEE;

/*
================================================================================
    3. فحص كلمات المرور الضعيفة
================================================================================
*/

PROMPT [3] حسابات بدون ملف تعريف آمن:
SELECT USERNAME, PROFILE, ACCOUNT_STATUS
FROM DBA_USERS
WHERE PROFILE = 'DEFAULT'
AND USERNAME NOT IN ('SYS','SYSTEM','DBSNMP','APPQOSSYS')
AND USERNAME NOT LIKE 'APEX%'
AND ACCOUNT_STATUS = 'OPEN';

/*
================================================================================
    4. فحص PUBLIC privileges
================================================================================
*/

PROMPT [4] صلاحيات خطيرة ممنوحة لـ PUBLIC:
SELECT PRIVILEGE, TABLE_NAME
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'PUBLIC'
AND PRIVILEGE IN ('EXECUTE','DELETE','UPDATE','INSERT')
AND OWNER NOT IN ('SYS','SYSTEM')
ORDER BY TABLE_NAME;

/*
================================================================================
    5. فحص Audit Trail
================================================================================
*/

PROMPT [5] حالة التدقيق:
SELECT PARAMETER_NAME, PARAMETER_VALUE
FROM V$OPTION
WHERE PARAMETER_NAME LIKE '%AUDIT%';

/*
================================================================================
    6. فحص معلمات الأمان
================================================================================
*/

PROMPT [6] معلمات الأمان:
SELECT NAME, VALUE
FROM V$PARAMETER
WHERE NAME IN (
    'audit_trail',
    'remote_login_passwordfile',
    'sec_case_sensitive_logon',
    'password_lock_time',
    'password_grace_time'
);

/*
================================================================================
    7. فحص Database Links
================================================================================
*/

PROMPT [7] روابط قواعد البيانات:
SELECT OWNER, DB_LINK, HOST
FROM DBA_DB_LINKS;

/*
================================================================================
    8. فحص Directories
================================================================================
*/

PROMPT [8] الدلائل المتاحة:
SELECT DIRECTORY_NAME, DIRECTORY_PATH
FROM DBA_DIRECTORIES;

/*
================================================================================
    9. ملخص التوصيات
================================================================================
*/

PROMPT ========================================
PROMPT ملخص التوصيات:
PROMPT ========================================
PROMPT 1. قفل الحسابات الافتراضية غير المستخدمة
PROMPT 2. مراجعة الصلاحيات الممنوحة لـ PUBLIC
PROMPT 3. تفعيل التدقيق الموحد
PROMPT 4. استخدام ملفات تعريف آمنة لجميع المستخدمين
PROMPT 5. إزالة Database Links غير الضرورية
PROMPT ========================================

PROMPT تم الانتهاء من فحوصات التأمين ✓
