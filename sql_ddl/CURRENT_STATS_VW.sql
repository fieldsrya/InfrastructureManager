  CREATE OR REPLACE FORCE EDITIONABLE VIEW "STATS_USER"."CURRENT_STATS" ("DBNAME", "TABLE_COUNT", "ROW_COUNT", "MB_FREE", "MB_USED", "MB_ALLOCATED", "AS_OF_DATE") AS 
  (select d.name, 
  s.table_count, 
  s.row_count,
  s.mb_free,
  s.mb_used,
  s.mb_allocated,
  rl.run_date
from STATS_USER.STATS s
inner join stats_user.database_info d on d.id = s.databaseid
inner join stats_user.run_log rl on s.run_log_id = rl.id
where run_log_id = (select max(run_log_id) from stats_user.stats)
AND d.name not like '%HCA%');
