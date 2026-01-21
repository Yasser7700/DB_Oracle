/*
================================================================================
    01_Create_Tables.sql - إنشاء الجداول الرئيسية
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    الوصف: إنشاء جميع جداول النظام مع العلاقات والقيود
    المستخدم المطلوب: ECOM_OWNER
    المتطلبات: المستخدم والـ Tablespaces موجودة
================================================================================
*/

-- التأكد من الاتصال بالمستخدم الصحيح
SELECT USER, SYS_CONTEXT('USERENV', 'CON_NAME') AS PDB FROM DUAL;

PROMPT ========================================
PROMPT إنشاء الجداول الرئيسية
PROMPT ========================================

/*
================================================================================
    جدول 1: CATEGORIES - الفئات/التصنيفات
================================================================================
*/

CREATE TABLE CATEGORIES (
    CATEGORY_ID         NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CATEGORY_NAME       VARCHAR2(100)       NOT NULL,
    CATEGORY_NAME_AR    VARCHAR2(100),
    DESCRIPTION         VARCHAR2(500),
    PARENT_CATEGORY_ID  NUMBER(10),
    IS_ACTIVE           CHAR(1)             DEFAULT 'Y' CHECK (IS_ACTIVE IN ('Y', 'N')),
    DISPLAY_ORDER       NUMBER(5)           DEFAULT 0,
    CREATED_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_DATE        TIMESTAMP,
    CONSTRAINT FK_CATEGORY_PARENT 
        FOREIGN KEY (PARENT_CATEGORY_ID) REFERENCES CATEGORIES(CATEGORY_ID)
)
TABLESPACE ECOM_DATA;

COMMENT ON TABLE CATEGORIES IS 'جدول فئات المنتجات';
COMMENT ON COLUMN CATEGORIES.CATEGORY_ID IS 'المعرف الفريد للفئة';
COMMENT ON COLUMN CATEGORIES.CATEGORY_NAME IS 'اسم الفئة بالإنجليزية';
COMMENT ON COLUMN CATEGORIES.CATEGORY_NAME_AR IS 'اسم الفئة بالعربية';

PROMPT ✓ تم إنشاء جدول CATEGORIES

/*
================================================================================
    جدول 2: PRODUCTS - المنتجات
================================================================================
*/

CREATE TABLE PRODUCTS (
    PRODUCT_ID          NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PRODUCT_CODE        VARCHAR2(50)        NOT NULL UNIQUE,
    PRODUCT_NAME        VARCHAR2(200)       NOT NULL,
    PRODUCT_NAME_AR     VARCHAR2(200),
    DESCRIPTION         CLOB,
    CATEGORY_ID         NUMBER(10)          NOT NULL,
    UNIT_PRICE          NUMBER(12,2)        NOT NULL CHECK (UNIT_PRICE >= 0),
    COST_PRICE          NUMBER(12,2)        CHECK (COST_PRICE >= 0),
    STOCK_QUANTITY      NUMBER(10)          DEFAULT 0 CHECK (STOCK_QUANTITY >= 0),
    REORDER_LEVEL       NUMBER(10)          DEFAULT 10,
    WEIGHT_KG           NUMBER(8,3),
    IS_ACTIVE           CHAR(1)             DEFAULT 'Y' CHECK (IS_ACTIVE IN ('Y', 'N')),
    IS_FEATURED         CHAR(1)             DEFAULT 'N' CHECK (IS_FEATURED IN ('Y', 'N')),
    IMAGE_URL           VARCHAR2(500),
    CREATED_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_DATE        TIMESTAMP,
    CREATED_BY          VARCHAR2(50)        DEFAULT USER,
    CONSTRAINT FK_PRODUCT_CATEGORY 
        FOREIGN KEY (CATEGORY_ID) REFERENCES CATEGORIES(CATEGORY_ID)
)
TABLESPACE ECOM_DATA;

COMMENT ON TABLE PRODUCTS IS 'جدول المنتجات الرئيسي';
COMMENT ON COLUMN PRODUCTS.COST_PRICE IS 'سعر التكلفة - بيانات حساسة';

PROMPT ✓ تم إنشاء جدول PRODUCTS

/*
================================================================================
    جدول 3: CUSTOMERS - العملاء
================================================================================
*/

CREATE TABLE CUSTOMERS (
    CUSTOMER_ID         NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CUSTOMER_CODE       VARCHAR2(20)        NOT NULL UNIQUE,
    FIRST_NAME          VARCHAR2(50)        NOT NULL,
    LAST_NAME           VARCHAR2(50)        NOT NULL,
    EMAIL               VARCHAR2(150)       NOT NULL UNIQUE,
    PHONE               VARCHAR2(20),
    PHONE_SECONDARY     VARCHAR2(20),
    DATE_OF_BIRTH       DATE,
    GENDER              CHAR(1)             CHECK (GENDER IN ('M', 'F')),
    NATIONAL_ID         VARCHAR2(20),       -- بيانات حساسة جداً
    PASSWORD_HASH       VARCHAR2(256)       NOT NULL,
    REGISTRATION_DATE   TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_LOGIN          TIMESTAMP,
    IS_ACTIVE           CHAR(1)             DEFAULT 'Y' CHECK (IS_ACTIVE IN ('Y', 'N')),
    IS_VERIFIED         CHAR(1)             DEFAULT 'N' CHECK (IS_VERIFIED IN ('Y', 'N')),
    LOYALTY_POINTS      NUMBER(10)          DEFAULT 0,
    CUSTOMER_TIER       VARCHAR2(20)        DEFAULT 'BRONZE' 
                        CHECK (CUSTOMER_TIER IN ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM')),
    ASSIGNED_AGENT      VARCHAR2(50),
    NOTES               CLOB,
    CREATED_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_DATE        TIMESTAMP
)
TABLESPACE ECOM_SECURE;

COMMENT ON TABLE CUSTOMERS IS 'جدول العملاء - يحتوي بيانات شخصية حساسة';
COMMENT ON COLUMN CUSTOMERS.NATIONAL_ID IS 'رقم الهوية الوطنية - محمي بالإخفاء';
COMMENT ON COLUMN CUSTOMERS.EMAIL IS 'البريد الإلكتروني - بيانات شخصية';
COMMENT ON COLUMN CUSTOMERS.PASSWORD_HASH IS 'تجزئة كلمة المرور - لا يتم عرضها أبداً';

PROMPT ✓ تم إنشاء جدول CUSTOMERS

/*
================================================================================
    جدول 4: ADDRESSES - العناوين
================================================================================
*/

CREATE TABLE ADDRESSES (
    ADDRESS_ID          NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CUSTOMER_ID         NUMBER(10)          NOT NULL,
    ADDRESS_TYPE        VARCHAR2(20)        DEFAULT 'SHIPPING' 
                        CHECK (ADDRESS_TYPE IN ('SHIPPING', 'BILLING', 'BOTH')),
    ADDRESS_LINE1       VARCHAR2(200)       NOT NULL,
    ADDRESS_LINE2       VARCHAR2(200),
    CITY                VARCHAR2(100)       NOT NULL,
    STATE_PROVINCE      VARCHAR2(100),
    POSTAL_CODE         VARCHAR2(20),
    COUNTRY             VARCHAR2(100)       DEFAULT 'Saudi Arabia',
    IS_DEFAULT          CHAR(1)             DEFAULT 'N' CHECK (IS_DEFAULT IN ('Y', 'N')),
    PHONE               VARCHAR2(20),
    RECIPIENT_NAME      VARCHAR2(100),
    DELIVERY_NOTES      VARCHAR2(500),
    CREATED_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    UPDATED_DATE        TIMESTAMP,
    CONSTRAINT FK_ADDRESS_CUSTOMER 
        FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID) ON DELETE CASCADE
)
TABLESPACE ECOM_DATA;

COMMENT ON TABLE ADDRESSES IS 'جدول عناوين العملاء';

PROMPT ✓ تم إنشاء جدول ADDRESSES

/*
================================================================================
    جدول 5: ORDERS - الطلبات
================================================================================
*/

CREATE TABLE ORDERS (
    ORDER_ID            NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ORDER_NUMBER        VARCHAR2(30)        NOT NULL UNIQUE,
    CUSTOMER_ID         NUMBER(10)          NOT NULL,
    ORDER_DATE          TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    ORDER_STATUS        VARCHAR2(30)        DEFAULT 'PENDING'
                        CHECK (ORDER_STATUS IN ('PENDING', 'CONFIRMED', 'PROCESSING', 
                               'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED')),
    PAYMENT_STATUS      VARCHAR2(20)        DEFAULT 'PENDING'
                        CHECK (PAYMENT_STATUS IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    SUBTOTAL            NUMBER(12,2)        NOT NULL CHECK (SUBTOTAL >= 0),
    DISCOUNT_AMOUNT     NUMBER(12,2)        DEFAULT 0 CHECK (DISCOUNT_AMOUNT >= 0),
    TAX_AMOUNT          NUMBER(12,2)        DEFAULT 0 CHECK (TAX_AMOUNT >= 0),
    SHIPPING_AMOUNT     NUMBER(12,2)        DEFAULT 0 CHECK (SHIPPING_AMOUNT >= 0),
    TOTAL_AMOUNT        NUMBER(12,2)        NOT NULL CHECK (TOTAL_AMOUNT >= 0),
    SHIPPING_ADDRESS_ID NUMBER(10),
    BILLING_ADDRESS_ID  NUMBER(10),
    SHIPPING_METHOD     VARCHAR2(50),
    TRACKING_NUMBER     VARCHAR2(100),
    ESTIMATED_DELIVERY  DATE,
    ACTUAL_DELIVERY     DATE,
    NOTES               CLOB,
    COUPON_CODE         VARCHAR2(50),
    CREATED_BY          VARCHAR2(50)        DEFAULT USER,
    UPDATED_DATE        TIMESTAMP,
    CONSTRAINT FK_ORDER_CUSTOMER 
        FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID),
    CONSTRAINT FK_ORDER_SHIP_ADDR 
        FOREIGN KEY (SHIPPING_ADDRESS_ID) REFERENCES ADDRESSES(ADDRESS_ID),
    CONSTRAINT FK_ORDER_BILL_ADDR 
        FOREIGN KEY (BILLING_ADDRESS_ID) REFERENCES ADDRESSES(ADDRESS_ID)
)
TABLESPACE ECOM_DATA;

COMMENT ON TABLE ORDERS IS 'جدول الطلبات الرئيسي';

-- إنشاء trigger لتوليد رقم الطلب تلقائياً
CREATE OR REPLACE TRIGGER TRG_ORDER_NUMBER
BEFORE INSERT ON ORDERS
FOR EACH ROW
WHEN (NEW.ORDER_NUMBER IS NULL)
BEGIN
    :NEW.ORDER_NUMBER := 'ORD-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || 
                         LPAD(ORDERS_SEQ.NEXTVAL, 6, '0');
EXCEPTION
    WHEN OTHERS THEN
        :NEW.ORDER_NUMBER := 'ORD-' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
END;
/

-- إنشاء sequence للطلبات
CREATE SEQUENCE ORDERS_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

PROMPT ✓ تم إنشاء جدول ORDERS

/*
================================================================================
    جدول 6: ORDER_ITEMS - عناصر الطلبات
================================================================================
*/

CREATE TABLE ORDER_ITEMS (
    ITEM_ID             NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ORDER_ID            NUMBER(10)          NOT NULL,
    PRODUCT_ID          NUMBER(10)          NOT NULL,
    QUANTITY            NUMBER(10)          NOT NULL CHECK (QUANTITY > 0),
    UNIT_PRICE          NUMBER(12,2)        NOT NULL CHECK (UNIT_PRICE >= 0),
    DISCOUNT_PERCENT    NUMBER(5,2)         DEFAULT 0 CHECK (DISCOUNT_PERCENT >= 0 AND DISCOUNT_PERCENT <= 100),
    LINE_TOTAL          NUMBER(12,2)        NOT NULL CHECK (LINE_TOTAL >= 0),
    NOTES               VARCHAR2(500),
    CONSTRAINT FK_ITEM_ORDER 
        FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID) ON DELETE CASCADE,
    CONSTRAINT FK_ITEM_PRODUCT 
        FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
)
TABLESPACE ECOM_DATA;

COMMENT ON TABLE ORDER_ITEMS IS 'جدول تفاصيل الطلبات';

-- إنشاء trigger لحساب المجموع تلقائياً
CREATE OR REPLACE TRIGGER TRG_CALC_LINE_TOTAL
BEFORE INSERT OR UPDATE ON ORDER_ITEMS
FOR EACH ROW
BEGIN
    :NEW.LINE_TOTAL := :NEW.QUANTITY * :NEW.UNIT_PRICE * (1 - :NEW.DISCOUNT_PERCENT / 100);
END;
/

PROMPT ✓ تم إنشاء جدول ORDER_ITEMS

/*
================================================================================
    جدول 7: PAYMENTS - المدفوعات
================================================================================
*/

CREATE TABLE PAYMENTS (
    PAYMENT_ID          NUMBER(10)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ORDER_ID            NUMBER(10)          NOT NULL,
    PAYMENT_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    PAYMENT_METHOD      VARCHAR2(50)        NOT NULL
                        CHECK (PAYMENT_METHOD IN ('CREDIT_CARD', 'DEBIT_CARD', 'BANK_TRANSFER', 
                               'CASH_ON_DELIVERY', 'WALLET', 'MADA', 'APPLE_PAY')),
    AMOUNT              NUMBER(12,2)        NOT NULL CHECK (AMOUNT > 0),
    CURRENCY            VARCHAR2(3)         DEFAULT 'SAR',
    TRANSACTION_ID      VARCHAR2(100),
    CARD_LAST_FOUR      VARCHAR2(4),        -- آخر 4 أرقام فقط
    CARD_TOKEN          VARCHAR2(256),      -- التوكن بدلاً من رقم البطاقة الكامل
    STATUS              VARCHAR2(20)        DEFAULT 'PENDING'
                        CHECK (STATUS IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED')),
    GATEWAY_RESPONSE    CLOB,
    NOTES               VARCHAR2(500),
    CREATED_DATE        TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT FK_PAYMENT_ORDER 
        FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID)
)
TABLESPACE ECOM_SECURE;

COMMENT ON TABLE PAYMENTS IS 'جدول المدفوعات - بيانات مالية حساسة';
COMMENT ON COLUMN PAYMENTS.CARD_TOKEN IS 'توكن البطاقة - لا يتم تخزين رقم البطاقة الكامل';

PROMPT ✓ تم إنشاء جدول PAYMENTS

/*
================================================================================
    جدول 8: AUDIT_LOG - سجل التدقيق المخصص
================================================================================
*/

CREATE TABLE AUDIT_LOG (
    LOG_ID              NUMBER(15)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EVENT_TIMESTAMP     TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    USERNAME            VARCHAR2(50)        NOT NULL,
    IP_ADDRESS          VARCHAR2(50),
    SESSION_ID          NUMBER,
    ACTION_TYPE         VARCHAR2(50)        NOT NULL,
    TABLE_NAME          VARCHAR2(100),
    RECORD_ID           VARCHAR2(100),
    OLD_VALUES          CLOB,
    NEW_VALUES          CLOB,
    DESCRIPTION         VARCHAR2(1000),
    STATUS              VARCHAR2(20)        DEFAULT 'SUCCESS' CHECK (STATUS IN ('SUCCESS', 'FAILED')),
    ERROR_MESSAGE       VARCHAR2(2000)
)
TABLESPACE ECOM_AUDIT;

COMMENT ON TABLE AUDIT_LOG IS 'سجل التدقيق المخصص للعمليات الحساسة';

PROMPT ✓ تم إنشاء جدول AUDIT_LOG

/*
================================================================================
    جدول 9: USER_SESSIONS - جلسات المستخدمين
================================================================================
*/

CREATE TABLE USER_SESSIONS (
    SESSION_ID          NUMBER(15)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CUSTOMER_ID         NUMBER(10),
    APP_USER            VARCHAR2(50),
    SESSION_TOKEN       VARCHAR2(256)       NOT NULL,
    LOGIN_TIME          TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    LOGOUT_TIME         TIMESTAMP,
    IP_ADDRESS          VARCHAR2(50),
    USER_AGENT          VARCHAR2(500),
    IS_ACTIVE           CHAR(1)             DEFAULT 'Y' CHECK (IS_ACTIVE IN ('Y', 'N')),
    LAST_ACTIVITY       TIMESTAMP           DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_SESSION_CUSTOMER 
        FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID)
)
TABLESPACE ECOM_AUDIT;

COMMENT ON TABLE USER_SESSIONS IS 'سجل جلسات المستخدمين للمراقبة الأمنية';

PROMPT ✓ تم إنشاء جدول USER_SESSIONS

/*
================================================================================
    جدول 10: SENSITIVE_DATA_ACCESS - سجل الوصول للبيانات الحساسة
================================================================================
*/

CREATE TABLE SENSITIVE_DATA_ACCESS (
    ACCESS_ID           NUMBER(15)          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ACCESS_TIMESTAMP    TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    USERNAME            VARCHAR2(50)        NOT NULL,
    TABLE_NAME          VARCHAR2(100)       NOT NULL,
    COLUMN_NAME         VARCHAR2(100),
    RECORD_ID           VARCHAR2(100),
    ACCESS_TYPE         VARCHAR2(20)        CHECK (ACCESS_TYPE IN ('READ', 'WRITE', 'DELETE')),
    PURPOSE             VARCHAR2(500),
    IP_ADDRESS          VARCHAR2(50),
    WAS_MASKED          CHAR(1)             DEFAULT 'N' CHECK (WAS_MASKED IN ('Y', 'N'))
)
TABLESPACE ECOM_AUDIT;

COMMENT ON TABLE SENSITIVE_DATA_ACCESS IS 'سجل الوصول للبيانات الحساسة حسب GDPR';

PROMPT ✓ تم إنشاء جدول SENSITIVE_DATA_ACCESS

/*
================================================================================
    التحقق من الجداول المنشأة
================================================================================
*/

PROMPT ========================================
PROMPT الجداول المنشأة:
PROMPT ========================================

SELECT 
    TABLE_NAME,
    TABLESPACE_NAME,
    NUM_ROWS,
    STATUS
FROM USER_TABLES
ORDER BY TABLE_NAME;

PROMPT ========================================
PROMPT العلاقات (Foreign Keys):
PROMPT ========================================

SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    R_CONSTRAINT_NAME AS "REFERENCES"
FROM USER_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'R'
ORDER BY TABLE_NAME;

PROMPT ========================================
PROMPT تم الانتهاء من إنشاء جميع الجداول بنجاح
PROMPT ========================================

-- نهاية السكربتياسؤيت
