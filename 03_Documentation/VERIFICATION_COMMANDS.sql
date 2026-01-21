/*
================================================================================
    VERIFICATION_COMMANDS.sql - أوامر التحقق الشاملة
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    الغرض: التحقق من تطبيق جميع متطلبات المشروع حسب معايير التقييم
    ملاحظة: كل قسم يحدد المستخدم المطلوب لتنفيذ الأوامر
================================================================================
*/

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 1000;

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

PROMPT -- 1.0 Check and Open PDB (if needed)
PROMPT Switching to CDB Root first...
ALTER SESSION SET CONTAINER = CDB$ROOT;

PROMPT Checking PDB status...
SELECT NAME, OPEN_MODE, RESTRICTED FROM V$PDBS WHERE NAME = 'ECOM_PDB';

PROMPT Opening ECOM_PDB if not already open...
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

PROMPT Switching to ECOM_PDB for verification...
ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT -- 1.1 Verify PDB Creation and Status
PROMPT Expected: ECOM_PDB should be OPEN
SELECT 
    PDB_NAME,
    PDB_ID,
    STATUS,
    OPEN_MODE
FROM DBA_PDBS
WHERE PDB_NAME = 'ECOM_PDB';

PROMPT 
PROMPT -- 1.2 Verify Schema/User Creation (8 schemas)
PROMPT Expected: 8 users (ECOM_OWNER, SEC_ADMIN, APP_USER, AUDITOR, CS_AGENT, WAREHOUSE_STAFF, SALES_REP, REPORT_USER)
SELECT 
    USERNAME,
    ACCOUNT_STATUS,
    DEFAULT_TABLESPACE,
    PROFILE,
    CREATED
FROM DBA_USERS
WHERE USERNAME IN (
    'ECOM_OWNER', 'SEC_ADMIN', 'APP_USER', 'AUDITOR',
    'CS_AGENT', 'WAREHOUSE_STAFF', 'SALES_REP', 'REPORT_USER'
)
ORDER BY USERNAME;

PROMPT 
PROMPT -- 1.3 Verify Tablespace Creation
PROMPT Expected: ECOM_DATA, ECOM_INDEX, ECOM_AUDIT, ECOM_SECURE, ECOM_ENCRYPTED
SELECT 
    TABLESPACE_NAME,
    BLOCK_SIZE,
    STATUS,
    ENCRYPTED,
    CONTENTS
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME LIKE 'ECOM%'
ORDER BY TABLESPACE_NAME;

PROMPT 
PROMPT -- 1.4 Verify Main Tables (Switch to ECOM_OWNER)
PROMPT المستخدم: ECOM_OWNER
CONNECT ECOM_OWNER/EcomOwner#2024@ECOM_PDB

PROMPT Expected: 10+ tables
SELECT 
    TABLE_NAME,
    NUM_ROWS,
    TABLESPACE_NAME,
    LAST_ANALYZED
FROM USER_TABLES
ORDER BY TABLE_NAME;

PROMPT 
PROMPT -- 1.5 Verify Data Classification Table
PROMPT Expected: Sensitive columns identified (IS_PII='Y')
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

PROMPT -- 2.1 Verify Roles Creation
PROMPT Expected: 8 roles (ROLE_ADMIN, ROLE_SALES, ROLE_SUPPORT, etc.)
SELECT 
    ROLE,
    AUTHENTICATION_TYPE,
    COMMON
FROM DBA_ROLES
WHERE ROLE LIKE 'ROLE_%'
ORDER BY ROLE;

PROMPT 
PROMPT -- 2.2 Verify Password Profiles
PROMPT Expected: ECOM_ADMIN_PROFILE, ECOM_STAFF_PROFILE with strict limits
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

PROMPT 
PROMPT -- 2.3 Verify Role Assignments
PROMPT Expected: Each user has appropriate role
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

PROMPT 
PROMPT -- 2.4 Verify Privilege Separation (No DBA to regular users)
PROMPT Expected: Only ECOM_OWNER and SEC_ADMIN have elevated privileges
SELECT 
    GRANTEE,
    GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTED_ROLE IN ('DBA', 'RESOURCE', 'CONNECT')
  AND GRANTEE NOT IN ('SYS', 'SYSTEM')
ORDER BY GRANTEE;


-- ============================================================================
--  CATEGORY 3: ACCESS CONTROLS - VPD & VIEWS (15% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [3] ACCESS CONTROLS (VPD & VIEWS) VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

PROMPT -- 3.1 Verify VPD Policies
PROMPT Expected: CUSTOMERS_VPD, ORDERS_VPD policies active
SELECT 
    OBJECT_OWNER,
    OBJECT_NAME,
    POLICY_NAME,
    FUNCTION,
    ENABLE,
    SEL,
    INS,
    UPD,
    DEL
FROM DBA_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, POLICY_NAME;

PROMPT 
PROMPT -- 3.2 Verify Application Context
PROMPT Expected: ECOM_CTX context exists
SELECT 
    NAMESPACE,
    SCHEMA,
    PACKAGE,
    TYPE
FROM DBA_CONTEXT
WHERE NAMESPACE = 'ECOM_CTX';

PROMPT 
PROMPT -- 3.3 Verify Restricted Views
PROMPT Expected: Multiple V_* views with masked columns
SELECT 
    VIEW_NAME,
    TEXT_LENGTH,
    READ_ONLY
FROM DBA_VIEWS
WHERE OWNER = 'ECOM_OWNER'
  AND VIEW_NAME LIKE 'V_%'
ORDER BY VIEW_NAME;

PROMPT 
PROMPT -- 3.4 Test VPD Policy (as SALES_REP)
PROMPT المستخدم: SALES_REP
CONNECT SALES_REP/SalesRep#2024@ECOM_PDB

PROMPT Expected: Limited rows based on VPD policy
SELECT COUNT(*) AS VISIBLE_CUSTOMERS
FROM ECOM_OWNER.CUSTOMERS;

PROMPT 
PROMPT -- 3.5 Test Masked View (as CS_AGENT)
PROMPT المستخدم: CS_AGENT
CONNECT CS_AGENT/CsAgent#2024@ECOM_PDB

PROMPT Expected: EMAIL and PHONE masked
SELECT 
    CUSTOMER_ID,
    FIRST_NAME,
    EMAIL,
    PHONE
FROM ECOM_OWNER.V_CUSTOMERS_SUPPORT
FETCH FIRST 5 ROWS ONLY;

PROMPT 
PROMPT -- 3.6 Verify Column-Level Privileges
PROMPT المستخدم: SYS
CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

SELECT 
    GRANTEE,
    TABLE_NAME,
    COLUMN_NAME,
    PRIVILEGE
FROM DBA_COL_PRIVS
WHERE OWNER = 'ECOM_OWNER'
  AND GRANTEE LIKE 'ROLE_%'
ORDER BY TABLE_NAME, GRANTEE;


-- ============================================================================
--  CATEGORY 4: PRIVACY TECHNIQUES (10% - 2 marks)
--  المستخدم المطلوب: ECOM_OWNER
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [4] PRIVACY TECHNIQUES VERIFICATION
PROMPT  Required User: ECOM_OWNER
PROMPT ========================================================================

CONNECT ECOM_OWNER/EcomOwner#2024@ECOM_PDB

PROMPT -- 4.1 Verify Static Masking Table
PROMPT Expected: CUSTOMERS_MASKED with masked data
SELECT 
    CUSTOMER_ID,
    FIRST_NAME,
    EMAIL,
    PHONE
FROM CUSTOMERS_MASKED
FETCH FIRST 5 ROWS ONLY;

PROMPT 
PROMPT -- 4.2 Verify Tokenization (Token Vault)
PROMPT Expected: Tokens for credit cards
SELECT 
    TOKEN,
    CREATED_DATE,
    LENGTH(ENCRYPTED_VALUE) AS ENCRYPTED_LENGTH
FROM TOKEN_VAULT
FETCH FIRST 5 ROWS ONLY;

PROMPT 
PROMPT -- 4.3 Verify Pseudonymization (Anonymous Table)
PROMPT Expected: Anonymized customer data
SELECT 
    ANON_ID,
    AGE_GROUP,
    CITY,
    TOTAL_PURCHASES
FROM CUSTOMERS_ANONYMOUS
FETCH FIRST 10 ROWS ONLY;

PROMPT 
PROMPT -- 4.4 Verify Dynamic Redaction Policies
PROMPT المستخدم: SYS
CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT Expected: Redaction policies on NATIONAL_ID, EMAIL, PHONE, DOB
SELECT 
    OBJECT_OWNER,
    OBJECT_NAME,
    COLUMN_NAME,
    FUNCTION_TYPE,
    POLICY_NAME,
    ENABLE
FROM REDACTION_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, COLUMN_NAME;

PROMPT 
PROMPT -- 4.5 Test Redaction (as CS_AGENT - should see redacted)
PROMPT المستخدم: CS_AGENT
CONNECT CS_AGENT/CsAgent#2024@ECOM_PDB

SELECT 
    CUSTOMER_ID,
    NATIONAL_ID,
    EMAIL,
    DATE_OF_BIRTH
FROM ECOM_OWNER.CUSTOMERS
FETCH FIRST 3 ROWS ONLY;


-- ============================================================================
--  CATEGORY 5: ENCRYPTION (TDE & BACKUPS) (10% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [5] ENCRYPTION (TDE & BACKUPS) VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT -- 5.1 Verify Wallet Status
PROMPT Expected: OPEN, FILE
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT 
    WRL_TYPE,
    STATUS,
    WALLET_TYPE,
    WALLET_ORDER,
    FULLY_BACKED_UP,
    CON_ID
FROM V$ENCRYPTION_WALLET;

PROMPT 
PROMPT -- 5.2 Verify Encrypted Tablespace
PROMPT Expected: ECOM_ENCRYPTED with ENCRYPTED=YES
ALTER SESSION SET CONTAINER = ECOM_PDB;
SELECT 
    TABLESPACE_NAME,
    ENCRYPTED,
    ENCRYPTIONALG AS ALGORITHM,
    STATUS
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME = 'ECOM_ENCRYPTED';

PROMPT 
PROMPT -- 5.3 Verify Encryption Keys
PROMPT Expected: At least one key for ECOM_PDB
SELECT 
    KEY_ID,
    CREATION_TIME,
    ACTIVATION_TIME,
    CON_ID
FROM V$ENCRYPTION_KEYS
WHERE CON_ID > 2;

PROMPT 
PROMPT -- 5.4 Verify ARCHIVELOG Mode (Required for Online Backups)
PROMPT Expected: ARCHIVELOG
SELECT LOG_MODE FROM V$DATABASE;


-- ============================================================================
--  CATEGORY 6: BACKUP & RECOVERY (10% - 1 mark)
--  المستخدم المطلوب: RMAN (من CMD)
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [6] BACKUP & RECOVERY VERIFICATION
PROMPT  Required: RMAN from Command Line
PROMPT ========================================================================

PROMPT -- الأوامر التالية يجب تنفيذها من CMD (ليس SQL*Plus)
PROMPT -- rman target sys/A#a12345678@orcle

PROMPT 
PROMPT -- 6.1 Check RMAN Configuration
PROMPT RMAN> SHOW ALL;
PROMPT Expected: CONTROLFILE AUTOBACKUP ON

PROMPT 
PROMPT -- 6.2 List Recent Backups
PROMPT RMAN> LIST BACKUP SUMMARY;
PROMPT Expected: At least one full backup

PROMPT 
PROMPT -- 6.3 Validate Last Backup
PROMPT RMAN> LIST BACKUP OF DATABASE;
PROMPT Expected: Backup pieces with status AVAILABLE

PROMPT 
PROMPT -- 6.4 Check Backup Integrity (من SQL*Plus)
PROMPT المستخدم: SYS
CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

SELECT 
    SESSION_KEY,
    INPUT_TYPE,
    STATUS,
    START_TIME,
    END_TIME,
    ELAPSED_SECONDS,
    INPUT_BYTES/1024/1024 AS INPUT_MB
FROM V$RMAN_BACKUP_JOB_DETAILS
WHERE START_TIME > SYSDATE - 7
ORDER BY START_TIME DESC;

PROMPT 
PROMPT -- 6.5 Verify Secure Deletion Procedure
PROMPT المستخدم: ECOM_OWNER
CONNECT ECOM_OWNER/EcomOwner#2024@ECOM_PDB

SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    CREATED,
    LAST_DDL_TIME
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'SECURE_DELETE_CUSTOMER'
  AND OBJECT_TYPE = 'PROCEDURE';


-- ============================================================================
--  CATEGORY 7: HARDENING & VULNERABILITY MANAGEMENT (10% - 1 mark)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [7] HARDENING & VULNERABILITY MANAGEMENT VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT -- 7.1 Verify Default Accounts are Locked
PROMPT Expected: SCOTT, HR, OE, SH should be LOCKED or EXPIRED & LOCKED
SELECT 
    USERNAME,
    ACCOUNT_STATUS,
    LOCK_DATE,
    EXPIRY_DATE
FROM DBA_USERS
WHERE USERNAME IN ('SCOTT', 'HR', 'OE', 'SH', 'OUTLN', 'DBSNMP')
ORDER BY USERNAME;

PROMPT 
PROMPT -- 7.2 Verify Dangerous PUBLIC Grants Revoked
PROMPT Expected: No dangerous packages granted to PUBLIC
SELECT 
    TABLE_NAME,
    PRIVILEGE,
    GRANTEE
FROM DBA_TAB_PRIVS
WHERE GRANTEE = 'PUBLIC'
  AND TABLE_NAME IN ('UTL_FILE', 'UTL_SMTP', 'DBMS_RANDOM', 'UTL_TCP')
ORDER BY TABLE_NAME;

PROMPT 
PROMPT -- 7.3 Verify Password Profile on DEFAULT
PROMPT Expected: FAILED_LOGIN_ATTEMPTS = 3
SELECT 
    PROFILE,
    RESOURCE_NAME,
    LIMIT
FROM DBA_PROFILES
WHERE PROFILE = 'DEFAULT'
  AND RESOURCE_NAME IN (
      'FAILED_LOGIN_ATTEMPTS',
      'PASSWORD_LOCK_TIME',
      'PASSWORD_LIFE_TIME'
  );

PROMPT 
PROMPT -- 7.4 Verify ARCHIVELOG Mode (Critical for Recovery)
PROMPT Expected: ARCHIVELOG
ALTER SESSION SET CONTAINER = CDB$ROOT;
SELECT LOG_MODE FROM V$DATABASE;

PROMPT 
PROMPT -- 7.5 Verify TDE Encryption (Hardening at Rest)
PROMPT Expected: At least one encrypted tablespace
ALTER SESSION SET CONTAINER = ECOM_PDB;
SELECT COUNT(*) AS ENCRYPTED_TABLESPACES
FROM DBA_TABLESPACES
WHERE ENCRYPTED = 'YES';


-- ============================================================================
--  CATEGORY 8: AUDITING & MONITORING (15% - 2 marks)
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [8] AUDITING & MONITORING VERIFICATION
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT -- 8.1 Verify Unified Audit Policies
PROMPT Expected: 5 policies (ECOM_LOGON_AUDIT, ECOM_DDL_AUDIT, etc.)
SELECT 
    POLICY_NAME,
    ENABLED_OPTION,
    USER_NAME,
    SUCCESS,
    FAILURE
FROM AUDIT_UNIFIED_ENABLED_POLICIES
WHERE POLICY_NAME LIKE 'ECOM%'
ORDER BY POLICY_NAME;

PROMPT 
PROMPT -- 8.2 Verify FGA Policies
PROMPT Expected: 4 FGA policies on sensitive columns
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    POLICY_NAME,
    POLICY_COLUMN,
    ENABLED,
    SEL,
    INS,
    UPD,
    DEL
FROM DBA_AUDIT_POLICIES
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, POLICY_NAME;

PROMPT 
PROMPT -- 8.3 Sample Audit Trail (Recent Activity)
PROMPT Expected: Login/logout and DML activity logged
SELECT 
    EVENT_TIMESTAMP,
    DBUSERNAME,
    ACTION_NAME,
    OBJECT_NAME,
    SQL_TEXT,
    RETURN_CODE
FROM UNIFIED_AUDIT_TRAIL
WHERE EVENT_TIMESTAMP > SYSDATE - 1
ORDER BY EVENT_TIMESTAMP DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT 
PROMPT -- 8.4 Sample FGA Audit Trail
PROMPT Expected: Access to sensitive columns logged
SELECT 
    TIMESTAMP,
    DB_USER,
    OBJECT_NAME,
    POLICY_NAME,
    SQL_TEXT
FROM DBA_FGA_AUDIT_TRAIL
WHERE TIMESTAMP > SYSDATE - 1
ORDER BY TIMESTAMP DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT 
PROMPT -- 8.5 Verify Alert System (Detection Rules)
PROMPT المستخدم: ECOM_OWNER
CONNECT ECOM_OWNER/EcomOwner#2024@ECOM_PDB

PROMPT Expected: Procedures for failed login, after-hours, bulk access detection
SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME IN (
    'CHECK_FAILED_LOGINS',
    'CHECK_AFTER_HOURS_ACCESS',
    'CHECK_SENSITIVE_DATA_ACCESS'
)
AND OBJECT_TYPE = 'PROCEDURE';

PROMPT 
PROMPT -- 8.6 Verify Security Alerts Table
PROMPT Expected: Table to store security alerts
SELECT 
    ALERT_TYPE,
    SEVERITY,
    COUNT(*) AS ALERT_COUNT
FROM SECURITY_ALERTS
WHERE ALERT_DATE > SYSDATE - 7
GROUP BY ALERT_TYPE, SEVERITY
ORDER BY SEVERITY DESC, ALERT_COUNT DESC;


-- ============================================================================
--  CATEGORY 9: FINAL DOCUMENTATION (10% - 1 mark)
--  المستخدم المطلوب: File System Check (Windows Explorer)
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  [9] FINAL DOCUMENTATION VERIFICATION
PROMPT  Required: Manual File System Check
PROMPT ========================================================================

PROMPT -- 9.1 Verify SQL Scripts Organization
PROMPT Expected Directory Structure:
PROMPT DB_Oracle/
PROMPT   ├── 00_RUN_GUIDE/
PROMPT   ├── 01_VALIDATION_QUERIES/
PROMPT   ├── 02_Database_Scripts/
PROMPT   │   ├── 01_Setup/ (4 files)
PROMPT   │   ├── 02_Schema_Objects/ (4 files)
PROMPT   │   ├── 03_Security_Implementation/ (5 files)
PROMPT   │   ├── 04_Privacy_Protection/ (4 files)
PROMPT   │   ├── 05_Audit_Monitoring/ (5 files)
PROMPT   │   ├── 06_Maintenance/ (3 files)
PROMPT   │   └── 07_Final_Compliance/ (6 files)
PROMPT 
PROMPT -- 9.2 Verify Documentation Files (Artifacts)
PROMPT Expected Files in: C:\Users\osama\.gemini\antigravity\brain\[conversation-id]\
PROMPT   - professional_report.md
PROMPT   - compliance_matrix.md
PROMPT   - completion_report.md
PROMPT   - final_security_report.md
PROMPT   - project_scenario.md
PROMPT   - rubric_evidence.md
PROMPT   - verification_commands.sql (this file)
PROMPT 
PROMPT -- 9.3 Count Total SQL Files
PROMPT المستخدم: SYS
CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT From Database (Executed Scripts):
SELECT 
    OWNER,
    COUNT(*) AS TOTAL_OBJECTS
FROM DBA_OBJECTS
WHERE OWNER = 'ECOM_OWNER'
GROUP BY OWNER;

PROMPT 
PROMPT -- 9.4 Verify User Guide Exists
PROMPT Expected: 03_User_Connection_Guide.txt with user credentials
PROMPT Location: 00_RUN_GUIDE/03_User_Connection_Guide.txt


-- ============================================================================
--  COMPREHENSIVE SUMMARY REPORT
--  المستخدم المطلوب: SYS AS SYSDBA
-- ============================================================================

PROMPT 
PROMPT ========================================================================
PROMPT  COMPREHENSIVE SUMMARY REPORT
PROMPT  Required User: SYS AS SYSDBA
PROMPT ========================================================================

CONNECT SYS/A#a12345678@ECOM_PDB AS SYSDBA

PROMPT -- Summary 1: Database Objects Count
SELECT 
    OWNER,
    OBJECT_TYPE,
    COUNT(*) AS COUNT
FROM DBA_OBJECTS
WHERE OWNER IN ('ECOM_OWNER', 'SEC_ADMIN')
GROUP BY OWNER, OBJECT_TYPE
ORDER BY OWNER, OBJECT_TYPE;

PROMPT 
PROMPT -- Summary 2: Security Features Count
SELECT 
    'VPD Policies' AS FEATURE,
    COUNT(*) AS COUNT
FROM DBA_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER'
UNION ALL
SELECT 
    'Redaction Policies',
    COUNT(*)
FROM REDACTION_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER'
UNION ALL
SELECT 
    'Audit Policies',
    COUNT(*)
FROM AUDIT_UNIFIED_ENABLED_POLICIES
WHERE POLICY_NAME LIKE 'ECOM%'
UNION ALL
SELECT 
    'FGA Policies',
    COUNT(*)
FROM DBA_AUDIT_POLICIES
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
UNION ALL
SELECT 
    'Encrypted Tablespaces',
    COUNT(*)
FROM DBA_TABLESPACES
WHERE ENCRYPTED = 'YES' AND TABLESPACE_NAME LIKE 'ECOM%';

PROMPT 
PROMPT -- Summary 3: User & Role Summary
SELECT 
    'Total Users' AS CATEGORY,
    COUNT(*) AS COUNT
FROM DBA_USERS
WHERE USERNAME LIKE 'ECOM_%' OR USERNAME IN ('SEC_ADMIN', 'AUDITOR', 'CS_AGENT', 'WAREHOUSE_STAFF', 'SALES_REP', 'REPORT_USER', 'APP_USER')
UNION ALL
SELECT 
    'Total Roles',
    COUNT(*)
FROM DBA_ROLES
WHERE ROLE LIKE 'ROLE_%'
UNION ALL
SELECT 
    'Total Profiles',
    COUNT(DISTINCT PROFILE)
FROM DBA_PROFILES
WHERE PROFILE LIKE 'ECOM%';

PROMPT 
PROMPT ========================================================================
PROMPT  VERIFICATION COMPLETE
PROMPT  النتيجة المتوقعة: 15/15 (100%)
PROMPT ========================================================================
PROMPT 
PROMPT ملاحظات نهائية:
PROMPT 1. تأكد من أخذ لقطات شاشة (Screenshots) لكل قسم
PROMPT 2. للتحقق من RMAN، استخدم CMD وليس SQL*Plus
PROMPT 3. راجع الملفات الوثائقية في مجلد Artifacts
PROMPT 4. تحقق من هيكل المجلدات يدوياً في File Explorer
PROMPT 
