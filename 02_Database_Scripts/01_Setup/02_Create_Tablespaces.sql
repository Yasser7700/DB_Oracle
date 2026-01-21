-- ========================================
-- ملف: 02_Create_Tablespaces.sql
-- الغرض: إنشاء مساحات التخزين للنظام
-- المستخدم المطلوب: SYS as SYSDBA
-- المتطلبات: PDB ECOM_PDB موجودة ومفتوحة
-- ========================================

-- التأكد من الاتصال بـ ECOM_PDB
ALTER SESSION SET CONTAINER = ECOM_PDB;

-- التحقق من الحاوية الحالية
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS CURRENT_CONTAINER FROM DUAL;

PROMPT ========================================
PROMPT Creating Tablespaces for ECOM_PDB
PROMPT ========================================

-- إنشاء Tablespace للبيانات الرئيسية
PROMPT Creating ECOM_DATA Tablespace...

CREATE TABLESPACE ECOM_DATA
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_data01.dbf'
    SIZE 500M
    AUTOEXTEND ON
    NEXT 100M
    MAXSIZE 5G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ECOM_DATA tablespace created successfully.

-- إنشاء Tablespace للفهارس
PROMPT Creating ECOM_INDEX Tablespace...

CREATE TABLESPACE ECOM_INDEX
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_index01.dbf'
    SIZE 200M
    AUTOEXTEND ON
    NEXT 50M
    MAXSIZE 2G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ECOM_INDEX tablespace created successfully.

-- إنشاء Tablespace للتدقيق
PROMPT Creating ECOM_AUDIT Tablespace...

CREATE TABLESPACE ECOM_AUDIT
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_audit01.dbf'
    SIZE 100M
    AUTOEXTEND ON
    NEXT 50M
    MAXSIZE 1G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ECOM_AUDIT tablespace created successfully.

-- إنشاء Tablespace للأرشيف
PROMPT Creating ECOM_ARCHIVE Tablespace...

CREATE TABLESPACE ECOM_ARCHIVE
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_archive01.dbf'
    SIZE 200M
    AUTOEXTEND ON
    NEXT 100M
    MAXSIZE 3G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ECOM_ARCHIVE tablespace created successfully.

-- إنشاء Tablespace مؤقت
PROMPT Creating ECOM_TEMP Temporary Tablespace...

CREATE TEMPORARY TABLESPACE ECOM_TEMP
    TEMPFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_temp01.dbf'
    SIZE 100M
    AUTOEXTEND ON
    NEXT 50M
    MAXSIZE 1G;

PROMPT ECOM_TEMP temporary tablespace created successfully.

-- إنشاء Tablespace للبيانات الحساسة/المشفرة
PROMPT Creating ECOM_SECURE Tablespace...

CREATE TABLESPACE ECOM_SECURE
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_secure01.dbf'
    SIZE 100M
    AUTOEXTEND ON
    NEXT 50M
    MAXSIZE 1G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ECOM_SECURE tablespace created successfully.

PROMPT ========================================
PROMPT Verification - All Tablespaces
PROMPT ========================================

-- التحقق من إنشاء جميع Tablespaces
SELECT TABLESPACE_NAME, STATUS, CONTENTS, EXTENT_MANAGEMENT
FROM DBA_TABLESPACES
WHERE TABLESPACE_NAME LIKE 'ECOM%'
ORDER BY TABLESPACE_NAME;

-- التحقق من ملفات البيانات
SELECT TABLESPACE_NAME, FILE_NAME, 
       ROUND(BYTES/1024/1024) AS SIZE_MB,
       AUTOEXTENSIBLE
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME LIKE 'ECOM%'
ORDER BY TABLESPACE_NAME;

PROMPT ========================================
PROMPT All Tablespaces Created Successfully
PROMPT ========================================
