/*
================================================================================
    02_Password_Profiles.sql - سياسات كلمات المرور
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    المستخدم المطلوب: SYS AS SYSDBA
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء سياسات كلمات المرور...

/*
================================================================================
    1. دالة التحقق من تعقيد كلمة المرور
================================================================================
*/

CREATE OR REPLACE FUNCTION ECOM_PWD_VERIFY (
    username     VARCHAR2,
    password     VARCHAR2,
    old_password VARCHAR2
) RETURN BOOLEAN IS
    n BOOLEAN;
    differ INTEGER;
BEGIN
    -- الحد الأدنى للطول: 12 حرف
    IF LENGTH(password) < 12 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Password must be at least 12 characters');
    END IF;
    
    -- يجب أن تحتوي على حرف كبير
    IF NOT REGEXP_LIKE(password, '[A-Z]') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Password must contain uppercase letter');
    END IF;
    
    -- يجب أن تحتوي على حرف صغير
    IF NOT REGEXP_LIKE(password, '[a-z]') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Password must contain lowercase letter');
    END IF;
    
    -- يجب أن تحتوي على رقم
    IF NOT REGEXP_LIKE(password, '[0-9]') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Password must contain a digit');
    END IF;
    
    -- يجب أن تحتوي على رمز خاص
    IF NOT REGEXP_LIKE(password, '[!@#$%^&*()_+]') THEN
        RAISE_APPLICATION_ERROR(-20005, 'Password must contain special character');
    END IF;
    
    -- لا يمكن أن تكون مطابقة لاسم المستخدم
    IF UPPER(password) = UPPER(username) THEN
        RAISE_APPLICATION_ERROR(-20006, 'Password cannot be same as username');
    END IF;
    
    -- يجب أن تختلف عن كلمة المرور السابقة بـ 4 أحرف على الأقل
    IF old_password IS NOT NULL THEN
        differ := 0;
        FOR i IN 1..LEAST(LENGTH(password), LENGTH(old_password)) LOOP
            IF SUBSTR(password, i, 1) != SUBSTR(old_password, i, 1) THEN
                differ := differ + 1;
            END IF;
        END LOOP;
        IF differ < 4 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Password must differ from old password by 4 chars');
        END IF;
    END IF;
    
    RETURN TRUE;
END;
/

/*
================================================================================
    2. ملفات التعريف (Profiles)
================================================================================
*/

-- ملف تعريف المسؤولين (صارم جداً)
CREATE PROFILE ECOM_ADMIN_PROFILE LIMIT
    PASSWORD_LIFE_TIME 60
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_TIME 365
    PASSWORD_REUSE_MAX 12
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1/24
    PASSWORD_VERIFY_FUNCTION ECOM_PWD_VERIFY
    SESSIONS_PER_USER 3
    IDLE_TIME 15;

-- ملف تعريف الموظفين
CREATE PROFILE ECOM_STAFF_PROFILE LIMIT
    PASSWORD_LIFE_TIME 90
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_TIME 180
    PASSWORD_REUSE_MAX 6
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1/48
    PASSWORD_VERIFY_FUNCTION ECOM_PWD_VERIFY
    SESSIONS_PER_USER 5
    IDLE_TIME 30;

-- ملف تعريف التطبيقات
CREATE PROFILE ECOM_APP_PROFILE LIMIT
    PASSWORD_LIFE_TIME 180
    PASSWORD_GRACE_TIME 14
    PASSWORD_REUSE_TIME 90
    PASSWORD_REUSE_MAX 4
    FAILED_LOGIN_ATTEMPTS 10
    PASSWORD_LOCK_TIME 1/96
    SESSIONS_PER_USER UNLIMITED
    IDLE_TIME UNLIMITED;

/*
================================================================================
    3. تعيين الملفات للمستخدمين
================================================================================
*/

ALTER USER ECOM_OWNER PROFILE ECOM_ADMIN_PROFILE;
ALTER USER SEC_ADMIN PROFILE ECOM_ADMIN_PROFILE;
ALTER USER ECOM_MANAGER PROFILE ECOM_ADMIN_PROFILE;
ALTER USER CS_AGENT PROFILE ECOM_STAFF_PROFILE;
ALTER USER WAREHOUSE_STAFF PROFILE ECOM_STAFF_PROFILE;
ALTER USER SALES_REP PROFILE ECOM_STAFF_PROFILE;
ALTER USER AUDITOR PROFILE ECOM_STAFF_PROFILE;
ALTER USER REPORT_USER PROFILE ECOM_STAFF_PROFILE;
ALTER USER APP_USER PROFILE ECOM_APP_PROFILE;

/*
================================================================================
    4. التحقق
================================================================================
*/

PROMPT الملفات المنشأة:
SELECT PROFILE, RESOURCE_NAME, LIMIT
FROM DBA_PROFILES
WHERE PROFILE LIKE 'ECOM_%'
AND RESOURCE_TYPE = 'PASSWORD'
ORDER BY PROFILE, RESOURCE_NAME;

PROMPT تم إنشاء سياسات كلمات المرور ✓
