CREATE OR REPLACE PACKAGE LogManager
AS
    FUNCTION GetLogger RETURN Logger;
    FUNCTION GetLogger(logname VARCHAR2) RETURN Logger;
    FUNCTION GETCLASSNAME(DEPTH NUMBER) RETURN VARCHAR2;

    ll_TRACE VARCHAR2(6) := 'TRACE';
    ll_DEBUG VARCHAR2(6) := 'DEBUG';
    ll_INFO VARCHAR2(6) := 'INFO';
    ll_WARN VARCHAR2(6) := 'WARN';
    ll_ERROR VARCHAR2(6) := 'ERROR';
    ll_FATAL VARCHAR2(6) := 'FATAL';
    ll_ALL VARCHAR2(6) := 'ALL';

    ll_TRACE_enabled BOOLEAN := TRUE;
    ll_DEBUG_enabled BOOLEAN := TRUE;
    ll_INFO_enabled BOOLEAN := TRUE;
    ll_WARN_enabled BOOLEAN := TRUE;
    ll_ERROR_enabled BOOLEAN := TRUE;
    ll_FATAL_enabled BOOLEAN := TRUE;

    PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2);
    FUNCTION isEnabled(lvl VARCHAR2, mkr VARCHAR2) RETURN BOOLEAN;
END;
/
CREATE OR REPLACE PACKAGE BODY LOGMANAGER AS
  ROOT_LOGGER_NAME CONSTANT VARCHAR2(1) := '';

         $IF dbms_db_version.ver_le_11 $THEN

  PROCEDURE who_called_me(owner    OUT VARCHAR2,
                          NAME     OUT VARCHAR2,
                          lineno   OUT NUMBER,
                          caller_t OUT VARCHAR2 ,
                          DEPTH    NUMBER DEFAULT 1)
  AS
     call_stack  VARCHAR2(4096) DEFAULT dbms_utility.format_call_stack;
     n           NUMBER;
     found_stack BOOLEAN DEFAULT FALSE;
     line        VARCHAR2(255);
     cnt         NUMBER := 0;
  BEGIN
  --dbms_output.put_line(call_stack);
  --
     LOOP
         n := INSTR( call_stack, CHR(10) );
         EXIT WHEN ( n IS NULL OR n = 0 );
  --
         line := SUBSTR( call_stack, 1, n-1 );
         call_stack := SUBSTR( call_stack, n+1 );
  --
         IF ( NOT found_stack ) THEN
             IF ( line LIKE '%handle%number%name%' ) THEN
                 found_stack := TRUE;
             END IF;
         ELSE
             cnt := cnt + 1;
             -- cnt = 1 is ME
             -- cnt = 2 is MY Caller
             -- cnt = 3 is Their Caller
             IF ( cnt = (2+DEPTH) ) THEN
  --dbms_output.put_line('         1         2         3');
  --dbms_output.put_line('123456789012345678901234567890');
  --dbms_output.put_line(line);
                  --format '0x70165ba0       104  package body S06DP3.LOGMANAGER'
  --dbms_output.put_line('substr:'||substr( line, 14, 8 ));
                 lineno := to_number(SUBSTR( line, 12, 10 ));
                 line   := SUBSTR( line, 23 ); --set to rest of line .. change from 21 to 23
                 IF ( line LIKE 'pr%' ) THEN
                     n := LENGTH( 'procedure ' );
                 ELSIF ( line LIKE 'fun%' ) THEN
                     n := LENGTH( 'function ' );
                 ELSIF ( line LIKE 'package body%' ) THEN
                     n := LENGTH( 'package body ' );
                 ELSIF ( line LIKE 'pack%' ) THEN
                     n := LENGTH( 'package ' );
                 ELSIF ( line LIKE 'anonymous%' ) THEN
                     n := LENGTH( 'anonymous block ' );
                 ELSE
                     n := NULL;
                 END IF;
                 IF ( n IS NOT NULL ) THEN
                    caller_t := LTRIM(RTRIM(UPPER(SUBSTR( line, 1, n-1 ))));
                 ELSE
                    caller_t := 'TRIGGER';
                 END IF;

                 line := SUBSTR( line, NVL(n,1) );
                 n := INSTR( line, '.' );
                 owner := LTRIM(RTRIM(SUBSTR( line, 1, n-1 )));
                 NAME  := LTRIM(RTRIM(SUBSTR( LINE, N+1 )));
                 EXIT;
             END IF;
         END IF;
     END LOOP;
  END;
--         $ELSE
--           --VERSION 12 AND later CODE
--           BEGIN NULL; END;
         $END

  FUNCTION isEnabled(lvl VARCHAR2, mkr VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN (CASE lvl
			  WHEN 'TRACE' THEN logmanager.ll_trace_enabled
			  WHEN 'DEBUG' THEN logmanager.ll_debug_enabled
			  WHEN 'INFO'  THEN logmanager.ll_info_enabled
			  WHEN 'WARN'  THEN logmanager.ll_warn_enabled
			  WHEN 'ERROR' THEN logmanager.ll_error_enabled
			  WHEN 'FATAL' THEN logmanager.ll_fatal_enabled
			  ELSE FALSE
			END);
  END;

  PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2) IS
    owner       VARCHAR2(30);
    prgname     VARCHAR2(30);
    lineno      NUMBER;
    caller_type VARCHAR2(30);
  BEGIN
    $IF dbms_db_version.ver_le_11 $THEN
       WHO_CALLED_ME(OWNER, prgname, LINENO, CALLER_TYPE, 2);
    $ELSE
        --3 represent. 1 = this (logmanager.log), 2 = caller (ie logger.xxx), 3 = who called logger.xxx
      prgname := Utl_Call_Stack.Concatenate_Subprogram(Utl_Call_Stack.Subprogram(3));
      Lineno := Utl_Call_Stack.Unit_Line(3);
    $END
    --DBMS_OUTPUT.PUT_LINE(name||'('||lineno||') '||TO_CHAR(systimestamp,'YYYY-MM-DD"T"HH:MI:SSXFF6')||' '||RPAD(lvl,5)||rtrim(' '||marker)||' '||msg);
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD"T"HH:MI:SSXFF6')||' '||RPAD(lvl,5)||' '||REPLACE(prgname,' ')||'('||lineno||')'||RTRIM(' '||marker)||' - '||msg);
  END;

    --essentially who called me at depth
  FUNCTION getClassName(DEPTH NUMBER) RETURN VARCHAR2
  IS
    owner       VARCHAR2(30);
    prgname     VARCHAR2(30);
    lineno      NUMBER;
    caller_type VARCHAR2(30);
  BEGIN
    --k_logger.entry('getClassName');
    --dbms_output.put_line($$PLSQL_UNIT ||':'||loc.lineno);
    --dbms_output.put_line($$PLSQL_UNIT ||':'||loc.toString());
    --return k_logger.exit('getClassName',loc.getfqcn);
    $IF dbms_db_version.ver_le_11 $THEN
       LogManager.who_called_me( owner, prgname, lineno, caller_type ,DEPTH );
       RETURN owner||'.'||prgname;
    $ELSE
       RETURN utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1+DEPTH)); --owner||'.'||name;
    $END
  END;

  FUNCTION GetLogger(logname VARCHAR2) RETURN LOGGER IS
  BEGIN
    --k_logger.entry('GetLogger');
    --needs to come from logger context
    --K_LOGGER.debug('create simple logger');
    RETURN LOGGER(logname);

    --return TREAT( k_logger.exit('GetLogger',m_log) as Logger);
  END;

  FUNCTION GetLogger RETURN LOGGER IS
  BEGIN
    RETURN getLogger(getClassName(2));
  END;

  FUNCTION GetRootLogger RETURN LOGGER IS
  BEGIN
    RETURN getLogger(ROOT_LOGGER_NAME);
  END;

END;
/
