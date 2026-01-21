-- =========================================================
-- ملف: 04_Fix_Quota.sql
-- الغرض: منح صلاحية الكتابة في ECOM_AUDIT للمستخدم ECOM_OWNER
-- المستخدم المطلوب: SYS as SYSDBA
-- =========================================================

-- التأكد من الاتصال بـ ECOM_PDB
ALTER SESSION SET CONTAINER = ECOM_PDB;

-- منح الحصة (Quota)
ALTER USER ECOM_OWNER QUOTA UNLIMITED ON ECOM_AUDIT;

PROMPT ✓ تم منح صلاحية الكتابة في ECOM_AUDIT بنجاح
