/*
================================================================================
    02_FGA_Policies.sql - التدقيق الدقيق (Fine Grained Auditing)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء سياسات التدقيق الدقيق (FGA)...

/*
================================================================================
    1. FGA للوصول لرقم الهوية الوطنية
================================================================================
*/

BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'CUSTOMERS',
        policy_name     => 'FGA_NATIONAL_ID_ACCESS',
        audit_condition => 'NATIONAL_ID IS NOT NULL',
        audit_column    => 'NATIONAL_ID',
        statement_types => 'SELECT,UPDATE',
        enable          => TRUE
    );
END;
/

PROMPT ✓ FGA لرقم الهوية

/*
================================================================================
    2. FGA للوصول للبريد الإلكتروني
================================================================================
*/

BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'CUSTOMERS',
        policy_name     => 'FGA_EMAIL_ACCESS',
        audit_column    => 'EMAIL',
        statement_types => 'SELECT',
        enable          => TRUE
    );
END;
/

PROMPT ✓ FGA للبريد الإلكتروني

/*
================================================================================
    3. FGA للوصول لبيانات المدفوعات
================================================================================
*/

BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'PAYMENTS',
        policy_name     => 'FGA_PAYMENT_ACCESS',
        audit_column    => 'CARD_TOKEN,AMOUNT',
        statement_types => 'SELECT,UPDATE',
        enable          => TRUE
    );
END;
/

PROMPT ✓ FGA للمدفوعات

/*
================================================================================
    4. FGA لتحديث الطلبات ذات القيمة العالية
================================================================================
*/

BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'ORDERS',
        policy_name     => 'FGA_HIGH_VALUE_ORDERS',
        audit_condition => 'TOTAL_AMOUNT > 10000',
        audit_column    => 'ORDER_STATUS,TOTAL_AMOUNT',
        statement_types => 'SELECT,UPDATE,DELETE',
        enable          => TRUE
    );
END;
/

PROMPT ✓ FGA للطلبات عالية القيمة

/*
================================================================================
    5. عرض سياسات FGA
================================================================================
*/

PROMPT ========================================
PROMPT سياسات التدقيق الدقيق:
PROMPT ========================================

SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    POLICY_NAME,
    POLICY_COLUMN,
    ENABLED
FROM DBA_AUDIT_POLICIES
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
ORDER BY OBJECT_NAME, POLICY_NAME;

/*
================================================================================
    6. استعلام عرض سجلات FGA
================================================================================
*/

PROMPT ========================================
PROMPT استعلام عرض سجلات FGA:
PROMPT ========================================

-- يمكن استخدامه لعرض السجلات لاحقاً
/*
SELECT 
    TIMESTAMP,
    DB_USER,
    OS_USER,
    USERHOST,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    POLICY_NAME,
    SQL_TEXT
FROM DBA_FGA_AUDIT_TRAIL
WHERE OBJECT_SCHEMA = 'ECOM_OWNER'
ORDER BY TIMESTAMP DESC;
*/

PROMPT تم إنشاء سياسات FGA ✓
