/*
================================================================================
    01_Audit_Policies.sql - سياسات التدقيق الموحد (Unified Auditing)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء سياسات التدقيق...

/*
================================================================================
    0. تنظيف السياسات القديمة (Robust Cleanup)
================================================================================
*/
DECLARE
    v_sql VARCHAR2(1000);
BEGIN
    FOR p IN (SELECT POLICY_NAME FROM AUDIT_UNIFIED_POLICIES WHERE POLICY_NAME LIKE 'ECOM_%') LOOP
        -- 1. محاولة إيقاف التدقيق (NOAUDIT)
        BEGIN
            v_sql := 'NOAUDIT POLICY ' || p.POLICY_NAME;
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN NULL; -- تجاهل الخطأ إذا لم تكن مفعلة
        END;

        -- 2. حذف السياسة (DROP)
        BEGIN
            v_sql := 'DROP AUDIT POLICY ' || p.POLICY_NAME;
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN NULL; -- تجاهل الخطأ إذا لم تكن موجودة
        END;
    END LOOP;
END;
/

PROMPT تم تنظيف السياسات القديمة.

/*
================================================================================
    1. سياسة تدقيق تسجيل الدخول (Logon/Logoff)
================================================================================
*/

CREATE AUDIT POLICY ECOM_LOGON_AUDIT
    ACTIONS LOGON, LOGOFF;

AUDIT POLICY ECOM_LOGON_AUDIT;

PROMPT ✓ سياسة تسجيل الدخول

/*
================================================================================
    2. سياسة تدقيق البيانات الحساسة (Sensitive Data Access)
    - مراقبة من يقرأ أو يعدل بيانات العملاء والمدفوعات
================================================================================
*/

CREATE AUDIT POLICY ECOM_SENSITIVE_DATA_AUDIT
    ACTIONS 
        SELECT ON ECOM_OWNER.CUSTOMERS,
        UPDATE ON ECOM_OWNER.CUSTOMERS,
        DELETE ON ECOM_OWNER.CUSTOMERS,
        SELECT ON ECOM_OWNER.PAYMENTS,
        UPDATE ON ECOM_OWNER.PAYMENTS;

AUDIT POLICY ECOM_SENSITIVE_DATA_AUDIT;

PROMPT ✓ سياسة البيانات الحساسة

/*
================================================================================
    3. سياسة تدقيق العمليات الإدارية (Admin Actions)
    - مراقبة إنشاء المستخدمين ومنح الصلاحيات
================================================================================
*/

CREATE AUDIT POLICY ECOM_ADMIN_AUDIT
    ACTIONS
        CREATE USER, ALTER USER, DROP USER,
        GRANT, REVOKE,
        CREATE ROLE, DROP ROLE,
        ALTER SYSTEM;

AUDIT POLICY ECOM_ADMIN_AUDIT;

PROMPT ✓ سياسة العمليات الإدارية

/*
================================================================================
    4. سياسة تدقيق تغييرات المخطط (Schema Changes)
    - مراقبة أي تعديل في هيكل قاعدة البيانات بواسطة المالك
================================================================================
*/

CREATE AUDIT POLICY ECOM_DDL_AUDIT
    ACTIONS
        CREATE TABLE, ALTER TABLE, DROP TABLE,
        CREATE INDEX, DROP INDEX,
        CREATE VIEW, DROP VIEW,
        CREATE PROCEDURE, DROP PROCEDURE;

AUDIT POLICY ECOM_DDL_AUDIT BY ECOM_OWNER;

PROMPT ✓ سياسة تغييرات المخطط

/*
================================================================================
    5. سياسة تدقيق المعاملات المالية (Orders & Payments)
================================================================================
*/

CREATE AUDIT POLICY ECOM_ORDERS_AUDIT
    ACTIONS
        INSERT ON ECOM_OWNER.ORDERS,
        UPDATE ON ECOM_OWNER.ORDERS,
        INSERT ON ECOM_OWNER.PAYMENTS,
        UPDATE ON ECOM_OWNER.PAYMENTS;

AUDIT POLICY ECOM_ORDERS_AUDIT;

PROMPT ✓ سياسة الطلبات والمدفوعات

/*
================================================================================
    6. التحقق من السياسات
================================================================================
*/

PROMPT ========================================
PROMPT سياسات التدقيق المفعلة:
PROMPT ========================================

SELECT 
    POLICY_NAME,
    ENABLED_OPT,
    SUCCESS,
    FAILURE
FROM AUDIT_UNIFIED_ENABLED_POLICIES
WHERE POLICY_NAME LIKE 'ECOM_%'
ORDER BY POLICY_NAME;

PROMPT تم إنشاء سياسات التدقيق بنجاح ✓
