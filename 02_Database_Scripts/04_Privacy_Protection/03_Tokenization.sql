/*
================================================================================
    03_Tokenization.sql - التوكنة (Tokenization)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: ECOM_OWNER
    المتطلبات المسبقة: يجب تنفيذ الأمر التالي بواسطة SYS:
    GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ECOM_OWNER;
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء نظام التوكنة...

/*
================================================================================
    1. جدول خريطة التوكنات (Token Vault)
================================================================================
*/

BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE TOKEN_VAULT (
        TOKEN_ID        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        TOKEN_VALUE     VARCHAR2(64) NOT NULL UNIQUE,
        DATA_TYPE       VARCHAR2(50) NOT NULL,
        ORIGINAL_HASH   VARCHAR2(256) NOT NULL,
        CREATED_DATE    TIMESTAMP DEFAULT SYSTIMESTAMP,
        EXPIRES_DATE    TIMESTAMP,
        IS_ACTIVE       CHAR(1) DEFAULT ''Y'' CHECK (IS_ACTIVE IN (''Y'',''N''))
    ) TABLESPACE ECOM_SECURE';
    
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_TOKEN_VALUE ON TOKEN_VAULT(TOKEN_VALUE)';
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_TOKEN_HASH ON TOKEN_VAULT(ORIGINAL_HASH)';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL; -- الجدول موجود
        ELSE RAISE;
        END IF;
END;
/

/*
================================================================================
    2. دوال التوكنة
================================================================================
*/

-- توليد توكن عشوائي
CREATE OR REPLACE FUNCTION GENERATE_TOKEN RETURN VARCHAR2 IS
    v_token RAW(32);
BEGIN
    v_token := DBMS_CRYPTO.RANDOMBYTES(32);
    RETURN 'TOK_' || RAWTOHEX(v_token);
END;
/

-- توكنة قيمة
CREATE OR REPLACE FUNCTION TOKENIZE_VALUE(
    p_value IN VARCHAR2,
    p_data_type IN VARCHAR2 DEFAULT 'GENERAL'
) RETURN VARCHAR2 IS
    v_hash VARCHAR2(256);
    v_token VARCHAR2(64);
BEGIN
    IF p_value IS NULL THEN RETURN NULL; END IF;
    
    -- حساب تجزئة القيمة
    v_hash := RAWTOHEX(DBMS_CRYPTO.HASH(
        UTL_RAW.CAST_TO_RAW(p_value),
        DBMS_CRYPTO.HASH_SH256
    ));
    
    -- البحث عن توكن موجود
    BEGIN
        SELECT TOKEN_VALUE INTO v_token
        FROM TOKEN_VAULT
        WHERE ORIGINAL_HASH = v_hash AND DATA_TYPE = p_data_type AND IS_ACTIVE = 'Y';
        RETURN v_token;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- إنشاء توكن جديد
            v_token := GENERATE_TOKEN();
            INSERT INTO TOKEN_VAULT (TOKEN_VALUE, DATA_TYPE, ORIGINAL_HASH)
            VALUES (v_token, p_data_type, v_hash);
            -- (نلاحظ: لا نقوم بـ COMMIT هنا لأن الدالة قد تُستدعى ضمن معاملة أكبر)
            RETURN v_token;
    END;
END;
/

/*
================================================================================
    3. توكنة بيانات البطاقات في جدول المدفوعات
================================================================================
*/

-- Trigger لتوكنة البطاقات تلقائياً
CREATE OR REPLACE TRIGGER TRG_TOKENIZE_CARD
BEFORE INSERT OR UPDATE ON PAYMENTS
FOR EACH ROW
BEGIN
    IF :NEW.CARD_TOKEN IS NULL AND :NEW.CARD_LAST_FOUR IS NOT NULL THEN
        -- نستخدم التوكنة لتوليد رمز فريد بناء على الرقم (لأغراض المثال)
        :NEW.CARD_TOKEN := TOKENIZE_VALUE(:NEW.CARD_LAST_FOUR, 'CARD');
    END IF;
END;
/

PROMPT تم إنشاء نظام التوكنة بنجاح ✓
PROMPT تأكد من منح صلاحية DBMS_CRYPTO للمستخدم ECOM_OWNER اذا ظهرت أخطاء.



SELECT table_name
FROM user_tables
WHERE table_name LIKE '%CARD%';

