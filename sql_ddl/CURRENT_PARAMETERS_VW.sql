CREATE OR REPLACE FORCE EDITIONABLE VIEW "STATS_USER"."CURRENT_PARAMETERS" ("PARAMETER_NAME", "PARAMETER_VALUE", "DB_INSTANCE", "DB_NAME") AS 
  (SELECT
  P.PARAM_NAME
  , P.PARAM_DISPLAY_VALUE
  , DI.NAME || P.INST_ID AS INSTANCE
  , DI.NAME
FROM 
  DBPARAMETERS P
INNER JOIN DATABASE_INFO DI ON DI.ID = P.DATABASEID
WHERE P.RUN_LOG_ID = (SELECT MAX(RUN_LOG_ID) FROM STATS_USER.DBPARAMETERS));