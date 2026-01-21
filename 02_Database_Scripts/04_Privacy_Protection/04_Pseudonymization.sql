/*
================================================================================
    04_Pseudonymization.sql - إزالة التعريف
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    الوصف: إنتاج بيانات مجهولة الهوية للتقارير والتحليل
    المستخدم المطلوب: ECOM_OWNER
    المتطلبات المسبقة: يجب تنفيذ الأمر التالي بواسطة SYS (إن لم يتم سابقاً):
    GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ECOM_OWNER;
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء نظام إزالة التعريف...

/*
================================================================================
    1. جدول البيانات المجهولة
================================================================================
*/

CREATE TABLE ECOM_OWNER.CUSTOMERS_ANONYMOUS (
    ANONYMOUS_ID    VARCHAR2(50) PRIMARY KEY,
    AGE_GROUP       VARCHAR2(20),
    GENDER          CHAR(1),
    CITY_REGION     VARCHAR2(50),
    CUSTOMER_TIER   VARCHAR2(20),
    SIGNUP_YEAR     NUMBER(4),
    ORDER_COUNT     NUMBER,
    TOTAL_SPENT     NUMBER(12,2),
    LAST_UPDATE     TIMESTAMP DEFAULT SYSTIMESTAMP
) TABLESPACE ECOM_DATA;

/*
================================================================================
    2. دالة توليد معرف مجهول
================================================================================
*/

CREATE OR REPLACE FUNCTION ECOM_OWNER.GENERATE_ANONYMOUS_ID(p_customer_id NUMBER) RETURN VARCHAR2 IS
    v_hash RAW(32);
    v_salt VARCHAR2(50) := 'ECOM_ANON_SALT_2024';
BEGIN
    v_hash := DBMS_CRYPTO.HASH(
        UTL_RAW.CAST_TO_RAW(p_customer_id || v_salt),
        DBMS_CRYPTO.HASH_SH256
    );
    RETURN 'ANON_' || SUBSTR(RAWTOHEX(v_hash), 1, 16);
END;
/

/*
================================================================================
    3. دالة تحديد الفئة العمرية
================================================================================
*/

CREATE OR REPLACE FUNCTION ECOM_OWNER.GET_AGE_GROUP(p_dob DATE) RETURN VARCHAR2 IS
    v_age NUMBER;
BEGIN
    IF p_dob IS NULL THEN RETURN 'UNKNOWN'; END IF;
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    
    RETURN CASE
        WHEN v_age < 18 THEN 'Under 18'
        WHEN v_age BETWEEN 18 AND 24 THEN '18-24'
        WHEN v_age BETWEEN 25 AND 34 THEN '25-34'
        WHEN v_age BETWEEN 35 AND 44 THEN '35-44'
        WHEN v_age BETWEEN 45 AND 54 THEN '45-54'
        WHEN v_age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END;
END;
/

/*
================================================================================
    4. إجراء إنتاج البيانات المجهولة
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.GENERATE_ANONYMOUS_DATA AS
BEGIN
    DELETE FROM CUSTOMERS_ANONYMOUS;
    
    INSERT INTO CUSTOMERS_ANONYMOUS (ANONYMOUS_ID, AGE_GROUP, GENDER, CITY_REGION, CUSTOMER_TIER, SIGNUP_YEAR, ORDER_COUNT, TOTAL_SPENT)
    SELECT 
        ECOM_OWNER.GENERATE_ANONYMOUS_ID(C.CUSTOMER_ID),
        ECOM_OWNER.GET_AGE_GROUP(C.DATE_OF_BIRTH),
        C.GENDER,
        COALESCE((SELECT CITY FROM ADDRESSES WHERE CUSTOMER_ID = C.CUSTOMER_ID AND IS_DEFAULT = 'Y' AND ROWNUM = 1), 'Unknown'),
        C.CUSTOMER_TIER,
        EXTRACT(YEAR FROM C.REGISTRATION_DATE),
        (SELECT COUNT(*) FROM ORDERS WHERE CUSTOMER_ID = C.CUSTOMER_ID),
        (SELECT NVL(SUM(TOTAL_AMOUNT), 0) FROM ORDERS WHERE CUSTOMER_ID = C.CUSTOMER_ID AND PAYMENT_STATUS = 'PAID')
    FROM CUSTOMERS C
    WHERE C.IS_ACTIVE = 'Y';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Generated ' || SQL%ROWCOUNT || ' anonymous records');
END;
/

/*
================================================================================
    5. عرض البيانات المجهولة للتحليل
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_ANALYTICS_DATA AS
SELECT 
    AGE_GROUP,
    GENDER,
    CITY_REGION,
    CUSTOMER_TIER,
    SIGNUP_YEAR,
    AVG(ORDER_COUNT) AS AVG_ORDERS,
    AVG(TOTAL_SPENT) AS AVG_SPENT
FROM CUSTOMERS_ANONYMOUS
GROUP BY AGE_GROUP, GENDER, CITY_REGION, CUSTOMER_TIER, SIGNUP_YEAR;

GRANT SELECT ON ECOM_OWNER.V_ANALYTICS_DATA TO ROLE_READONLY;

/*
================================================================================
    6. تشغيل أولي
================================================================================
*/

BEGIN
    ECOM_OWNER.GENERATE_ANONYMOUS_DATA;
END;
/
PROMPT تم إنشاء نظام إزالة التعريف ✓
