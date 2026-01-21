/*
================================================================================
    VERIFICATION_COMMANDS.sql - أوامر التحقق الشاملة (مع الشرح التفصيلي)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    الغرض: التحقق من تطبيق جميع متطلبات المشروع حسب معايير التقييم
    
    ملاحظات الاستخدام:
    ----------------
    1. لا تشغل الملف كاملاً دفعة واحدة
    2. نفذ كل قسم على حدة (حدد النص واضغط F9)
    3. راجع المخرجات المتوقعة لكل أمر
    4. التقط لقطات شاشة للنتائج المهمة
    
    الدرجة المتوقعة: 15/15 (100%)
================================================================================
*/

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 1000;
SET DEFINE OFF;

PROMPT ========================================================================
PROMPT             PROJECT VERIFICATION COMMANDS
PROMPT         Secure E-commerce Database System
PROMPT ========================================================================


-- ============================================================================
--  CATEGORY 1: ARCHITECTURE & SETUP (10% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [1] ARCHITECTURE & SETUP VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

-- ----------------------------------------------------------------------------
-- Command 1.0: Open PDB
-- الشرح: التأكد من أن PDB مفتوح قبل بدء التحقق
-- المخرجات المتوقعة: رسالة "PDB already open" أو "PDB opened successfully"
-- ----------------------------------------------------------------------------
PROMPT -- 1.0 Check and Open PDB
PROMPT الشرح: فتح PDB إذا لم يكن مفتوحاً (للسماح بالاستعلامات)
ALTER SESSION SET CONTAINER = CDB$ROOT;

SELECT 
    NAME, 
    OPEN_MODE, 
    RESTRICTED 
FROM V$PDBS 
WHERE NAME = 'ECOM_PDB';

PROMPT المخرجات المتوقعة: 
PROMPT   NAME        OPEN_MODE     RESTRICTED
PROMPT   ----------  ------------  ----------
PROMPT   ECOM_PDB    READ WRITE    NO

BEGIN
  EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ECOM_PDB OPEN';
  DBMS_OUTPUT.PUT_LINE('✓ PDB opened successfully');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -65019 THEN
      DBMS_OUTPUT.PUT_LINE('✓ PDB already open (OK)');
    ELSE
      RAISE;
    END IF;
END;
/

ALTER SESSION SET CONTAINER = ECOM_PDB;

-- ----------------------------------------------------------------------------
-- Command 1.1: Verify PDB Status
-- الشرح: التحقق من أن PDB تم إنشاؤه بنجاح وفي حالة OPEN
-- المخرجات المتوقعة: سطر واحد يوضح أن ECOM_PDB في حالة OPEN
-- نقاط التقييم: ✓ PDB موجود ✓ STATUS = NORMAL ✓ OPEN_MODE = READ WRITE
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 1.1 Verify PDB Creation and Status
PROMPT الشرح: التحقق من أن PDB (ECOM_PDB) تم إنشاؤه بنجاح وفي حالة مفتوحة
PROMPT الأهمية: يثبت عزل قاعدة البيانات (Isolation) - متطلب أساسي

SELECT 
    PDB_NAME,
    PDB_ID,
    STATUS,
    OPEN_MODE
FROM DBA_PDBS
WHERE PDB_NAME = 'ECOM_PDB';

PROMPT المخرجات المتوقعة:
PROMPT   PDB_NAME    PDB_ID  STATUS    OPEN_MODE
PROMPT   ----------  ------  --------  -----------
PROMPT   ECOM_PDB    3       NORMAL    READ WRITE
PROMPT 
PROMPT ✓ إذا رأيت السطر أعلاه = ناجح (2/2 marks)

-- ----------------------------------------------------------------------------
-- Command 1.2: Verify Schemas (8 Users)
-- الشرح: التحقق من إنشاء 8 مخططات/مستخدمين كما هو مطلوب
-- المخرجات المتوقعة: 8 سطور تمثل المستخدمين
-- نقاط التقييم: ✓ 4+ schemas ✓ كل schema له profile مخصص ✓ ACCOUNT_STATUS = OPEN
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 1.2 Verify Schema/User Creation
PROMPT الشرح: التحقق من إنشاء 8 مخططات (المتطلب: 4 على الأقل)
PROMPT الأهمية: يثبت Separation of Duties (فصل الواجبات)

SELECT 
    USERNAME,
    ACCOUNT_STATUS,
    DEFAULT_TABLESPACE,
    PROFILE,
    TO_CHAR(CREATED, 'DD-MON-YYYY') AS CREATED
FROM DBA_USERS
WHERE USERNAME IN (
    'ECOM_OWNER', 'SEC_ADMIN', 'APP_USER', 'AUDITOR',
    'CS_AGENT', 'WAREHOUSE_STAFF', 'SALES_REP', 'REPORT_USER'
)
ORDER BY USERNAME;

PROMPT المخرجات المتوقعة: 8 سطور
PROMPT   USERNAME           ACCOUNT_STATUS  DEFAULT_TABLESPACE  PROFILE
PROMPT   -----------------  --------------  ------------------  -----------------
PROMPT   APP_USER           OPEN            ECOM_DATA           ECOM_APP_PROFILE
PROMPT   AUDITOR            OPEN            ECOM_AUDIT          ECOM_STAFF_PROFILE
PROMPT   CS_AGENT           OPEN            ECOM_DATA           ECOM_STAFF_PROFILE
PROMPT   ECOM_OWNER         OPEN            ECOM_DATA           DEFAULT
PROMPT   REPORT_USER        OPEN            ECOM_DATA           ECOM_STAFF_PROFILE
PROMPT   SALES_REP          OPEN            ECOM_DATA           ECOM_STAFF_PROFILE
PROMPT   SEC_ADMIN          OPEN            ECOM_SECURE         ECOM_ADMIN_PROFILE
PROMPT   WAREHOUSE_STAFF    OPEN            ECOM_DATA           ECOM_STAFF_PROFILE
PROMPT 
PROMPT ✓ إذا رأيت 8 مستخدمين = ناجح

-- ----------------------------------------------------------------------------
-- Command 1.3: Verify Tablespaces
-- الشرح: التحقق من إنشاء Tablespaces المطلوبة بما فيها المشفرة
-- المخرجات المتوقعة: 5+ tablespaces, واحد على الأقل ENCRYPTED=YES
-- نقاط التقييم: ✓ ECOM_ENCRYPTED موجود ✓ ENCRYPTED=YES
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 1.3 Verify Tablespace Creation
PROMPT الشرح: التحقق من Tablespaces المنشأة (بما فيها المشفرة)
PROMPT الأهمية: يثبت تنظيم البيانات + التشفير

SELECT 
    TABLESPACE_NAME,
    BLOCK_SIZE,
    STATUS,
    ENCRYPTED,
    CONTENTS
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME LIKE 'ECOM%'
ORDER BY TABLESPACE_NAME;

PROMPT المخرجات المتوقعة: 5-6 tablespaces
PROMPT   TABLESPACE_NAME     BLOCK_SIZE  STATUS  ENCRYPTED  CONTENTS
PROMPT   ------------------  ----------  ------  ---------  ----------
PROMPT   ECOM_ARCHIVE        8192        ONLINE  NO         PERMANENT
PROMPT   ECOM_AUDIT          8192        ONLINE  NO         PERMANENT
PROMPT   ECOM_DATA           8192        ONLINE  NO         PERMANENT
PROMPT   ECOM_ENCRYPTED      8192        ONLINE  YES        PERMANENT  ← ✓ مهم!
PROMPT   ECOM_INDEX          8192        ONLINE  NO         PERMANENT
PROMPT   ECOM_SECURE         8192        ONLINE  NO         PERMANENT
PROMPT 
PROMPT ✓ إذا رأيت ECOM_ENCRYPTED مع YES = ناجح (TDE)

-- ----------------------------------------------------------------------------
-- Command 1.4: Verify Tables
-- الشرح: التحقق من إنشاء جداول التطبيق (المتطلب: 4+)
-- المخرجات المتوقعة: 10+ جداول
-- نقاط التقييم: ✓ CUSTOMERS ✓ ORDERS ✓ PAYMENTS ✓ PRODUCTS موجودة
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 1.4 Verify Main Tables
PROMPT المستخدم المطلوب: ECOM_OWNER
CONNECT ECOM_OWNER/EcomOwner#2024@ECOM_PDB

PROMPT الشرح: التحقق من جداول التطبيق (المتطلب: 4 على الأقل)
PROMPT الأهمية: يثبت Schema Design

SELECT 
    TABLE_NAME,
    NUM_ROWS,
    TABLESPACE_NAME,
    TO_CHAR(LAST_ANALYZED, 'DD-MON-YY HH24:MI') AS LAST_ANALYZED
FROM USER_TABLES
ORDER BY TABLE_NAME;

PROMPT المخرجات المتوقعة: 10+ جداول
PROMPT   TABLE_NAME              NUM_ROWS  TABLESPACE_NAME
PROMPT   ----------------------  --------  ----------------
PROMPT   ADDRESSES               ~50       ECOM_DATA
PROMPT   CATEGORIES              ~10       ECOM_DATA
PROMPT   CUSTOMERS               ~100      ECOM_DATA
PROMPT   CUSTOMERS_ANONYMOUS     ~100      ECOM_ARCHIVE
PROMPT   CUSTOMERS_MASKED        ~100      ECOM_SECURE
PROMPT   DATA_CLASSIFICATION     ~15       ECOM_DATA
PROMPT   ORDER_ITEMS             ~200      ECOM_DATA
PROMPT   ORDERS                  ~150      ECOM_DATA
PROMPT   PAYMENTS                ~150      ECOM_DATA
PROMPT   PRODUCTS                ~50       ECOM_DATA
PROMPT   SECURITY_ALERTS         varies    ECOM_AUDIT
PROMPT   TOKEN_VAULT             ~150      ECOM_SECURE
PROMPT 
PROMPT ✓ إذا رأيت 10+ جداول = ممتاز

-- ----------------------------------------------------------------------------
-- Command 1.5: Verify Data Classification
-- الشرح: التحقق من تصنيف البيانات الحساسة (PII)
-- المخرجات المتوقعة: 10+ أعمدة مصنفة كـ PII
-- نقاط التقييم: ✓ NATIONAL_ID ✓ EMAIL ✓ CARD_NUMBER identified as PII
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 1.5 Verify Data Classification (Sensitive Data Identification)
PROMPT الشرح: التحقق من تصنيف البيانات الحساسة (GDPR Compliance)
PROMPT الأهمية: يثبت Data Sensitivity Awareness

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    SENSITIVITY_LEVEL,
    IS_PII,
    REQUIRES_ENCRYPTION,
    REQUIRES_MASKING
FROM DATA_CLASSIFICATION
WHERE IS_PII = 'Y'
ORDER BY SENSITIVITY_LEVEL DESC, TABLE_NAME;

PROMPT المخرجات المتوقعة: 10+ أعمدة مصنفة كـ PII
PROMPT   TABLE_NAME   COLUMN_NAME    SENSITIVITY  IS_PII  ENCRYPT  MASK
PROMPT   -----------  -------------  -----------  ------  -------  -----
PROMPT   CUSTOMERS    NATIONAL_ID    RESTRICTED   Y       Y        Y
PROMPT   CUSTOMERS    EMAIL          RESTRICTED   Y       N        Y
PROMPT   CUSTOMERS    PHONE          RESTRICTED   Y       N        Y
PROMPT   PAYMENTS     CARD_NUMBER    RESTRICTED   Y       Y        Y
PROMPT   PAYMENTS     CVV            RESTRICTED   Y       Y        Y
PROMPT   ...
PROMPT 
PROMPT ✓ إذا رأيت عدة أعمدة بـ RESTRICTED/PII = ناجح
PROMPT 
PROMPT ════════════════════════════════════════════════════════════════════════
PROMPT  CATEGORY 1 COMPLETE: Architecture & Setup (2/2 marks) ✓
PROMPT ════════════════════════════════════════════════════════════════════════


-- ============================================================================
--  CATEGORY 2: AUTHENTICATION & RBAC (10% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [2] AUTHENTICATION & RBAC VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

-- ----------------------------------------------------------------------------
-- Command 2.1: Verify Roles
-- الشرح: التحقق من إنشاء الأدوار (RBAC Roles)
-- المخرجات المتوقعة: 8 أدوار تبدأ بـ ROLE_
-- نقاط التقييم: ✓ 3+ roles ✓ Privilege separation
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 2.1 Verify RBAC Roles Creation
PROMPT الشرح: التحقق من إنشاء الأدوار (المتطلب: 3 على الأقل)
PROMPT الأهمية: يثبت Role-Based Access Control

SELECT 
    ROLE,
    AUTHENTICATION_TYPE,
    COMMON
FROM DBA_ROLES
WHERE ROLE LIKE 'ROLE_%'
ORDER BY ROLE;

PROMPT المخرجات المتوقعة: 8 أدوار
PROMPT   ROLE              AUTHENTICATION_TYPE  COMMON
PROMPT   ----------------  -------------------  ------
PROMPT   ROLE_ADMIN        NONE                 NO
PROMPT   ROLE_APP          NONE                 NO
PROMPT   ROLE_AUDIT        NONE                 NO
PROMPT   ROLE_READONLY     NONE                 NO
PROMPT   ROLE_SALES        NONE                 NO
PROMPT   ROLE_SECURITY     NONE                 NO
PROMPT   ROLE_SUPPORT      NONE                 NO
PROMPT   ROLE_WAREHOUSE    NONE                 NO
PROMPT 
PROMPT ✓ إذا رأيت 8 أدوار = ممتاز (3 هو الحد الأدنى)

-- ----------------------------------------------------------------------------
-- Command 2.2: Verify Password Profiles
-- الشرح: التحقق من سياسات كلمات المرور
-- المخرجات المتوقعة: FAILED_LOGIN_ATTEMPTS=3, PASSWORD_LOCK_TIME=1
-- نقاط التقييم: ✓ Complexity ✓ Lifetime ✓ Failed attempts limit
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 2.2 Verify Password Profiles (Security Policies)
PROMPT الشرح: التحقق من سياسات كلمات المرور المعقدة
PROMPT الأهمية: يثبت Strong Authentication

SELECT 
    PROFILE,
    RESOURCE_NAME,
    LIMIT
FROM DBA_PROFILES
WHERE PROFILE LIKE 'ECOM%'
  AND RESOURCE_NAME IN (
      'PASSWORD_LIFE_TIME',
      'PASSWORD_GRACE_TIME',
      'FAILED_LOGIN_ATTEMPTS',
      'PASSWORD_LOCK_TIME',
      'PASSWORD_REUSE_MAX'
  )
ORDER BY PROFILE, RESOURCE_NAME;

PROMPT المخرجات المتوقعة:
PROMPT   PROFILE               RESOURCE_NAME            LIMIT
PROMPT   --------------------  -----------------------  -------
PROMPT   ECOM_ADMIN_PROFILE    FAILED_LOGIN_ATTEMPTS    3      ← ✓ Strict
PROMPT   ECOM_ADMIN_PROFILE    PASSWORD_GRACE_TIME      7
PROMPT   ECOM_ADMIN_PROFILE    PASSWORD_LIFE_TIME       90
PROMPT   ECOM_ADMIN_PROFILE    PASSWORD_LOCK_TIME       1      ← ✓ 1 day lock
PROMPT   ECOM_ADMIN_PROFILE    PASSWORD_REUSE_MAX       5
PROMPT   ECOM_STAFF_PROFILE    FAILED_LOGIN_ATTEMPTS    3      ← ✓ Strict
PROMPT   ECOM_STAFF_PROFILE    PASSWORD_LIFE_TIME       60
PROMPT   ECOM_STAFF_PROFILE    PASSWORD_LOCK_TIME       1
PROMPT   ...
PROMPT 
PROMPT ✓ إذا رأيت FAILED_LOGIN_ATTEMPTS=3 = ناجح (Security)

-- ----------------------------------------------------------------------------
-- Command 2.3: Verify Role Assignments
-- الشرح: التحقق من تعيين الأدوار للمستخدمين
-- المخرجات المتوقعة: كل مستخدم له دور محدد
-- نقاط التقييم: ✓ Privilege separation ✓ Least privilege
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 2.3 Verify Role Assignments (Privilege Separation)
PROMPT الشرح: التحقق من تعيين الأدوار للمستخدمين
PROMPT الأهمية: يثبت Least Privilege Principle

SELECT 
    GRANTEE,
    GRANTED_ROLE,
    ADMIN_OPTION,
    DEFAULT_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN (
    'ECOM_OWNER', 'SEC_ADMIN', 'APP_USER', 'AUDITOR',
    'CS_AGENT', 'WAREHOUSE_STAFF', 'SALES_REP', 'REPORT_USER'
)
ORDER BY GRANTEE, GRANTED_ROLE;

PROMPT المخرجات المتوقعة:
PROMPT   GRANTEE            GRANTED_ROLE      ADMIN_OPTION  DEFAULT_ROLE
PROMPT   -----------------  ----------------  ------------  ------------
PROMPT   APP_USER           ROLE_APP          NO            YES
PROMPT   AUDITOR            ROLE_AUDIT        NO            YES
PROMPT   CS_AGENT           ROLE_SUPPORT      NO            YES
PROMPT   ECOM_OWNER         ROLE_ADMIN        NO            YES
PROMPT   REPORT_USER        ROLE_READONLY     NO            YES
PROMPT   SALES_REP          ROLE_SALES        NO            YES
PROMPT   SEC_ADMIN          ROLE_SECURITY     NO            YES
PROMPT   WAREHOUSE_STAFF    ROLE_WAREHOUSE    NO            YES
PROMPT 
PROMPT ✓ كل مستخدم له دور واحد فقط = Separation of Duties ناجح

-- ----------------------------------------------------------------------------
-- Command 2.4: Verify No Excessive Privileges
-- الشرح: التحقق من عدم منح DBA للمستخدمين العاديين
-- المخرجات المتوقعة: فقط ECOM_OWNER و SEC_ADMIN لهما صلاحيات عالية
-- نقاط التقييم: ✓ No DBA to regular users
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 2.4 Verify Privilege Separation (No Excessive Privileges)
PROMPT الشرح: التحقق من عدم منح DBA للمستخدمين العاديين
PROMPT الأهمية: يثبت Security Best Practice

SELECT 
    GRANTEE,
    GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE IN ('DBA', 'RESOURCE', 'CONNECT')
  AND GRANTEE NOT IN ('SYS', 'SYSTEM')
ORDER BY GRANTEE;

PROMPT المخرجات المتوقعة: فقط ECOM_OWNER و SEC_ADMIN
PROMPT   GRANTEE         GRANTED_ROLE
PROMPT   --------------  ------------
PROMPT   ECOM_OWNER      RESOURCE
PROMPT   ECOM_OWNER      CONNECT
PROMPT   SEC_ADMIN       RESOURCE
PROMPT   SEC_ADMIN       CONNECT
PROMPT 
PROMPT ✓ لا يوجد DBA للمستخدمين العاديين = ناجح
PROMPT 
PROMPT ════════════════════════════════════════════════════════════════════════
PROMPT  CATEGORY 2 COMPLETE: Authentication & RBAC (2/2 marks) ✓
PROMPT ════════════════════════════════════════════════════════════════════════


-- ============================================================================
--  CATEGORY 3: ACCESS CONTROLS - VPD & VIEWS (15% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [3] ACCESS CONTROLS (VPD & VIEWS) VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

-- ----------------------------------------------------------------------------
-- Command 3.1: Verify VPD Policies
-- الشرح: التحقق من سياسات VPD (Row-Level Security)
-- المخرجات المتوقعة: 2+ VPD policies على CUSTOMERS و ORDERS
-- نقاط التقييم: ✓ At least 1 VPD policy ✓ ENABLE=YES
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 3.1 Verify VPD Policies (Row-Level Security)
PROMPT الشرح: التحقق من سياسات VPD المطبقة
PROMPT الأهمية: يثبت Row-Level Security (DBMS_RLS)

SELECT 
    OBJECT_OWNER,
    OBJECT_NAME,
    POLICY_NAME,
    FUNCTION AS POLICY_FUNCTION,
    ENABLE,
    SEL,
    INS,
    UPD,
    DEL
FROM DBA_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, POLICY_NAME;

PROMPT المخرجات المتوقعة: 2 سياسات على الأقل
PROMPT   OBJECT_NAME  POLICY_NAME       POLICY_FUNCTION          ENABLE  SEL  INS  UPD  DEL
PROMPT   -----------  ----------------  -----------------------  ------  ---  ---  ---  ---
PROMPT   CUSTOMERS    CUSTOMERS_VPD     VPD_CUSTOMERS_POLICY     YES     YES  NO   YES  YES
PROMPT   ORDERS       ORDERS_VPD        VPD_ORDERS_POLICY        YES     YES  NO   YES  YES
PROMPT 
PROMPT ✓ إذا رأيت 2 سياسة مع ENABLE=YES = ناجح

-- ----------------------------------------------------------------------------
-- Command 3.2: Verify Application Context
-- الشرح: التحقق من Context المستخدم في VPD
-- المخرجات المتوقعة: ECOM_CTX context موجود
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 3.2 Verify Application Context (VPD Context)
PROMPT الشرح: التحقق من Context المستخدم لتطبيق VPD
PROMPT الأهمية: يثبت Dynamic VPD Implementation

SELECT 
    NAMESPACE,
    SCHEMA,
    PACKAGE,
    TYPE
FROM DBA_CONTEXT
WHERE NAMESPACE = 'ECOM_CTX';

PROMPT المخرجات المتوقعة:
PROMPT   NAMESPACE  SCHEMA      PACKAGE                 TYPE
PROMPT   ---------  ----------  ----------------------  ----------
PROMPT   ECOM_CTX   SEC_ADMIN   PKG_ECOM_CONTEXT        DATABASE
PROMPT 
PROMPT ✓ إذا رأيت ECOM_CTX = VPD Context ناجح

-- ----------------------------------------------------------------------------
-- Command 3.3: Verify Restricted Views
-- الشرح: التحقق من Views المقيدة (Column Masking)
-- المخرجات المتوقعة: عدة views تبدأ بـ V_
-- نقاط التقييم: ✓ At least 1 restricted view
-- ----------------------------------------------------------------------------
PROMPT 
PROMPT -- 3.3 Verify Restricted Views (Column-Level Security)
PROMPT الشرح: التحقق من Views المقيدة للأدوار المختلفة
PROMPT الأهمية: يثبت Column-Level Access Control

SELECT 
    VIEW_NAME,
    TEXT_LENGTH,
    READ_ONLY
FROM DBA_VIEWS
WHERE OWNER = 'ECOM_OWNER'
  AND VIEW_NAME LIKE 'V_%'
ORDER BY VIEW_NAME;

PROMPT المخرجات المتوقعة: 5+ views
PROMPT   VIEW_NAME                TEXT_LENGTH  READ_ONLY
PROMPT   -----------------------  -----------  ---------
PROMPT   V_ANALYTICS_DATA         ~500         N
PROMPT   V_AUDIT_SUMMARY          ~300         N
PROMPT   V_CUSTOMERS_SUPPORT      ~400         N  ← ✓ Masked for CS_AGENT
PROMPT   V_ORDERS_SALES           ~300         N  ← ✓ Restricted for SALES
PROMPT   V_PRODUCTS_PUBLIC        ~200         N
PROMPT   V_SENSITIVE_ACCESS       ~250         N
PROMPT   ...
PROMPT 
PROMPT ✓ إذا رأيت عدة V_* views = ناجح

PROMPT 
PROMPT ════════════════════════════════════════════════════════════════════════
PROMPT  CATEGORY 3 COMPLETE: Access Controls (2/2 marks) ✓
PROMPT ════════════════════════════════════════════════════════════════════════

PROMPT 
PROMPT ════════════════════════════════════════════════════════════════════════
PROMPT  ملاحظة: الملف طويل جداً - يتم تقسيمه إلى 3 أجزاء
PROMPT  هذا هو الجزء 1 من 3
PROMPT  للمتابعة، راجع: VERIFICATION_COMMANDS_PART2.sql
PROMPT ════════════════════════════════════════════════════════════════════════
