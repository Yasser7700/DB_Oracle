-- ========================================
-- ملف: 01_Create_PDB.sql
-- الغرض: إنشاء قاعدة بيانات Pluggable جديدة
-- المستخدم المطلوب: SYS as SYSDBA
-- ========================================

-- تغيير الجلسة لـ CDB
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- التحقق من قواعد البيانات الحالية
SELECT NAME, CDB, CON_ID FROM V$DATABASE;
SELECT PDB_ID, PDB_NAME, STATUS FROM CDB_PDBS ORDER BY PDB_ID;

PROMPT ========================================
PROMPT Creating Pluggable Database: ECOM_PDB
PROMPT ========================================

-- إنشاء PDB جديد من PDB$SEED
CREATE PLUGGABLE DATABASE ECOM_PDB
   ADMIN USER ECOM_PDB_ADMIN IDENTIFIED BY "EcomPdbAdmin#2024"
   ROLES = (DBA)
   DEFAULT TABLESPACE USERS
   DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ecom_pdb01.dbf' 
       SIZE 500M AUTOEXTEND ON NEXT 100M MAXSIZE 5G
   FILE_NAME_CONVERT = (
       'C:\ORACLE\ORADATA\ORCLE\PDBSEED\',
       'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\'
   );

PROMPT ========================================
PROMPT Opening PDB and Saving State
PROMPT ========================================

-- فتح PDB الجديدة
ALTER PLUGGABLE DATABASE ECOM_PDB OPEN;

-- حفظ حالة PDB 
ALTER PLUGGABLE DATABASE ECOM_PDB SAVE STATE;

PROMPT ========================================
PROMPT Verification Queries
PROMPT ========================================

-- التحقق من حالة PDB
SELECT PDB_ID, PDB_NAME, STATUS, CON_ID
FROM CDB_PDBS 
WHERE PDB_NAME = 'ECOM_PDB';

-- التحقق من الخدمات المتاحة
SELECT NAME, PDB FROM V$SERVICES WHERE PDB = 'ECOM_PDB';

PROMPT ========================================
PROMPT ECOM_PDB Created Successfully
PROMPT Admin User: ECOM_PDB_ADMIN
PROMPT ========================================
