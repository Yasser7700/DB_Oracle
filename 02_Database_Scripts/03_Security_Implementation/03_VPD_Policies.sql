/*
================================================================================
    03_VPD_Policies.sql - ”Ì«”«  Virtual Private Database
    ‰Ÿ«„ «· Ã«—… «·≈·ﬂ —Ê‰Ì… «·¬„‰ Oracle 19c
================================================================================
    «·„” Œœ„ «·„ÿ·Ê»: SEC_ADMIN
================================================================================
*/

ALTER SESSION SET CONTAINER = ECOM_PDB;

PROMPT ≈‰‘«¡ ”Ì«”«  VPD...

/*
================================================================================
    1. ≈‰‘«¡ Application Context ··Ã·”…
================================================================================
*/

-- ÌÃ» √‰  ﬂÊ‰ «·Õ“„…  «»⁄… ·‹ SEC_ADMIN
CREATE OR REPLACE CONTEXT ECOM_CTX USING SEC_ADMIN.SET_ECOM_CONTEXT;
/

CREATE OR REPLACE PACKAGE SEC_ADMIN.SET_ECOM_CONTEXT AS
    PROCEDURE SET_CONTEXT;
END;
/

CREATE OR REPLACE PACKAGE BODY SEC_ADMIN.SET_ECOM_CONTEXT AS
    PROCEDURE SET_CONTEXT IS
        v_user VARCHAR2(50);
        v_role VARCHAR2(50);
        v_agent VARCHAR2(50);
    BEGIN
        v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
        
        --  ÕœÌœ «·œÊ—
        IF v_user IN ('SYS', 'SYSTEM', 'ECOM_OWNER', 'ECOM_MANAGER') THEN
            v_role := 'ADMIN';
        ELSIF v_user = 'SEC_ADMIN' THEN
            v_role := 'SECURITY';
        ELSIF v_user = 'AUDITOR' THEN
            v_role := 'AUDIT';
        ELSIF v_user = 'CS_AGENT' THEN
            v_role := 'SUPPORT';
            v_agent := v_user;
        ELSIF v_user = 'SALES_REP' THEN
            v_role := 'SALES';
        ELSE
            v_role := 'USER';
        END IF;
        
        DBMS_SESSION.SET_CONTEXT('ECOM_CTX', 'USER_ROLE', v_role);
        DBMS_SESSION.SET_CONTEXT('ECOM_CTX', 'USERNAME', v_user);
        IF v_agent IS NOT NULL THEN
            DBMS_SESSION.SET_CONTEXT('ECOM_CTX', 'AGENT_ID', v_agent);
        END IF;
    END;
END;
/

-- „·«ÕŸ…: ≈‰‘«¡ Trigger ⁄·Ï „” ÊÏ ﬁ«⁄œ… «·»Ì«‰«  Ì ÿ·» ’·«ÕÌ«  ⁄«·Ì… (ADMINISTER DATABASE TRIGGER).
-- ”‰ﬂ ›Ì »≈‰‘«¡ «·”Ì«”« ° ÊÌ„ﬂ‰ ··„” Œœ„ «” œ⁄«¡ «·≈Ã—«¡ ÌœÊÌ« ··«Œ »«—° 
-- √Ê ÌÃ»  ‰›Ì– Â–« «·Ã“¡ (Trigger) »Ê«”ÿ… SYS ≈–« √—œ‰« √ „  Â.
-- ·· ”ÂÌ·° ”‰ﬁÊ„ »≈‰‘«¡ Trigger ⁄·Ï „” ÊÏ SCHEMA (schema SEC_ADMIN) ·«Õﬁ« ≈–« ·“„ «·√„—°
-- ·ﬂ‰ «·¬‰ ”‰—ﬂ“ ⁄·Ï «·œÊ«·.

/*
================================================================================
    2. œÊ«· ”Ì«”«  VPD
================================================================================
*/

-- ”Ì«”… «·⁄„·«¡: Œœ„… «·⁄„·«¡  —Ï ›ﬁÿ «·⁄„·«¡ «·„⁄Ì‰Ì‰ ·Â«
CREATE OR REPLACE FUNCTION SEC_ADMIN.VPD_CUSTOMERS_POLICY (
    schema_var IN VARCHAR2,
    table_var  IN VARCHAR2
) RETURN VARCHAR2 AS
    v_role VARCHAR2(50);
    v_user VARCHAR2(50);
BEGIN
    v_role := SYS_CONTEXT('ECOM_CTX', 'USER_ROLE');
    v_user := SYS_CONTEXT('ECOM_CTX', 'USERNAME');
    
    -- «·„”ƒÊ·Ê‰ Ì—Ê‰ «·ﬂ·
    IF v_role IN ('ADMIN', 'SECURITY', 'AUDIT') THEN
        RETURN NULL;
    END IF;
    
    -- Œœ„… «·⁄„·«¡  —Ï «·⁄„·«¡ «·„⁄Ì‰Ì‰ ·Â« ›ﬁÿ
    IF v_role = 'SUPPORT' THEN
        RETURN 'ASSIGNED_AGENT = ''' || v_user || ''' OR ASSIGNED_AGENT IS NULL';
    END IF;
    
    -- «·¬Œ—Ê‰ ·« Ì—Ê‰ ‘Ì∆«
    RETURN '1=0';
END;
/

-- ”Ì«”… «·ÿ·»« : ﬂ· „” Œœ„ Ì—Ï ÿ·»« Â ›ﬁÿ
CREATE OR REPLACE FUNCTION SEC_ADMIN.VPD_ORDERS_POLICY (
    schema_var IN VARCHAR2,
    table_var  IN VARCHAR2
) RETURN VARCHAR2 AS
    v_role VARCHAR2(50);
BEGIN
    v_role := SYS_CONTEXT('ECOM_CTX', 'USER_ROLE');
    
    -- «·„”ƒÊ·Ê‰ Ê«·„” Êœ⁄ Ì—Ê‰ «·ﬂ·
    IF v_role IN ('ADMIN', 'SECURITY', 'AUDIT', 'SUPPORT', 'SALES') THEN
        RETURN NULL;
    END IF;
    
    RETURN '1=0';
END;
/

/*
================================================================================
    3.  ÿ»Ìﬁ «·”Ì«”« 
================================================================================
*/

BEGIN
    -- ”Ì«”… «·⁄„·«¡
    BEGIN
        DBMS_RLS.DROP_POLICY('ECOM_OWNER', 'CUSTOMERS', 'VPD_CUSTOMERS');
    EXCEPTION
        WHEN OTHERS THEN NULL; --  Ã«Â· «·Œÿ√ ≈–« ·„  ﬂ‰ «·”Ì«”… „ÊÃÊœ…
    END;

    DBMS_RLS.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'CUSTOMERS',
        policy_name     => 'VPD_CUSTOMERS',
        function_schema => 'SEC_ADMIN',
        policy_function => 'VPD_CUSTOMERS_POLICY',
        statement_types => 'SELECT,UPDATE',
        update_check    => TRUE,
        enable          => TRUE
    );
END;
/

BEGIN
    -- ”Ì«”… «·ÿ·»« 
    BEGIN
        DBMS_RLS.DROP_POLICY('ECOM_OWNER', 'ORDERS', 'VPD_ORDERS');
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_RLS.ADD_POLICY(
        object_schema   => 'ECOM_OWNER',
        object_name     => 'ORDERS',
        policy_name     => 'VPD_ORDERS',
        function_schema => 'SEC_ADMIN',
        policy_function => 'VPD_ORDERS_POLICY',
        statement_types => 'SELECT',
        enable          => TRUE
    );
END;
/

/*
================================================================================
    4. «· Õﬁﬁ
================================================================================
*/

PROMPT «·”Ì«”«  «·„›⁄·…:
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_NAME, ENABLE
FROM DBA_POLICIES
WHERE OBJECT_OWNER = 'ECOM_OWNER';

PROMPT  „ ≈‰‘«¡ ”Ì«”«  VPD ?
