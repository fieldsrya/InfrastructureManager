create or replace PROCEDURE            INSERT_STATS_PROC 
(v_rowcnt NUMBER,
 v_tblcnt NUMBER,
 v_free NUMBER,
 v_used NUMBER,
 v_allocated NUMBER,
 v_logmode VARCHAR2,
 v_dbid VARCHAR2 
)

AS
  v_exists NUMBER := NULL;
  v_database_pk1 NUMBER := NULL;
  v_runlog_pk1 NUMBER := NULL;
BEGIN
 BEGIN
  SELECT (1),id INTO v_exists,v_database_pk1 FROM DATABASE_INFO
  WHERE dbid = v_dbid;
      EXCEPTION
        WHEN no_data_found
        THEN
          v_exists :=0;
  
 END;
 BEGIN
   SELECT MAX(id) INTO v_runlog_pk1 FROM RUN_LOG;
 END;
 IF v_exists = 1 THEN
  INSERT INTO STATS VALUES (NULL, v_database_pk1, v_rowcnt, v_tblcnt, v_free, v_used, v_allocated, v_logmode, v_runlog_pk1);
  commit;
 END IF; 
END;