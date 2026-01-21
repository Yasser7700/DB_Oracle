/*
================================================================================
    02_Create_Indexes.sql - ����� �������
    ���� ������� ����������� ����� Oracle 19c
================================================================================
    �����: ����� ������� ������ ���� �����������
    �������� �������: ECOM_OWNER
================================================================================
*/

PROMPT ========================================
PROMPT ����� �������
PROMPT ========================================

/*
================================================================================
    ����� ���� CATEGORIES
================================================================================
*/

CREATE INDEX IDX_CAT_NAME ON CATEGORIES(CATEGORY_NAME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CAT_PARENT ON CATEGORIES(PARENT_CATEGORY_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CAT_ACTIVE ON CATEGORIES(IS_ACTIVE)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� CATEGORIES

/*
================================================================================
    ����� ���� PRODUCTS
================================================================================
*/

CREATE INDEX IDX_PROD_CODE ON PRODUCTS(PRODUCT_CODE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PROD_NAME ON PRODUCTS(PRODUCT_NAME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PROD_CATEGORY ON PRODUCTS(CATEGORY_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PROD_ACTIVE ON PRODUCTS(IS_ACTIVE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PROD_FEATURED ON PRODUCTS(IS_FEATURED)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PROD_PRICE ON PRODUCTS(UNIT_PRICE)
    TABLESPACE ECOM_INDEX;

-- ���� ���� ����� �������
CREATE INDEX IDX_PROD_CAT_ACTIVE ON PRODUCTS(CATEGORY_ID, IS_ACTIVE)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� PRODUCTS

/*
================================================================================
    ����� ���� CUSTOMERS
================================================================================
*/

CREATE INDEX IDX_CUST_CODE ON CUSTOMERS(CUSTOMER_CODE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_EMAIL ON CUSTOMERS(EMAIL)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_PHONE ON CUSTOMERS(PHONE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_NAME ON CUSTOMERS(LAST_NAME, FIRST_NAME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_REG_DATE ON CUSTOMERS(REGISTRATION_DATE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_TIER ON CUSTOMERS(CUSTOMER_TIER)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_AGENT ON CUSTOMERS(ASSIGNED_AGENT)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_CUST_ACTIVE ON CUSTOMERS(IS_ACTIVE)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� CUSTOMERS

/*
================================================================================
    ����� ���� ADDRESSES
================================================================================
*/

CREATE INDEX IDX_ADDR_CUSTOMER ON ADDRESSES(CUSTOMER_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ADDR_TYPE ON ADDRESSES(ADDRESS_TYPE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ADDR_CITY ON ADDRESSES(CITY)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ADDR_DEFAULT ON ADDRESSES(CUSTOMER_ID, IS_DEFAULT)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� ADDRESSES

/*
================================================================================
    ����� ���� ORDERS
================================================================================
*/

CREATE INDEX IDX_ORD_NUMBER ON ORDERS(ORDER_NUMBER)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ORD_CUSTOMER ON ORDERS(CUSTOMER_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ORD_DATE ON ORDERS(ORDER_DATE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ORD_STATUS ON ORDERS(ORDER_STATUS)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ORD_PAY_STATUS ON ORDERS(PAYMENT_STATUS)
    TABLESPACE ECOM_INDEX;

-- ���� ���� ����������� �������
CREATE INDEX IDX_ORD_CUST_DATE ON ORDERS(CUSTOMER_ID, ORDER_DATE DESC)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ORD_STATUS_DATE ON ORDERS(ORDER_STATUS, ORDER_DATE)
    TABLESPACE ECOM_INDEX;

-- ���� ������
CREATE INDEX IDX_ORD_TRACKING ON ORDERS(TRACKING_NUMBER)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� ORDERS

/*
================================================================================
    ����� ���� ORDER_ITEMS
================================================================================
*/

CREATE INDEX IDX_ITEM_ORDER ON ORDER_ITEMS(ORDER_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_ITEM_PRODUCT ON ORDER_ITEMS(PRODUCT_ID)
    TABLESPACE ECOM_INDEX;

-- ���� ���� ��������
CREATE INDEX IDX_ITEM_ORD_PROD ON ORDER_ITEMS(ORDER_ID, PRODUCT_ID)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� ORDER_ITEMS

/*
================================================================================
    ����� ���� PAYMENTS
================================================================================
*/

CREATE INDEX IDX_PAY_ORDER ON PAYMENTS(ORDER_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PAY_DATE ON PAYMENTS(PAYMENT_DATE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PAY_STATUS ON PAYMENTS(STATUS)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PAY_METHOD ON PAYMENTS(PAYMENT_METHOD)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_PAY_TRANS ON PAYMENTS(TRANSACTION_ID)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� PAYMENTS

/*
================================================================================
    ����� ���� AUDIT_LOG
================================================================================
*/

CREATE INDEX IDX_AUDIT_TIME ON AUDIT_LOG(EVENT_TIMESTAMP)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_AUDIT_USER ON AUDIT_LOG(USERNAME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_AUDIT_ACTION ON AUDIT_LOG(ACTION_TYPE)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_AUDIT_TABLE ON AUDIT_LOG(TABLE_NAME)
    TABLESPACE ECOM_INDEX;

-- ���� ���� �����
CREATE INDEX IDX_AUDIT_USER_TIME ON AUDIT_LOG(USERNAME, EVENT_TIMESTAMP DESC)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� AUDIT_LOG

/*
================================================================================
    ����� ���� USER_SESSIONS
================================================================================
*/

CREATE INDEX IDX_SESS_CUSTOMER ON USER_SESSIONS(CUSTOMER_ID)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_SESS_TOKEN ON USER_SESSIONS(SESSION_TOKEN)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_SESS_LOGIN ON USER_SESSIONS(LOGIN_TIME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_SESS_ACTIVE ON USER_SESSIONS(IS_ACTIVE)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� USER_SESSIONS

/*
================================================================================
    ����� ���� SENSITIVE_DATA_ACCESS
================================================================================
*/

CREATE INDEX IDX_SDA_TIME ON SENSITIVE_DATA_ACCESS(ACCESS_TIMESTAMP)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_SDA_USER ON SENSITIVE_DATA_ACCESS(USERNAME)
    TABLESPACE ECOM_INDEX;

CREATE INDEX IDX_SDA_TABLE ON SENSITIVE_DATA_ACCESS(TABLE_NAME)
    TABLESPACE ECOM_INDEX;

PROMPT ? ����� SENSITIVE_DATA_ACCESS

/*
================================================================================
    ��� ������� �������
================================================================================
*/

PROMPT ========================================
PROMPT ������� �������:
PROMPT ========================================

SELECT 
    INDEX_NAME,
    TABLE_NAME,
    UNIQUENESS,
    STATUS,
    TABLESPACE_NAME
FROM USER_INDEXES
WHERE INDEX_NAME LIKE 'IDX_%'
ORDER BY TABLE_NAME, INDEX_NAME;

/*
================================================================================
    �������� �������
================================================================================
*/

-- ��� ���������� �������
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        OWNNAME => USER,
        OPTIONS => 'GATHER AUTO',
        ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE
    );
END;
/

PROMPT ========================================
PROMPT �� ����� ���� ������� �����
PROMPT ========================================

-- ����� �������
