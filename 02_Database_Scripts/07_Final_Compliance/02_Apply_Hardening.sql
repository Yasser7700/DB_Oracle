/*
================================================================================
    02_Apply_Hardening.sql - تطبيق التحصين الأمني (Hardening)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
    المتطلب: Lab 9 - Vulnerability Management
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT البدء في تطبيق إجراءات التحصين...

-- 1. قفل الحسابات الافتراضية غير المستخدمة
BEGIN
    FOR u IN (SELECT username FROM dba_users WHERE username IN ('SCOTT','HR','OE','SH','PM','BI','MDDATA') AND account_status = 'OPEN') LOOP
        EXECUTE IMMEDIATE 'ALTER USER ' || u.username || ' ACCOUNT LOCK PASSWORD EXPIRE';
        DBMS_OUTPUT.PUT_LINE('Account Locked: ' || u.username);
    END LOOP;
END;
/

-- 2. سحب صلاحيات خطيرة من PUBLIC
-- ملاحظة: يتم سحبها فقط إذا كانت ممنوحة
BEGIN
    FOR p IN (
        SELECT privilege, table_name FROM dba_tab_privs 
        WHERE grantee = 'PUBLIC' AND table_name IN ('UTL_FILE','UTL_SMTP','UTL_HTTP','DBMS_RANDOM')
    ) LOOP
        EXECUTE IMMEDIATE 'REVOKE ' || p.privilege || ' ON ' || p.table_name || ' FROM PUBLIC';
        DBMS_OUTPUT.PUT_LINE('Revoked ' || p.privilege || ' on ' || p.table_name || ' from PUBLIC');
    END LOOP;
END;
/

-- 3. تقييد التخمين على كلمات المرور
-- (تم تطبيقه مسبقاً عبر Profiles، لكن نؤكد عليه هنا)
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1/24; -- قفل لمدة ساعة

PROMPT تم تطبيق إجراءات التحصين بنجاح ✓

GRANT EXECUTE ON DBMS_RANDOM TO ECOM_OWNER;
