/*
================================================================================
    03_Secure_Deletion.sql - المسح الآمن للبيانات (Secure Deletion)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: ECOM_OWNER
    المتطلب: Lab 8 - Backup & Recovery (Secure Deletion)
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء إجراء المسح الآمن...

CREATE OR REPLACE PROCEDURE ECOM_OWNER.SECURE_DELETE_CUSTOMER (
    p_customer_id NUMBER
) AS
    v_dummy_char CHAR(100) := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
BEGIN
    -- 1. الكتابة فوق البيانات (Overwriting) ببيانات عشوائية أو ثابتة عدة مرات
    -- الدورة الأولى: مسح بالصفر
    UPDATE ECOM_OWNER.CUSTOMERS
    SET FIRST_NAME = '00000',
        LAST_NAME = '00000',
        EMAIL = '00000',
        PHONE = '00000',
        NATIONAL_ID = '00000'
    WHERE CUSTOMER_ID = p_customer_id;
    
    COMMIT; -- تثبيت الكتابة في القرص
    
    -- الدورة الثانية: مسح ببيانات عشوائية
    UPDATE ECOM_OWNER.CUSTOMERS
    SET FIRST_NAME = dbms_random.string('A', 10),
        LAST_NAME = dbms_random.string('A', 10),
        EMAIL = dbms_random.string('X', 20),
        NATIONAL_ID = dbms_random.string('U', 10)
    WHERE CUSTOMER_ID = p_customer_id;
    
    COMMIT;
    
    -- 2. الحذف النهائي للبيانات
    DELETE FROM ECOM_OWNER.CUSTOMERS
    WHERE CUSTOMER_ID = p_customer_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Customer ' || p_customer_id || ' data has been securely overwritten and deleted.');
END;
/


PROMPT تم إنشاء إجراء SECURE_DELETE_CUSTOMER بنجاح ✓
