create or replace PROCEDURE            INSERT_DB_PARAMETERS
( 
  v_dbid VARCHAR2,
  v_inst_id VARCHAR2,
  v_param_name VARCHAR2,
  v_param_value VARCHAR2,
  v_param_display_value VARCHAR2,
  v_param_default_value VARCHAR2
)

AS
  v_exists NUMBER := NULL;
  v_check_value VARCHAR2(500) := NULL;
  v_params_exist NUMBER := NULL;
  v_database_pk1 NUMBER := NULL;
  v_runlog_pk1 NUMBER := NULL;
BEGIN
 BEGIN
  SELECT (1),id INTO v_exists,v_database_pk1 
  FROM DATABASE_INFO
  WHERE dbid = v_dbid;
      EXCEPTION
        WHEN no_data_found
        THEN
          v_exists :=0;

 END;

 BEGIN
   SELECT MAX(id) INTO v_runlog_pk1 FROM RUN_LOG;
 END;

 -- Check if the database has parameters already in the table
 -- Added this check to prevent this table getting huge
 IF v_exists = 1 THEN
  BEGIN
    SELECT DISTINCT(1) INTO v_params_exist 
    FROM DBPARAMETERS
    WHERE v_database_pk1 = DATABASEID
      AND INST_ID = v_inst_id
      AND PARAM_NAME = v_param_name;
        EXCEPTION
          WHEN no_data_found
          THEN
            v_params_exist :=0;
  END;

  IF v_params_exist = 0 THEN
    INSERT INTO DBPARAMETERS VALUES (v_database_pk1, v_inst_id, v_param_name, v_param_value, v_param_display_value, v_param_default_value, v_runlog_pk1);
    commit;
  ELSE
    BEGIN
      SELECT param_value INTO v_check_value 
	    FROM DBPARAMETERS
      WHERE PARAM_NAME = v_param_name
        AND DATABASEID = v_database_pk1
        AND INST_ID = v_inst_id
		    AND RUN_LOG_ID = (SELECT MAX(RUN_LOG_ID) 
		      FROM DBPARAMETERS 
		      WHERE PARAM_NAME = v_param_name 
		      AND DATABASEID = v_database_pk1
          AND INST_ID = v_inst_id) ;
	  END;
  	IF v_check_value != v_param_value THEN
  	  INSERT INTO DBPARAMETERS VALUES (v_database_pk1, v_inst_id, v_param_name, v_param_value, v_param_display_value, v_param_default_value, v_runlog_pk1);
  	  COMMIT;
  	ELSE
  	  UPDATE DBPARAMETERS
	    SET run_log_id = v_runlog_pk1
	    WHERE DATABASEID = v_database_pk1
        AND INST_ID = v_inst_id
  	    AND PARAM_NAME = v_param_name;
	    COMMIT;
  	END IF;
  END IF;
 END IF; 
END;