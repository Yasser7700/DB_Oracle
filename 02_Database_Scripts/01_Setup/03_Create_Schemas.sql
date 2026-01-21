/*
================================================================================
    03_Create_Schemas.sql - إنشاء المستخدمين والمخططات
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    الوصف: إنشاء المستخدمين الأساسيين مع صلاحياتهم الأولية
    المستخدم المطلوب: SYS AS SYSDBA
    المتطلبات: PDB و Tablespaces موجودة
================================================================================
*/
show con_name;
-- التأكد من الاتصال بـ ECOM_PDB
ALTER SESSION SET CONTAINER = ECOM_PDB;

SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS CURRENT_CONTAINER FROM DUAL;

PROMPT ========================================
PROMPT إنشاء المستخدمين والمخططات
PROMPT ========================================

/*
================================================================================
    الخطوة 1: إنشاء مستخدم مالك المخطط (Schema Owner)
================================================================================
*/

-- حذف المستخدم إذا كان موجوداً (للتثبيت النظيف)
-- DROP USER ECOM_OWNER CASCADE;

CREATE USER ECOM_OWNER
    IDENTIFIED BY "EcomOwner#2024"
    DEFAULT TABLESPACE ECOM_DATA
    TEMPORARY TABLESPACE ECOM_TEMP
    QUOTA UNLIMITED ON ECOM_DATA
    QUOTA UNLIMITED ON ECOM_INDEX
    QUOTA UNLIMITED ON ECOM_SECURE
    QUOTA UNLIMITED ON ECOM_ARCHIVE
    ACCOUNT UNLOCK;

-- منح الصلاحيات الأساسية
GRANT CREATE SESSION TO ECOM_OWNER;
GRANT CREATE TABLE TO ECOM_OWNER;
GRANT CREATE VIEW TO ECOM_OWNER;
GRANT CREATE SEQUENCE TO ECOM_OWNER;
GRANT CREATE PROCEDURE TO ECOM_OWNER;
GRANT CREATE TRIGGER TO ECOM_OWNER;
GRANT CREATE TYPE TO ECOM_OWNER;
GRANT CREATE SYNONYM TO ECOM_OWNER;
GRANT CREATE MATERIALIZED VIEW TO ECOM_OWNER;

PROMPT ✓ تم إنشاء ECOM_OWNER بنجاح

/*
================================================================================
    الخطوة 2: إنشاء مستخدم مسؤول الأمان (Security Admin)
================================================================================
*/

CREATE USER SEC_ADMIN
    IDENTIFIED BY "SecAdmin#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

-- منح صلاحيات الأمان
GRANT CREATE SESSION TO SEC_ADMIN;
GRANT CREATE PROCEDURE TO SEC_ADMIN;
GRANT CREATE ANY CONTEXT TO SEC_ADMIN;
GRANT EXECUTE ON DBMS_RLS TO SEC_ADMIN;
GRANT EXECUTE ON DBMS_REDACT TO SEC_ADMIN;
GRANT EXECUTE ON DBMS_FGA TO SEC_ADMIN;
GRANT SELECT ANY DICTIONARY TO SEC_ADMIN;

PROMPT ✓ تم إنشاء SEC_ADMIN بنجاح

/*
================================================================================
    الخطوة 3: إنشاء مستخدم تطبيق الويب (Application User)
================================================================================
*/

CREATE USER APP_USER
    IDENTIFIED BY "AppUser#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO APP_USER;

PROMPT ✓ تم إنشاء APP_USER بنجاح

/*
================================================================================
    الخطوة 4: إنشاء مستخدم خدمة العملاء (Customer Service)
================================================================================
*/

CREATE USER CS_AGENT
    IDENTIFIED BY "CsAgent#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO CS_AGENT;

PROMPT ✓ تم إنشاء CS_AGENT بنجاح

/*
================================================================================
    الخطوة 5: إنشاء مستخدم المستودع (Warehouse Staff)
================================================================================
*/

CREATE USER WAREHOUSE_STAFF
    IDENTIFIED BY "Warehouse#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO WAREHOUSE_STAFF;

PROMPT ✓ تم إنشاء WAREHOUSE_STAFF بنجاح

/*
================================================================================
    الخطوة 6: إنشاء مستخدم المبيعات (Sales Representative)
================================================================================
*/

CREATE USER SALES_REP
    IDENTIFIED BY "SalesRep#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO SALES_REP;

PROMPT ✓ تم إنشاء SALES_REP بنجاح

/*
================================================================================
    الخطوة 7: إنشاء مستخدم المدقق (Auditor)
================================================================================
*/

CREATE USER AUDITOR
    IDENTIFIED BY "Auditor#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    QUOTA 100M ON ECOM_AUDIT
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO AUDITOR;
GRANT SELECT ANY DICTIONARY TO AUDITOR;
GRANT AUDIT_VIEWER TO AUDITOR;

PROMPT ✓ تم إنشاء AUDITOR بنجاح

/*
================================================================================
    الخطوة 8: إنشاء مستخدم التقارير (Report User)
================================================================================
*/

CREATE USER REPORT_USER
    IDENTIFIED BY "ReportUser#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO REPORT_USER;

PROMPT ✓ تم إنشاء REPORT_USER بنجاح

/*
================================================================================
    الخطوة 9: إنشاء مستخدم المدير (Manager)
================================================================================
*/

CREATE USER ECOM_MANAGER
    IDENTIFIED BY "EcomManager#2024"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE ECOM_TEMP
    ACCOUNT UNLOCK;

GRANT CREATE SESSION TO ECOM_MANAGER;

PROMPT ✓ تم إنشاء ECOM_MANAGER بنجاح

/*
================================================================================
    الخطوة 10: التحقق من المستخدمين المنشأين
================================================================================
*/

PROMPT ========================================
PROMPT المستخدمون المنشأون:
PROMPT ========================================

SELECT 
    USERNAME,
    ACCOUNT_STATUS,
    DEFAULT_TABLESPACE,
    TEMPORARY_TABLESPACE,
    CREATED
FROM DBA_USERS
WHERE USERNAME IN (
    'ECOM_OWNER',
    'SEC_ADMIN',
    'APP_USER',
    'CS_AGENT',
    'WAREHOUSE_STAFF',
    'SALES_REP',
    'AUDITOR',
    'REPORT_USER',
    'ECOM_MANAGER'
)
ORDER BY USERNAME;

/*
================================================================================
    الخطوة 11: عرض الصلاحيات الممنوحة
================================================================================
*/

PROMPT ========================================
PROMPT الصلاحيات الممنوحة:
PROMPT ========================================

SELECT 
    GRANTEE,
    PRIVILEGE
FROM DBA_SYS_PRIVS
WHERE GRANTEE IN (
    'ECOM_OWNER',
    'SEC_ADMIN',
    'APP_USER',
    'AUDITOR'
)
ORDER BY GRANTEE, PRIVILEGE;

PROMPT ========================================
PROMPT تم الانتهاء من إنشاء جميع المستخدمين بنجاح
PROMPT ========================================

/*
================================================================================
    ملخص المستخدمين المنشأين:
--------------------------------------------------------------------------------
    ECOM_OWNER      - مالك المخطط، جميع صلاحيات إنشاء الكائنات
    SEC_ADMIN       - مسؤول الأمان، صلاحيات VPD والتدقيق
    APP_USER        - تطبيق الويب، صلاحيات محدودة
    CS_AGENT        - خدمة العملاء، قراءة بيانات العملاء
    WAREHOUSE_STAFF - المستودع، إدارة الشحنات
    SALES_REP       - المبيعات، إدخال الطلبات
    AUDITOR         - المدقق، قراءة سجلات التدقيق
    REPORT_USER     - التقارير، قراءة فقط
    ECOM_MANAGER    - المدير، صلاحيات إشرافية
================================================================================
    ⚠️ تحذير: غيّر كلمات المرور فوراً في بيئة الإنتاج!
================================================================================
*/

-- نهاية السكربت
