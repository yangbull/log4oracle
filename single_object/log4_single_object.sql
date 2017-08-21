--this is a drop in replaceform for a simple version of log4 oracle
--not all logging methods are available
-- it only prints to dbms_output
-- all log levels are always enabled

CREATE OR REPLACE TYPE logger AS OBJECT
(
  m_name VARCHAR2(255)
  --m_lvl number

    /* log4x 1.x api */

  ,MEMBER PROCEDURE TRACE(msg VARCHAR2)
  --,member procedure trace(msg varchar2, throwable)
  ,MEMBER PROCEDURE DEBUG(msg VARCHAR2)
  --,member procedure debug(msg varchar2, throwable)
  ,MEMBER PROCEDURE info(msg VARCHAR2)
  --,member procedure info(msg varchar2, throwable)
  ,MEMBER PROCEDURE warn(msg VARCHAR2)
  --,member procedure warn(msg varchar2, throwable)
  ,MEMBER PROCEDURE ERROR(msg VARCHAR2)
  --,member procedure error(msg varchar2, throwable)
  ,MEMBER PROCEDURE fatal(msg VARCHAR2)
  --,member procedure fatal(msg varchar2, throwable)

  ,MEMBER FUNCTION isTraceEnabled RETURN BOOLEAN
  ,MEMBER FUNCTION isDebugEnabled RETURN BOOLEAN
  ,MEMBER FUNCTION isInfoEnabled  RETURN BOOLEAN
  ,MEMBER FUNCTION isWarnEnabled  RETURN BOOLEAN
  ,MEMBER FUNCTION isErrorEnabled RETURN BOOLEAN
  ,MEMBER FUNCTION isFatalEnabled RETURN BOOLEAN

  ,MEMBER FUNCTION getName RETURN VARCHAR2

/*  removed from 2.x
getlevel
getparent
*/

  ,MEMBER PROCEDURE LOG(lvl VARCHAR2, msg VARCHAR2)
  --,member procedure log(lvl varchar2, MSG varchar2, throwable)
  --,member procedure log(fqcn varchar2,lvl varchar2, MSG varchar2, throwable)

    /* end log4 1.x api */


    /* log4 2.x api */
  --,member procedure catching(throwable)
  --,member procedure catching(lvl varchar2, throwable)
  ,MEMBER PROCEDURE DEBUG(m VARCHAR2, msg VARCHAR2)
  --,member procedure debug(m varchar2, msg varchar2, throwable)

  ,MEMBER PROCEDURE ENTRY
  --,member procedure entry(params varchar2)

  ,MEMBER PROCEDURE ERROR(m VARCHAR2, msg VARCHAR2)
  --,member procedure error(m varchar2, msg varchar2, throwable)

  ,MEMBER PROCEDURE EXIT
--sql overloads
  ,MEMBER FUNCTION EXIT(RESULT VARCHAR2) RETURN VARCHAR2
  ,MEMBER FUNCTION EXIT(RESULT NUMBER) RETURN NUMBER
  ,MEMBER FUNCTION EXIT(RESULT DATE) RETURN DATE
  --,member function exit(result BINARY_FLOAT) return BINARY_FLOAT
  --,member function exit(result BINARY_DOUBLE) return BINARY_DOUBLE
  ,MEMBER FUNCTION EXIT(RESULT TIMESTAMP WITH TIME ZONE) RETURN TIMESTAMP WITH TIME ZONE
  --,member function exit(result INTERVAL YEAR TO MONTH ) return INTERVAL YEAR TO MONTH
  --,member function exit(result INTERVAL DAY TO SECOND ) return INTERVAL DAY TO SECOND
  --,member function exit(result RAW) return RAW
  --,member function exit(result BFILE) return BFILE
--pl/sql overloads
  ,MEMBER FUNCTION EXIT(RESULT BOOLEAN) RETURN BOOLEAN
  --,member function exit(result R) return R

  ,MEMBER PROCEDURE fatal(m VARCHAR2, msg VARCHAR2)
  --,member procedure fatal(m varchar2, msg varchar2, throwable)

  ,MEMBER PROCEDURE info(m VARCHAR2, msg VARCHAR2)
  --,member procedure info(m varchar2, msg varchar2, throwable)

  ,MEMBER FUNCTION isTraceEnabled(marker VARCHAR2) RETURN BOOLEAN
  ,MEMBER FUNCTION isDebugEnabled(marker VARCHAR2) RETURN BOOLEAN
  ,MEMBER FUNCTION isInfoEnabled(marker VARCHAR2)  RETURN BOOLEAN
  ,MEMBER FUNCTION isWarnEnabled(marker VARCHAR2)  RETURN BOOLEAN
  ,MEMBER FUNCTION isErrorEnabled(marker VARCHAR2) RETURN BOOLEAN
  ,MEMBER FUNCTION isFatalEnabled(marker VARCHAR2) RETURN BOOLEAN

  ,MEMBER FUNCTION isEnabled(lvl VARCHAR2) RETURN BOOLEAN
  ,MEMBER FUNCTION isEnabled(lvl VARCHAR2, marker VARCHAR2) RETURN BOOLEAN

  ,MEMBER PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2)
  --,member procedure log(lvl varchar2, marker varchar2, msg varchar2, throwable)


  --,member function throwing(lvl varchar2, t throwable) return throwable
  --,member function throwing(t throwable) return throwable

  ,MEMBER PROCEDURE TRACE(m VARCHAR2, msg VARCHAR2)
  --,member procedure trace(m varchar2, msg varchar2, throwable)

  ,MEMBER PROCEDURE warn(m VARCHAR2, msg VARCHAR2)
  --,member procedure warn(m varchar2, msg varchar2, throwable)

    /* end log4 2.x */
);
/
SHOW ERRORS


CREATE OR REPLACE PACKAGE LogManager
AS
    FUNCTION GetLogger RETURN Logger;
    FUNCTION GetLogger(NAME VARCHAR2) RETURN Logger;
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
SHOW ERRORS

--now implementations

CREATE OR REPLACE TYPE BODY LOGGER AS
  MEMBER FUNCTION getName RETURN VARCHAR2 IS
  BEGIN
    RETURN m_name;
  END;

  MEMBER FUNCTION isEnabled(lvl IN VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN isEnabled(lvl,NULL);
  END;

  MEMBER FUNCTION isEnabled(lvl IN VARCHAR2, marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN LogManager.isenabled(lvl,marker);
  END;

  MEMBER FUNCTION isTraceEnabled RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_trace_enabled;
  END;

  MEMBER FUNCTION isDebugEnabled RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_debug_enabled;
  END;

  MEMBER FUNCTION isInfoEnabled  RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_info_enabled;
  END;

  MEMBER FUNCTION isWarnEnabled  RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_warn_enabled;
  END;

  MEMBER FUNCTION isErrorEnabled RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_error_enabled;
  END;

  MEMBER FUNCTION isFatalEnabled RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_fatal_enabled;
  END;

  MEMBER FUNCTION isTraceEnabled(marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_trace_enabled;
  END;
  
  MEMBER FUNCTION isDebugEnabled(marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_debug_enabled;
  END;

  MEMBER FUNCTION isInfoEnabled(marker VARCHAR2)  RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_info_enabled;
  END;

  MEMBER FUNCTION isWarnEnabled(marker VARCHAR2)  RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_warn_enabled;
  END;

  MEMBER FUNCTION isErrorEnabled(marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_error_enabled;
  END;

  MEMBER FUNCTION isFatalEnabled(marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_fatal_enabled;
  END;

  MEMBER PROCEDURE LOG(lvl VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(lvl,NULL) THEN
      logmanager.log(lvl,NULL,msg);
    END IF;
  END;

  MEMBER PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(lvl,marker) THEN
      LogManager.log(lvl,marker,msg);
    END IF;
  END;

  MEMBER PROCEDURE ENTRY
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'ENTRY')  THEN
      LogManager.log(LogManager.ll_TRACE,'ENTRY',NULL);
    END IF;
  END;

  MEMBER PROCEDURE EXIT
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
	  LogManager.log(LogManager.ll_TRACE,'EXIT',NULL);
	END IF;
  END;

  MEMBER PROCEDURE TRACE(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,NULL)  THEN
      LogManager.log(LogManager.ll_TRACE, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE DEBUG(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_DEBUG,NULL) THEN
      LogManager.log(LogManager.ll_DEBUG, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE INFO(MSG VARCHAR2)
  IS
  BEGIN
    --if isenabled(LogManager.ll_INFO,NULL) THEN
       LogManager.log(LogManager.ll_INFO,NULL,msg);
   -- end if;
  END;

  MEMBER PROCEDURE WARN(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_WARN,NULL)  THEN
      LogManager.log(LogManager.ll_WARN,NULL,msg);
    END IF;
  END;

  MEMBER PROCEDURE ERROR(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_ERROR,NULL)  THEN
      LogManager.log(LogManager.ll_ERROR,NULL,msg);
    END IF;
  END;

  MEMBER PROCEDURE fatal(msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_FATAL,NULL)  THEN
      LogManager.log(LogManager.ll_FATAL,NULL,msg);
    END IF;
  END;

  MEMBER PROCEDURE TRACE(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,m)  THEN
      LogManager.log(LogManager.ll_TRACE,m,msg);
    END IF;
  END;

  MEMBER PROCEDURE DEBUG(m VARCHAR2,MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_DEBUG,m) THEN
      LogManager.log(LogManager.ll_DEBUG,m,msg);
    END IF;
  END;

  MEMBER PROCEDURE info(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_INFO,m)  THEN
      LogManager.log(LogManager.ll_INFO,m,msg);
    END IF;
  END;

  MEMBER PROCEDURE warn(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_WARN,m)  THEN
      LogManager.log(LogManager.ll_WARN,m,msg);
    END IF;
  END;

  MEMBER PROCEDURE ERROR(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_ERROR,m)  THEN
      LogManager.log(LogManager.ll_ERROR,m,msg);
    END IF;
  END;

  MEMBER PROCEDURE fatal(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_FATAL,m)  THEN
      LogManager.log(LogManager.ll_FATAL,m,msg);
    END IF;
  END;

  MEMBER FUNCTION EXIT(RESULT VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
      LogManager.log(LogManager.ll_TRACE,'EXIT',RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT NUMBER) RETURN NUMBER
  IS
  BEGIN
   IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
     LogManager.log(LogManager.ll_TRACE,'EXIT',RESULT);
   END IF;

   RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT DATE) RETURN DATE
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
      LogManager.log(LogManager.ll_TRACE,'EXIT',RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT TIMESTAMP WITH TIME ZONE) RETURN TIMESTAMP WITH TIME ZONE
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
      LogManager.log(LogManager.ll_TRACE,'EXIT',RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT BOOLEAN) RETURN BOOLEAN
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
      IF RESULT IS NULL THEN
        LogManager.log(LogManager.ll_TRACE,'EXIT','NULL');
      ELSIF RESULT THEN
        LogManager.log(LogManager.ll_TRACE,'EXIT','TRUE');
      ELSE
        LogManager.log(LogManager.ll_TRACE,'EXIT','FALSE');
      END IF;
    END IF;
    RETURN RESULT;
  END;

END;
/
SHOW ERRORS



CREATE OR REPLACE PACKAGE BODY LOGMANAGER AS
  ROOT_LOGGER_NAME CONSTANT VARCHAR2(1) := '';

         $IF dbms_db_version.ver_le_11 $THEN

  PROCEDURE who_called_me( owner      OUT VARCHAR2,
						  NAME       OUT VARCHAR2,
						  lineno     OUT NUMBER,
						  caller_t   OUT VARCHAR2 ,
						  DEPTH NUMBER DEFAULT 1)
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
         $ELSE
           VERSION 12 AND later CODE
         $END


  FUNCTION isEnabled(lvl VARCHAR2, mkr VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
	RETURN (CASE lvl
		WHEN 'TRACE' THEN logmanager.ll_trace_enabled
		WHEN 'DEBUG' THEN logmanager.ll_debug_enabled
		WHEN 'INFO' THEN logmanager.ll_info_enabled
		WHEN 'WARN' THEN logmanager.ll_warn_enabled
		WHEN 'ERROR' THEN logmanager.ll_error_enabled
		WHEN 'FATAL' THEN logmanager.ll_fatal_enabled
		ELSE FALSE
		END );
  END;

  PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2) IS
	 owner       VARCHAR2(30);
	 NAME        VARCHAR2(30);
	 lineno      NUMBER;
	 caller_type VARCHAR2(30);
  BEGIN
	$IF dbms_db_version.ver_le_11 $THEN
			WHO_CALLED_ME( OWNER, NAME, LINENO, CALLER_TYPE, 2);
			 $ELSE
		--3 represent. 1 = this (logmanager.log), 2 = caller (ie logger.xxx), 3 = who called logger.xxx
		NAME := Utl_Call_Stack.Concatenate_Subprogram(Utl_Call_Stack.Subprogram(3));
		Lineno := Utl_Call_Stack.Unit_Line(3);
	$END
		--DBMS_OUTPUT.PUT_LINE(name||'('||lineno||') '||TO_CHAR(systimestamp,'YYYY-MM-DD"T"HH:MI:SSXFF6')||' '||RPAD(lvl,5)||rtrim(' '||marker)||' '||msg);
	DBMS_OUTPUT.PUT_LINE(TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD"T"HH:MI:SSXFF6')||' '||RPAD(lvl,5)||' '||REPLACE(NAME,' ')||'('||lineno||')'||RTRIM(' '||marker)||' - '||msg);
  END;

    --essentially who called me at depth
  FUNCTION getClassName(DEPTH NUMBER) RETURN VARCHAR2
  IS
    owner        VARCHAR2(30);
    NAME      VARCHAR2(30);
    lineno    NUMBER;
    caller_type      VARCHAR2(30);
  BEGIN
        --k_logger.entry('getClassName');
        --dbms_output.put_line($$PLSQL_UNIT ||':'||loc.lineno);
        --dbms_output.put_line($$PLSQL_UNIT ||':'||loc.toString());
        --return k_logger.exit('getClassName',loc.getfqcn);
	$IF dbms_db_version.ver_le_11 $THEN
	   LogManager.who_called_me( owner, NAME, lineno, caller_type ,DEPTH );
	   RETURN owner||'.'||NAME;
	$ELSE
	   RETURN utl_call_stack.concatenate_subprogram(utl_call_stack.subprogram(1+DEPTH)); --owner||'.'||name;
	$END
  END;


  FUNCTION GetLogger(NAME VARCHAR2) RETURN LOGGER IS
  BEGIN
    --k_logger.entry('GetLogger');
    --needs to come from logger context
    --K_LOGGER.debug('create simple logger');
    RETURN LOGGER(NAME);

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
SHOW ERRORS
