/*
================================================================================
    03_Backup_Procedures.sql - إجراءات النسخ الاحتياطي
    نظام التجارة الإلكترونية الآمن Oracle 19c
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT إنشاء إجراءات النسخ الاحتياطي...

/*
================================================================================
    1. جدول سجل النسخ الاحتياطي
================================================================================
*/

CREATE TABLE ECOM_OWNER.BACKUP_LOG (
    LOG_ID          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    BACKUP_TYPE     VARCHAR2(50),
    BACKUP_STATUS   VARCHAR2(20),
    START_TIME      TIMESTAMP,
    END_TIME        TIMESTAMP,
    BACKUP_SIZE_MB  NUMBER,
    BACKUP_LOCATION VARCHAR2(500),
    NOTES           VARCHAR2(2000)
);

/*
================================================================================
    2. إجراء تسجيل النسخ الاحتياطي
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.LOG_BACKUP (
    p_type      VARCHAR2,
    p_status    VARCHAR2,
    p_start     TIMESTAMP,
    p_end       TIMESTAMP DEFAULT NULL,
    p_size      NUMBER DEFAULT NULL,
    p_location  VARCHAR2 DEFAULT NULL,
    p_notes     VARCHAR2 DEFAULT NULL
) AS
BEGIN
    INSERT INTO BACKUP_LOG (BACKUP_TYPE, BACKUP_STATUS, START_TIME, END_TIME, BACKUP_SIZE_MB, BACKUP_LOCATION, NOTES)
    VALUES (p_type, p_status, p_start, p_end, p_size, p_location, p_notes);
    COMMIT;
END;
/

/*
================================================================================
    3. إجراء تصدير المخطط
================================================================================
*/

CREATE OR REPLACE PROCEDURE ECOM_OWNER.EXPORT_SCHEMA_BACKUP AS
    v_start TIMESTAMP;
    v_dir VARCHAR2(100) := 'BACKUP_DIR';
    v_file VARCHAR2(100);
BEGIN
    v_start := SYSTIMESTAMP;
    v_file := 'ECOM_BACKUP_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') || '.dmp';
    
    LOG_BACKUP('DATA_PUMP_EXPORT', 'STARTED', v_start);
    
    -- ملاحظة: التنفيذ الفعلي يتم عبر expdp من سطر الأوامر
    DBMS_OUTPUT.PUT_LINE('Execute from command line:');
    DBMS_OUTPUT.PUT_LINE('expdp ECOM_OWNER/password@ECOM_PDB DIRECTORY=' || v_dir || ' DUMPFILE=' || v_file || ' SCHEMAS=ECOM_OWNER');
    
    DBMS_OUTPUT.PUT_LINE('Backup file: ' || v_file);
END;
/

/*
================================================================================
    4. سكربتات RMAN (للتنفيذ من سطر الأوامر)
================================================================================
*/

-- حفظ سكربتات RMAN في الجدول
CREATE TABLE ECOM_OWNER.RMAN_SCRIPTS (
    SCRIPT_ID       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SCRIPT_NAME     VARCHAR2(100),
    SCRIPT_TYPE     VARCHAR2(50),
    SCRIPT_CONTENT  CLOB,
    CREATED_DATE    TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- سكربت النسخ الكامل
INSERT INTO ECOM_OWNER.RMAN_SCRIPTS (SCRIPT_NAME, SCRIPT_TYPE, SCRIPT_CONTENT)
VALUES ('FULL_BACKUP', 'RMAN', 
'RUN {
    ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
    BACKUP DATABASE PLUS ARCHIVELOG;
    RELEASE CHANNEL c1;
}');

-- سكربت النسخ التزايدي
INSERT INTO ECOM_OWNER.RMAN_SCRIPTS (SCRIPT_NAME, SCRIPT_TYPE, SCRIPT_CONTENT)
VALUES ('INCREMENTAL_BACKUP', 'RMAN',
'RUN {
    ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
    BACKUP INCREMENTAL LEVEL 1 DATABASE;
    BACKUP ARCHIVELOG ALL DELETE INPUT;
    RELEASE CHANNEL c1;
}');

-- سكربت نسخ PDB
INSERT INTO ECOM_OWNER.RMAN_SCRIPTS (SCRIPT_NAME, SCRIPT_TYPE, SCRIPT_CONTENT)
VALUES ('PDB_BACKUP', 'RMAN',
'RUN {
    BACKUP PLUGGABLE DATABASE ECOM_PDB PLUS ARCHIVELOG;
}');

COMMIT;

/*
================================================================================
    5. عرض سجل النسخ الاحتياطي
================================================================================
*/

CREATE OR REPLACE VIEW ECOM_OWNER.V_BACKUP_HISTORY AS
SELECT 
    LOG_ID,
    BACKUP_TYPE,
    BACKUP_STATUS,
    START_TIME,
    END_TIME,
    ROUND((EXTRACT(DAY FROM (END_TIME - START_TIME)) * 24 * 60 +
           EXTRACT(HOUR FROM (END_TIME - START_TIME)) * 60 +
           EXTRACT(MINUTE FROM (END_TIME - START_TIME))), 2) AS DURATION_MINS,
    BACKUP_SIZE_MB,
    BACKUP_LOCATION
FROM BACKUP_LOG
ORDER BY START_TIME DESC;

/*
================================================================================
    6. التحقق من آخر نسخة احتياطية
================================================================================
*/

CREATE OR REPLACE FUNCTION ECOM_OWNER.CHECK_BACKUP_STATUS RETURN VARCHAR2 AS
    v_last_backup TIMESTAMP;
    v_hours_ago NUMBER;
BEGIN
    SELECT MAX(END_TIME) INTO v_last_backup
    FROM BACKUP_LOG
    WHERE BACKUP_STATUS = 'COMPLETED';
    
    IF v_last_backup IS NULL THEN
        RETURN 'WARNING: No completed backups found!';
    END IF;
    
    v_hours_ago := (SYSDATE - CAST(v_last_backup AS DATE)) * 24;
    
    IF v_hours_ago > 24 THEN
        RETURN 'WARNING: Last backup was ' || ROUND(v_hours_ago) || ' hours ago!';
    ELSE
        RETURN 'OK: Last backup was ' || ROUND(v_hours_ago, 1) || ' hours ago.';
    END IF;
END;
/

PROMPT تم إنشاء إجراءات النسخ الاحتياطي ✓




SET SERVEROUTPUT ON;
EXEC ECOM_OWNER.GENERATE_COMPLIANCE_REPORT;


SELECT * FROM ECOM_OWNER.RMAN_SCRIPTS;






