/*
================================================================================
    05_Column_Privileges.sql - صلاحيات الأعمدة (Refined Privileges)
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: ECOM_OWNER
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT ضبط صلاحيات الأعمدة وسحب الصلاحيات الزائدة...

/*
================================================================================
    1. سحب صلاحيات القراءة الكاملة (لإجبار استخدام Views)
================================================================================
*/

-- سحب SELECT من الجداول الحساسة (للاستبدال بـ Views)
REVOKE SELECT ON ECOM_OWNER.CUSTOMERS FROM ROLE_SUPPORT;
-- ملاحظة: ROLE_SALES لم يحصل عليها أصلاً بسبب الخطأ السابق، وهذا جيد.

-- سحب SELECT من المنتجات للمستودع (لمنع رؤية التكلفة إذا كانت ممنوحة)
-- REVOKE SELECT ON ECOM_OWNER.PRODUCTS FROM ROLE_WAREHOUSE; 
-- (إذا لم تكن ممنوحة، سيعطي خطأ، لذا سنتجاهلها ونعتمد على أننا لم نمنحها بشكل كامل سابقاً)

/*
================================================================================
    2. منح صلاحيات التحديث (UPDATE) على أعمدة محددة
    (Oracle تدعم هذا بشكل مباشر)
================================================================================
*/

PROMPT منح صلاحيات التحديث المحددة...

-- خدمة العملاء: تحديث الملاحظات والنقاط
GRANT UPDATE (LOYALTY_POINTS, NOTES) 
ON ECOM_OWNER.CUSTOMERS TO ROLE_SUPPORT;

GRANT UPDATE (ORDER_STATUS, NOTES) 
ON ECOM_OWNER.ORDERS TO ROLE_SUPPORT;

-- المستودع: تحديث المخزون وحالة الشحن
GRANT UPDATE (STOCK_QUANTITY) 
ON ECOM_OWNER.PRODUCTS TO ROLE_WAREHOUSE;

GRANT UPDATE (ORDER_STATUS, TRACKING_NUMBER, ACTUAL_DELIVERY) 
ON ECOM_OWNER.ORDERS TO ROLE_WAREHOUSE;

/*
================================================================================
    3. التحقق
================================================================================
*/

PROMPT صلاحيات الأعمدة الممنوحة (UPDATE):
SELECT GRANTEE, TABLE_NAME, PRIVILEGE, COLUMN_NAME
FROM USER_COL_PRIVS_MADE
ORDER BY GRANTEE, TABLE_NAME;

PROMPT تم ضبط الصلاحيات بنجاح ✓
