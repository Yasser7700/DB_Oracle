/*
================================================================================
    04_Access_Views.sql - «·⁄—Ê÷ «·„ﬁÌœ…
    ‰Ÿ«„ «· Ã«—… «·≈·ﬂ —Ê‰Ì… «·¬„‰ Oracle 19c
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT ≈‰‘«¡ «·⁄—Ê÷ «·„ﬁÌœ…...

/*
================================================================================
    1. ⁄—÷ «·⁄„·«¡ ·Œœ„… «·⁄„·«¡ (»œÊ‰ »Ì«‰«  Õ”«”…)
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_CUSTOMERS_SUPPORT AS
SELECT 
    CUSTOMER_ID,
    CUSTOMER_CODE,
    FIRST_NAME,
    SUBSTR(LAST_NAME, 1, 1) || '***' AS LAST_NAME,
    REGEXP_REPLACE(EMAIL, '(.{2})(.*)(@.*)', '\1****\3') AS EMAIL_MASKED,
    SUBSTR(PHONE, 1, 4) || '****' || SUBSTR(PHONE, -2) AS PHONE_MASKED,
    CUSTOMER_TIER,
    LOYALTY_POINTS,
    REGISTRATION_DATE,
    IS_ACTIVE
FROM ECOM_OWNER.CUSTOMERS;

GRANT SELECT ON ECOM_OWNER.V_CUSTOMERS_SUPPORT TO ROLE_SUPPORT;

/*
================================================================================
    2. ⁄—÷ «·⁄„·«¡ ·· ﬁ«—Ì— (»Ì«‰«  „Ã„⁄…)
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_CUSTOMERS_REPORT AS
SELECT 
    CUSTOMER_ID,
    CUSTOMER_TIER,
    LOYALTY_POINTS,
    REGISTRATION_DATE,
    IS_ACTIVE,
    CASE WHEN EMAIL LIKE '%@gmail.com' THEN 'Gmail' 
         WHEN EMAIL LIKE '%@yahoo.com' THEN 'Yahoo'
         ELSE 'Other' END AS EMAIL_PROVIDER
FROM ECOM_OWNER.CUSTOMERS;

GRANT SELECT ON ECOM_OWNER.V_CUSTOMERS_REPORT TO ROLE_READONLY;

/*
================================================================================
    3. ⁄—÷ «·ÿ·»«  ··„»Ì⁄« 
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_ORDERS_SALES AS
SELECT 
    O.ORDER_ID,
    O.ORDER_NUMBER,
    O.ORDER_DATE,
    O.ORDER_STATUS,
    O.TOTAL_AMOUNT,
    C.FIRST_NAME || ' ' || SUBSTR(C.LAST_NAME,1,1) || '.' AS CUSTOMER_NAME
FROM ECOM_OWNER.ORDERS O
JOIN ECOM_OWNER.CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID;

GRANT SELECT ON ECOM_OWNER.V_ORDERS_SALES TO ROLE_SALES;

/*
================================================================================
    4. ⁄—÷ «·ÿ·»«  ··„” Êœ⁄
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_ORDERS_WAREHOUSE AS
SELECT 
    O.ORDER_ID,
    O.ORDER_NUMBER,
    O.ORDER_STATUS,
    O.TRACKING_NUMBER,
    O.ESTIMATED_DELIVERY,
    A.CITY,
    A.STATE_PROVINCE,
    A.RECIPIENT_NAME
FROM ECOM_OWNER.ORDERS O
LEFT JOIN ECOM_OWNER.ADDRESSES A ON O.SHIPPING_ADDRESS_ID = A.ADDRESS_ID
WHERE O.ORDER_STATUS IN ('CONFIRMED', 'PROCESSING', 'SHIPPED');

GRANT SELECT ON ECOM_OWNER.V_ORDERS_WAREHOUSE TO ROLE_WAREHOUSE;

/*
================================================================================
    5. ⁄—÷ «·„‰ Ã«  ··„»Ì⁄«  (»œÊ‰ ”⁄— «· ﬂ·›…)
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_PRODUCTS_PUBLIC AS
SELECT 
    PRODUCT_ID,
    PRODUCT_CODE,
    PRODUCT_NAME,
    PRODUCT_NAME_AR,
    CATEGORY_ID,
    UNIT_PRICE,
    STOCK_QUANTITY,
    IS_ACTIVE,
    IS_FEATURED
FROM ECOM_OWNER.PRODUCTS;

GRANT SELECT ON ECOM_OWNER.V_PRODUCTS_PUBLIC TO ROLE_SALES, ROLE_SUPPORT, ROLE_READONLY, ROLE_WAREHOUSE;

/*
================================================================================
    6. ⁄—÷ ·ÊÕ… «·„⁄·Ê„«  «·≈œ«—Ì…
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_DASHBOARD AS
SELECT 
    (SELECT COUNT(*) FROM CUSTOMERS WHERE IS_ACTIVE='Y') AS ACTIVE_CUSTOMERS,
    (SELECT COUNT(*) FROM PRODUCTS WHERE IS_ACTIVE='Y') AS ACTIVE_PRODUCTS,
    (SELECT COUNT(*) FROM ORDERS WHERE ORDER_DATE > SYSDATE-30) AS ORDERS_LAST_30_DAYS,
    (SELECT SUM(TOTAL_AMOUNT) FROM ORDERS WHERE ORDER_DATE > SYSDATE-30 AND PAYMENT_STATUS='PAID') AS REVENUE_LAST_30_DAYS,
    (SELECT COUNT(*) FROM ORDERS WHERE ORDER_STATUS='PENDING') AS PENDING_ORDERS
FROM DUAL;

GRANT SELECT ON ECOM_OWNER.V_DASHBOARD TO ROLE_ADMIN;

PROMPT  „ ≈‰‘«¡ «·⁄—Ê÷ «·„ﬁÌœ… ?
