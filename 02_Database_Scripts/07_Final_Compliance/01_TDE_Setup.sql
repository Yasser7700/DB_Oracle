/*
================================================================================
    01_TDE_Setup.sql - إعداد التشفير (TDE) - Pure SQL Version
    نظام التجارة الإلكترونية الآمن Oracle 19c
    المستخدم المطلوب: SYS AS SYSDBA
================================================================================
    ملاحظة: إذا ظهر خطأ "Wallet already exists" في أول أمر، فتجاهله واستمر.
================================================================================
*/

-- 1. الانتقال إلى الجذر (Root)
ALTER SESSION SET CONTAINER = CDB$ROOT;

PROMPT [Step 1] Creating Keystore in Root...
-- محاولة إنشاء المحفظة (إذا كانت موجودة مسبقاً سيظهر خطأ، يمكن تجاهله)
ADMINISTER KEY MANAGEMENT CREATE KEYSTORE 'C:\Oracle\WALLET' IDENTIFIED BY "Oracle#Wallet123";

PROMPT [Step 2] Opening Keystore...
-- فتح المحفظة
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "Oracle#Wallet123" CONTAINER=ALL;

PROMPT [Step 3] Setting Master Key...
-- تعيين المفتاح الرئيسي
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "Oracle#Wallet123" WITH BACKUP CONTAINER=CURRENT;


-- 2. الانتقال إلى PDB
ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT [Step 4] Configuring PDB...
-- فتح المحفظة في PDB (قد تكون مفتوحة تلقائياً)
ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "Oracle#Wallet123" CONTAINER=CURRENT;

PROMPT [Step 5] Setting PDB Master Key...
-- تعيين المفتاح الخاص لـ PDB
ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "Oracle#Wallet123" WITH BACKUP CONTAINER=CURRENT;

PROMPT [Step 6] Creating Encrypted Tablespace...
-- حذف الـ Tablespace القديم إذا وجد (لإعادة الإنشاء)
DROP TABLESPACE ECOM_ENCRYPTED INCLUDING CONTENTS AND DATAFILES;

-- إنشاء الـ Tablespace الجديد
CREATE TABLESPACE ECOM_ENCRYPTED
    DATAFILE 'C:\ORACLE\ORADATA\ORCLE\ECOM_PDB\ECOM_ENCRYPTED01.DBF' SIZE 100M AUTOEXTEND ON NEXT 10M
    ENCRYPTION USING 'AES256' DEFAULT STORAGE(ENCRYPT);

PROMPT تم إعداد TDE وإنشاء الـ Tablespace المشفر بنجاح! ✓
