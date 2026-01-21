/*
================================================================================
    02_Dynamic_Masking.sql - الإخفاء الديناميكي (Data Redaction)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء سياسات الإخفاء الديناميكي...

/*
================================================================================
    تنظيف السياسات القديمة (Robust Cleanup)
    نستخدم كتل منفصلة لضمان محاولة حذف كل سياسة، حتى لو فشلت الأخرى
================================================================================
*/

-- 1. السياسات المجمعة (الجديدة)
BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'REDACT_CUSTOMERS');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'PAYMENTS', 'REDACT_PAYMENTS');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 2. السياسات الفردية (القديمة)
BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'REDACT_CUSTOMER_EMAIL');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'REDACT_CUSTOMER_PHONE');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'REDACT_NATIONAL_ID');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'REDACT_DOB');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    DBMS_REDACT.DROP_POLICY('ECOM_OWNER', 'PAYMENTS', 'REDACT_CARD_DIGITS');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

PROMPT تم تنظيف السياسات القديمة.

/*
================================================================================
    1. سياسة العملاء (مجمعة)
================================================================================
*/

-- 1.1 إنشاء السياسة مع العمود الأول (البريد الإلكتروني)
BEGIN
    DBMS_REDACT.ADD_POLICY(
        object_schema  => 'ECOM_OWNER',
        object_name    => 'CUSTOMERS',
        policy_name    => 'REDACT_CUSTOMERS',
        column_name    => 'EMAIL',
        function_type  => DBMS_REDACT.REGEXP,
        regexp_pattern => '(.{2})(.*)(@.*)',
        regexp_replace_string => '\1****\3',
        expression     => 'SYS_CONTEXT(''ECOM_CTX'',''USER_ROLE'') NOT IN (''ADMIN'',''SECURITY'')'
    );
END;
/

-- 1.2 إضافة عمود الهاتف
BEGIN
    DBMS_REDACT.ALTER_POLICY(
        object_schema  => 'ECOM_OWNER',
        object_name    => 'CUSTOMERS',
        policy_name    => 'REDACT_CUSTOMERS',
        action         => DBMS_REDACT.ADD_COLUMN,
        column_name    => 'PHONE',
        function_type  => DBMS_REDACT.REGEXP,
        regexp_pattern => '(.{3})(.*)(.{3})',
        regexp_replace_string => '\1****\3',
        expression     => 'SYS_CONTEXT(''ECOM_CTX'',''USER_ROLE'') NOT IN (''ADMIN'',''SECURITY'',''SUPPORT'')'
    );
END;
/

-- 1.3 إضافة عمود الهوية الوطنية
BEGIN
    DBMS_REDACT.ALTER_POLICY(
        object_schema  => 'ECOM_OWNER',
        object_name    => 'CUSTOMERS',
        policy_name    => 'REDACT_CUSTOMERS',
        action         => DBMS_REDACT.ADD_COLUMN,
        column_name    => 'NATIONAL_ID',
        function_type  => DBMS_REDACT.FULL,
        expression     => 'SYS_CONTEXT(''ECOM_CTX'',''USER_ROLE'') != ''ADMIN'''
    );
END;
/

-- 1.4 إضافة عمود تاريخ الميلاد
BEGIN
    DBMS_REDACT.ALTER_POLICY(
        object_schema  => 'ECOM_OWNER',
        object_name    => 'CUSTOMERS',
        policy_name    => 'REDACT_CUSTOMERS',
        action         => DBMS_REDACT.ADD_COLUMN,
        column_name    => 'DATE_OF_BIRTH',
        function_type  => DBMS_REDACT.FULL,
        expression     => 'SYS_CONTEXT(''ECOM_CTX'',''USER_ROLE'') NOT IN (''ADMIN'',''SECURITY'')'
    );
END;
/

/*
================================================================================
    2. سياسة المدفوعات (مجمعة)
================================================================================
*/
BEGIN
    DBMS_REDACT.ADD_POLICY(
        object_schema  => 'ECOM_OWNER',
        object_name    => 'PAYMENTS',
        policy_name    => 'REDACT_PAYMENTS',
        column_name    => 'CARD_LAST_FOUR',
        function_type  => DBMS_REDACT.FULL,
        expression     => 'SYS_CONTEXT(''ECOM_CTX'',''USER_ROLE'') NOT IN (''ADMIN'',''SECURITY'',''AUDIT'')'
    );
END;
/

/*
================================================================================
    3. التحقق
================================================================================
*/

PROMPT السياسات المفعلة:
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_NAME, ENABLE
FROM REDACTION_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER';

PROMPT الأعمدة المخفية:
SELECT OBJECT_NAME, COLUMN_NAME, FUNCTION_TYPE 
FROM REDACTION_COLUMNS 
WHERE OBJECT_OWNER = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, COLUMN_NAME;

PROMPT تم إنشاء سياسات الإخفاء الديناميكي بنجاح ✓
