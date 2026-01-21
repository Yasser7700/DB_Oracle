/*
================================================================================
    00_Grant_Audit_View.sql - منح صلاحيات قراءة سجل التدقيق
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
    الوصف: هذا الملف ضروري لتمكين المستخدمين من إنشاء تقارير المراقبة
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT منح صلاحيات سجل التدقيق الموحد...

-- 1. تنظيف الصلاحيات القديمة
BEGIN
    EXECUTE IMMEDIATE 'REVOKE READ ON AUDSYS.UNIFIED_AUDIT_TRAIL FROM SEC_ADMIN';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 2. منح صلاحية SELECT الكاملة مع حق التمرير (GRANT OPTION)
-- هذا ضروري جداً لكي يتمكن SEC_ADMIN من إنشاء VIEWS ومنح صلاحيات عليها للمدقق
GRANT SELECT ON AUDSYS.UNIFIED_AUDIT_TRAIL TO SEC_ADMIN WITH GRANT OPTION;

-- 3. حل مشكلة الاعتماديات الداخلية (Recursion Dependencies)
-- Unified Audit Trail يعتمد على جداول نظام داخلية، يجب منح SEC_ADMIN صلاحية عليها لتمريرها
GRANT SELECT ON SYS.STMT_AUDIT_OPTION_MAP TO SEC_ADMIN WITH GRANT OPTION;
GRANT SELECT ON SYS.AUDIT_UNIFIED_POLICIES TO SEC_ADMIN WITH GRANT OPTION;
GRANT SELECT ON SYS.AUDIT_UNIFIED_ENABLED_POLICIES TO SEC_ADMIN WITH GRANT OPTION;

-- 4. صلاحيات أخرى
GRANT CREATE VIEW TO SEC_ADMIN;
GRANT AUDIT_ADMIN TO SEC_ADMIN;
GRANT AUDIT_VIEWER TO SEC_ADMIN;

-- 5. منح صلاحيات للمستخدمين الآخرين
GRANT SELECT ON AUDSYS.UNIFIED_AUDIT_TRAIL TO ECOM_OWNER;
GRANT SELECT ON AUDSYS.UNIFIED_AUDIT_TRAIL TO AUDITOR;

PROMPT تم منح الصلاحيات وتصحيح سلسلة الاعتماديات بنجاح ✓
