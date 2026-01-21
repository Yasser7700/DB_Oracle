/*
================================================================================
    04_Alert_Procedures.sql - إجراءات التنبيه
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
    User: SYS AS SYSDBA
    ملاحظة: يتم التنفيذ بواسطة SYS لضمان صلاحيات إنشاء Jobs
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء إجراءات التنبيه (بواسطة SYS)...

/*
================================================================================
    1. جدول التنبيهات (في مخطط ECOM_OWNER)
================================================================================
*/

-- التحقق من وجود الجدول وحذفه إذا لزم الأمر (للتنظيف)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM DBA_TABLES WHERE OWNER = 'ECOM_OWNER' AND TABLE_NAME = 'SECURITY_ALERTS';
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE ECOM_OWNER.SECURITY_ALERTS PURGE';
    END IF;
END;
/

CREATE TABLE ECOM_OWNER.SECURITY_ALERTS (
    ALERT_ID        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ALERT_TYPE      VARCHAR2(50) NOT NULL,
    SEVERITY        VARCHAR2(20) CHECK (SEVERITY IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    USERNAME        VARCHAR2(50),
    DESCRIPTION     VARCHAR2(2000),
    DETAILS         CLOB,
    ALERT_TIME      TIMESTAMP DEFAULT SYSTIMESTAMP,
    IS_RESOLVED     CHAR(1) DEFAULT 'N',
    RESOLVED_BY     VARCHAR2(50),
    RESOLVED_TIME   TIMESTAMP
) TABLESPACE ECOM_AUDIT;

/*
================================================================================
    2. إجراء تسجيل التنبيه
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.LOG_SECURITY_ALERT (
    p_type      VARCHAR2,
    p_severity  VARCHAR2,
    p_username  VARCHAR2,
    p_desc      VARCHAR2,
    p_details   CLOB DEFAULT NULL
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO ECOM_OWNER.SECURITY_ALERTS (ALERT_TYPE, SEVERITY, USERNAME, DESCRIPTION, DETAILS)
    VALUES (p_type, p_severity, p_username, p_desc, p_details);
    COMMIT;
END;
/

/*
================================================================================
    3. مراقبة محاولات الدخول الفاشلة
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.CHECK_FAILED_LOGINS AS
BEGIN
    FOR rec IN (
        SELECT DBUSERNAME, COUNT(*) AS FAILS
        FROM AUDSYS.UNIFIED_AUDIT_TRAIL -- استخدام الجدول مباشرة (SYS يراه)
        WHERE ACTION_NAME = 'LOGON'
        AND RETURN_CODE != 0
        AND EVENT_TIMESTAMP > SYSTIMESTAMP - INTERVAL '1' HOUR
        GROUP BY DBUSERNAME
        HAVING COUNT(*) >= 3
    ) LOOP
        ECOM_OWNER.LOG_SECURITY_ALERT(
            'FAILED_LOGIN',
            'HIGH',
            rec.DBUSERNAME,
            'Multiple failed logins: ' || rec.FAILS || ' in last hour'
        );
    END LOOP;
END;
/

/*
================================================================================
    4. مراقبة الوصول خارج ساعات العمل
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.CHECK_AFTERHOURS_ACCESS AS
BEGIN
    FOR rec IN (
        SELECT DBUSERNAME, COUNT(*) AS ACTIONS
        FROM AUDSYS.UNIFIED_AUDIT_TRAIL
        WHERE (TO_NUMBER(TO_CHAR(EVENT_TIMESTAMP, 'HH24')) < 7 
           OR TO_NUMBER(TO_CHAR(EVENT_TIMESTAMP, 'HH24')) >= 22)
        AND EVENT_TIMESTAMP > SYSTIMESTAMP - INTERVAL '1' DAY
        AND ACTION_NAME NOT IN ('LOGON', 'LOGOFF')
        GROUP BY DBUSERNAME
        HAVING COUNT(*) > 10
    ) LOOP
        ECOM_OWNER.LOG_SECURITY_ALERT(
            'AFTERHOURS_ACCESS',
            'MEDIUM',
            rec.DBUSERNAME,
            'Significant activity outside business hours: ' || rec.ACTIONS || ' actions'
        );
    END LOOP;
END;
/

/*
================================================================================
    5. مراقبة الوصول للبيانات الحساسة
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.CHECK_SENSITIVE_ACCESS AS
BEGIN
    FOR rec IN (
        SELECT DBUSERNAME, OBJECT_NAME, COUNT(*) AS ACCESSES
        FROM AUDSYS.UNIFIED_AUDIT_TRAIL
        WHERE OBJECT_NAME IN ('CUSTOMERS', 'PAYMENTS')
        AND EVENT_TIMESTAMP > SYSTIMESTAMP - INTERVAL '1' HOUR
        GROUP BY DBUSERNAME, OBJECT_NAME
        HAVING COUNT(*) > 100
    ) LOOP
        ECOM_OWNER.LOG_SECURITY_ALERT(
            'HIGH_VOLUME_ACCESS',
            'HIGH',
            rec.DBUSERNAME,
            'High volume access to ' || rec.OBJECT_NAME || ': ' || rec.ACCESSES || ' in last hour'
        );
    END LOOP;
END;
/

/*
================================================================================
    6. Job للمراقبة الدورية (إنشاء بواسطة SYS في مخطط ECOM_OWNER)
    ملاحظة: تم حذف Job إذا كان موجوداً لتجنب الأخطاء
================================================================================
*/

BEGIN
    BEGIN
        DBMS_SCHEDULER.DROP_JOB('ECOM_OWNER.JOB_SECURITY_MONITORING', force => TRUE);
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'ECOM_OWNER.JOB_SECURITY_MONITORING',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                              ECOM_OWNER.CHECK_FAILED_LOGINS; 
                              ECOM_OWNER.CHECK_AFTERHOURS_ACCESS;
                              ECOM_OWNER.CHECK_SENSITIVE_ACCESS;
                           END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=HOURLY; INTERVAL=1',
        enabled         => TRUE,
        comments        => 'Job to run security alert checks hourly'
    );
END;
/

/*
================================================================================
    7. عرض التنبيهات
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_ACTIVE_ALERTS AS
SELECT 
    ALERT_ID, ALERT_TYPE, SEVERITY, USERNAME, DESCRIPTION, ALERT_TIME
FROM ECOM_OWNER.SECURITY_ALERTS
WHERE IS_RESOLVED = 'N'
ORDER BY 
    DECODE(SEVERITY, 'CRITICAL', 1, 'HIGH', 2, 'MEDIUM', 3, 'LOW', 4),
    ALERT_TIME DESC;

GRANT SELECT ON ECOM_OWNER.V_ACTIVE_ALERTS TO SEC_ADMIN;
GRANT SELECT ON ECOM_OWNER.V_ACTIVE_ALERTS TO AUDITOR;

PROMPT تم إنشاء إجراءات التنبيه بنجاح ✓



SELECT POLICY_NAME, ENABLED_OPTION FROM AUDIT_UNIFIED_ENABLED_POLICIES;
