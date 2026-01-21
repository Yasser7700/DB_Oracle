/*
================================================================================
    01_Static_Masking.sql - «·≈Œ›«¡ «·À«» 
    ‰Ÿ«„ «· Ã«—… «·≈·ﬂ —Ê‰Ì… «·¬„‰ Oracle 19c
================================================================================
    «·Ê’›: ≈Œ›«¡ œ«∆„ ··»Ì«‰«  ›Ì »Ì∆… «·«Œ »«—
    «·„” Œœ„ «·„ÿ·Ê»: ECOM_OWNER
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT ≈‰‘«¡ ≈Ã—«¡«  «·≈Œ›«¡ «·À«» ...

BEGIN
    -- Õ–› «·ÃœÊ· ≈–« ﬂ«‰ „ÊÃÊœ« · Ã‰» «·√Œÿ«¡ ⁄‰œ ≈⁄«œ… «· ‘€Ì·
    EXECUTE IMMEDIATE 'DROP TABLE ECOM_OWNER.CUSTOMERS_MASKED PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

/*
================================================================================
    1. ≈‰‘«¡ ÃœÊ· «·‰”Œ… «·„Œ›Ì… (ÂÌﬂ· ›ﬁÿ)
================================================================================
*/

-- ‰”Œ «·ÂÌﬂ· ›ﬁÿ (»œÊ‰ »Ì«‰« ) · Ã‰» „‘«ﬂ· √‰Ê«⁄ «·»Ì«‰«  √À‰«¡ «·≈‰‘«¡
CREATE TABLE ECOM_OWNER.CUSTOMERS_MASKED AS
SELECT * FROM ECOM_OWNER.CUSTOMERS WHERE 1=0;

PROMPT ?  „ ≈‰‘«¡ ÂÌﬂ· «·ÃœÊ· CUSTOMERS_MASKED

/*
================================================================================
    2. ≈Ã—«¡ «·≈Œ›«¡ «·À«» 
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.STATIC_MASK_DATA AS
BEGIN
    --  ‰ŸÌ› «·ÃœÊ· «·Âœ›
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ECOM_OWNER.CUSTOMERS_MASKED';
    
    -- ≈œ—«Ã «·»Ì«‰«  «·„Œ›Ì…
    INSERT INTO ECOM_OWNER.CUSTOMERS_MASKED (
        CUSTOMER_ID, CUSTOMER_CODE, FIRST_NAME, LAST_NAME, EMAIL,
        PHONE, PHONE_SECONDARY, DATE_OF_BIRTH, GENDER, NATIONAL_ID,
        PASSWORD_HASH, REGISTRATION_DATE, LAST_LOGIN, IS_ACTIVE,
        IS_VERIFIED, LOYALTY_POINTS, CUSTOMER_TIER, ASSIGNED_AGENT,
        NOTES, CREATED_DATE, UPDATED_DATE
    )
    SELECT 
        CUSTOMER_ID,
        CUSTOMER_CODE,
        -- ≈Œ›«¡ «·«”„ «·√Ê·
        CASE 
            WHEN LENGTH(FIRST_NAME) > 2 THEN SUBSTR(FIRST_NAME,1,2) || RPAD('*', LENGTH(FIRST_NAME)-2, '*')
            ELSE '**'
        END,
        -- ≈Œ›«¡ «”„ «·⁄«∆·…
        SUBSTR(LAST_NAME,1,1) || RPAD('*', LENGTH(LAST_NAME)-1, '*'),
        -- ≈Œ›«¡ «·»—Ìœ (ﬁœ Ì‰ Ã  ﬂ—«— Ê·ﬂ‰ «·ÃœÊ· «·„Œ›Ì ·« Ì„·ﬂ Unique Constraints ⁄«œ…)
        SUBSTR(EMAIL,1,2) || '****@' || SUBSTR(EMAIL, INSTR(EMAIL,'@')+1),
        -- ≈Œ›«¡ «·Â« ›
        SUBSTR(PHONE,1,3) || '****' || SUBSTR(PHONE,-3),
        PHONE_SECONDARY,
        -- ≈Œ›«¡  «—ÌŒ «·„Ì·«œ
        TRUNC(DATE_OF_BIRTH, 'YEAR'),
        GENDER,
        -- ≈Œ›«¡ «·ÂÊÃ… «·Êÿ‰Ì…
        'XXXX****' || SUBSTR(NATIONAL_ID,-4),
        -- ≈Œ›«¡ ﬂ·„… «·„—Ê—
        '*****HASHED*****',
        REGISTRATION_DATE,
        LAST_LOGIN,
        IS_ACTIVE,
        IS_VERIFIED,
        LOYALTY_POINTS,
        CUSTOMER_TIER,
        ASSIGNED_AGENT,
        -- «·„·«ÕŸ«  ›«—€…
        NULL,
        CREATED_DATE,
        UPDATED_DATE
    FROM ECOM_OWNER.CUSTOMERS;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Static masking completed: ' || SQL%ROWCOUNT || ' rows');
END;
/

PROMPT ?  „ ≈‰‘«¡ «·≈Ã—«¡ STATIC_MASK_DATA

/*
================================================================================
    3.  ‰›Ì– «·≈Œ›«¡ «·√Ê·Ì
================================================================================
*/

BEGIN
    ECOM_OWNER.STATIC_MASK_DATA;
END;
/

/*
================================================================================
    4. œÊ«· «·≈Œ›«¡ «·„”«⁄œ… (··«” Œœ«„ «·„” ﬁ»·Ì)
================================================================================
*/

CREATE OR REPLACE FUNCTION ECOM_OWNER.MASK_EMAIL(p_email VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    IF p_email IS NULL THEN RETURN NULL; END IF;
    RETURN SUBSTR(p_email,1,2) || '****@' || SUBSTR(p_email, INSTR(p_email,'@')+1);
END;
/

CREATE OR REPLACE FUNCTION ECOM_OWNER.MASK_PHONE(p_phone VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    IF p_phone IS NULL OR LENGTH(p_phone) < 7 THEN RETURN '***'; END IF;
    RETURN SUBSTR(p_phone,1,3) || '****' || SUBSTR(p_phone,-3);
END;
/

CREATE OR REPLACE FUNCTION ECOM_OWNER.MASK_NAME(p_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    IF p_name IS NULL OR LENGTH(p_name) < 2 THEN RETURN '**'; END IF;
    RETURN SUBSTR(p_name,1,1) || RPAD('*', LENGTH(p_name)-1, '*');
END;
/

CREATE OR REPLACE FUNCTION ECOM_OWNER.MASK_NATIONAL_ID(p_id VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    IF p_id IS NULL OR LENGTH(p_id) < 4 THEN RETURN 'XXXX'; END IF;
    RETURN 'XXXX****' || SUBSTR(p_id,-4);
END;
/

PROMPT  „ ≈‰‘«¡ Ê ‰›Ì– ≈Ã—«¡«  «·≈Œ›«¡ «·À«»  ?
