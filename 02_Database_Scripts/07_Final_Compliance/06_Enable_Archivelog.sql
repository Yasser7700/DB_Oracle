/*
================================================================================
    06_Enable_Archivelog.sql - تفعيل وضع الأرشفة تلقائياً
================================================================================
    طريقة التشغيل من CMD:
    sqlplus / as sysdba @C:\Users\osama\OneDrive\Attachments\Desktop\DB_Oracle\02_Database_Scripts\07_Final_Compliance\06_Enable_Archivelog.sql
================================================================================
*/

PROMPT إيقاف قاعدة البيانات (قد يستغرق وقتاً)...
SHUTDOWN IMMEDIATE;

PROMPT تشغيل في وضع Mount...
STARTUP MOUNT;

PROMPT تفعيل وضع الأرشفة (Archivelog)...
ALTER DATABASE ARCHIVELOG;

PROMPT فتح قاعدة البيانات...
ALTER DATABASE OPEN;

PROMPT التحقق من الوضع الحالي:
SELECT LOG_MODE FROM V$DATABASE;

EXIT;
