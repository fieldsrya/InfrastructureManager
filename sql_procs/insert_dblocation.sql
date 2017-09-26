create or replace PROCEDURE                                                                                                               INSERT_DBLOCATION_PROC
(
 v_dbname VARCHAR2,
 v_dbhome VARCHAR2,
 v_servername VARCHAR2,
 v_run_log_id NUMBER
)

AS
  v_exists NUMBER := NULL;
  v_database_id NUMBER := NULL;
  v_dbcluster_id NUMBER := NULL;
BEGIN
 BEGIN
  SELECT (1),id INTO v_exists,v_database_id FROM DATABASE_INFO
  WHERE name = v_dbname
   AND ID = (SELECT MAX(ID) FROM DATABASE_INFO WHERE name = v_dbname);
      EXCEPTION
        WHEN no_data_found
        THEN
          v_exists := 0;
  END;
  BEGIN
   SELECT CLUSTERID INTO v_dbcluster_id FROM DBSERVER 
    WHERE lower(SERVERNAME) = lower(v_servername);
  END;
 IF v_exists = 1 THEN
  INSERT INTO DBLOCATION VALUES (NULL, v_database_id, v_dbhome, v_dbcluster_id, v_run_log_id);
  commit;
 END IF; 
END;