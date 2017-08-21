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
)
/
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

  MEMBER FUNCTION isInfoEnabled(marker VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    RETURN logmanager.ll_info_enabled;
  END;

  MEMBER FUNCTION isWarnEnabled(marker VARCHAR2) RETURN BOOLEAN
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
    IF isenabled(lvl, NULL) THEN
      logmanager.log(lvl, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE LOG(lvl VARCHAR2, marker VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(lvl, marker) THEN
      LogManager.log(lvl, marker, msg);
    END IF;
  END;

  MEMBER PROCEDURE ENTRY
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE, 'ENTRY')  THEN
      LogManager.log(LogManager.ll_TRACE, 'ENTRY', NULL);
    END IF;
  END;

  MEMBER PROCEDURE EXIT
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT')  THEN
	  LogManager.log(LogManager.ll_TRACE, 'EXIT', NULL);
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
       LogManager.log(LogManager.ll_INFO, NULL, msg);
   -- end if;
  END;

  MEMBER PROCEDURE WARN(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_WARN,NULL) THEN
      LogManager.log(LogManager.ll_WARN, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE ERROR(MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_ERROR,NULL) THEN
      LogManager.log(LogManager.ll_ERROR, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE fatal(msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_FATAL,NULL) THEN
      LogManager.log(LogManager.ll_FATAL, NULL, msg);
    END IF;
  END;

  MEMBER PROCEDURE TRACE(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,m) THEN
      LogManager.log(LogManager.ll_TRACE, m, msg);
    END IF;
  END;

  MEMBER PROCEDURE DEBUG(m VARCHAR2,MSG VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_DEBUG,m) THEN
      LogManager.log(LogManager.ll_DEBUG, m, msg);
    END IF;
  END;

  MEMBER PROCEDURE info(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_INFO,m) THEN
      LogManager.log(LogManager.ll_INFO, m, msg);
    END IF;
  END;

  MEMBER PROCEDURE warn(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_WARN,m) THEN
      LogManager.log(LogManager.ll_WARN, m, msg);
    END IF;
  END;

  MEMBER PROCEDURE ERROR(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_ERROR,m) THEN
      LogManager.log(LogManager.ll_ERROR, m, msg);
    END IF;
  END;

  MEMBER PROCEDURE fatal(m VARCHAR2, msg VARCHAR2)
  IS
  BEGIN
    IF isenabled(LogManager.ll_FATAL,m) THEN
      LogManager.log(LogManager.ll_FATAL, m, msg);
    END IF;
  END;

  MEMBER FUNCTION EXIT(RESULT VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT') THEN
      LogManager.log(LogManager.ll_TRACE, 'EXIT', RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT NUMBER) RETURN NUMBER
  IS
  BEGIN
   IF isenabled(LogManager.ll_TRACE,'EXIT') THEN
     LogManager.log(LogManager.ll_TRACE, 'EXIT', RESULT);
   END IF;

   RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT DATE) RETURN DATE
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT') THEN
      LogManager.log(LogManager.ll_TRACE, 'EXIT', RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT TIMESTAMP WITH TIME ZONE) RETURN TIMESTAMP WITH TIME ZONE
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT') THEN
      LogManager.log(LogManager.ll_TRACE,'EXIT',RESULT);
    END IF;
    RETURN RESULT;
  END;

  MEMBER FUNCTION EXIT(RESULT BOOLEAN) RETURN BOOLEAN
  IS
  BEGIN
    IF isenabled(LogManager.ll_TRACE,'EXIT') THEN
      IF RESULT IS NULL THEN
        LogManager.log(LogManager.ll_TRACE, 'EXIT', 'NULL');
      ELSIF RESULT THEN
        LogManager.log(LogManager.ll_TRACE, 'EXIT', 'TRUE');
      ELSE
        LogManager.log(LogManager.ll_TRACE, 'EXIT', 'FALSE');
      END IF;
    END IF;
    RETURN RESULT;
  END;

END;
/
