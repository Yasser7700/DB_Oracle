/*
================================================================================
    03_Monitoring_Queries.sql - استعلامات المراقبة
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    User: SYS AS SYSDBA
    ملاحظة: يتم التنفيذ بواسطة SYS لتجاوز قيود منح الصلاحيات (ORA-01720)
    سيتم إنشاء الكائنات في مخطط SEC_ADMIN
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT ========================================
PROMPT استعلامات المراقبة الأمنية (بواسطة SYS)
PROMPT ========================================

/*
================================================================================
    1. مراقبة محاولات تسجيل الدخول الفاشلة
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_FAILED_LOGINS AS
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    OS_USERNAME,
    USERHOST,
    TERMINAL,
    AUTHENTICATION_TYPE,
    RETURN_CODE
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
WHERE ACTION_NAME = 'LOGON'
AND RETURN_CODE != 0
ORDER BY EVENT_TIMESTAMP DESC;

/*
================================================================================
    2. مراقبة الوصول للبيانات الحساسة
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_SENSITIVE_ACCESS AS
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    OBJECT_NAME,
    ACTION_NAME,
    SQL_TEXT,
    RETURN_CODE
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
AND OBJECT_NAME IN ('CUSTOMERS', 'PAYMENTS')
ORDER BY EVENT_TIMESTAMP DESC;

/*
================================================================================
    3. مراقبة التغييرات على المخطط
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_SCHEMA_CHANGES AS
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    ACTION_NAME,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    SQL_TEXT
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
WHERE ACTION_NAME IN ('CREATE', 'ALTER', 'DROP')
ORDER BY EVENT_TIMESTAMP DESC;

/*
================================================================================
    4. مراقبة النشاط غير المعتاد (بعد ساعات العمل)
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_AFTERHOURS_ACTIVITY AS
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    ACTION_NAME,
    OBJECT_NAME,
    SQL_TEXT
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
WHERE (TO_NUMBER(TO_CHAR(EVENT_TIMESTAMP, 'HH24')) < 8 
   OR TO_NUMBER(TO_CHAR(EVENT_TIMESTAMP, 'HH24')) >= 18)
AND ACTION_NAME NOT IN ('LOGON', 'LOGOFF')
ORDER BY EVENT_TIMESTAMP DESC;

/*
================================================================================
    5. ملخص نشاط المستخدمين
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_USER_ACTIVITY_SUMMARY AS
SELECT 
    DBUSERNAME,
    TRUNC(EVENT_TIMESTAMP) AS ACTIVITY_DATE,
    COUNT(*) AS TOTAL_ACTIONS,
    SUM(CASE WHEN ACTION_NAME = 'LOGON' THEN 1 ELSE 0 END) AS LOGINS,
    SUM(CASE WHEN ACTION_NAME = 'SELECT' THEN 1 ELSE 0 END) AS SELECTS,
    SUM(CASE WHEN ACTION_NAME IN ('INSERT','UPDATE','DELETE') THEN 1 ELSE 0 END) AS DML_OPERATIONS
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
GROUP BY DBUSERNAME, TRUNC(EVENT_TIMESTAMP)
ORDER BY ACTIVITY_DATE DESC, TOTAL_ACTIONS DESC;

/*
================================================================================
    6. مراقبة الاستعلامات البطيئة
================================================================================
*/

CREATE OR REPLACE VIEW SEC_ADMIN.V_SLOW_QUERIES AS
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    OBJECT_NAME,
    SQL_TEXT,
    EXECUTION_ID
FROM AUDSYS.UNIFIED_AUDIT_TRAIL
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
ORDER BY EVENT_TIMESTAMP DESC;

/*
================================================================================
    7. منح الصلاحيات للمدقق
================================================================================
*/

GRANT SELECT ON SEC_ADMIN.V_FAILED_LOGINS TO AUDITOR;
GRANT SELECT ON SEC_ADMIN.V_SENSITIVE_ACCESS TO AUDITOR;
GRANT SELECT ON SEC_ADMIN.V_SCHEMA_CHANGES TO AUDITOR;
GRANT SELECT ON SEC_ADMIN.V_AFTERHOURS_ACTIVITY TO AUDITOR;
GRANT SELECT ON SEC_ADMIN.V_USER_ACTIVITY_SUMMARY TO AUDITOR;

PROMPT تم إنشاء استعلامات المراقبة بنجاح بواسطة SYS ✓
