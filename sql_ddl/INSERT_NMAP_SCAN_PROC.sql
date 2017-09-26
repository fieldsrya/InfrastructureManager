create or replace PROCEDURE            STATS_USER.INSERT_NMAP_SCAN
(v_hostname VARCHAR2,
 v_ip_addr VARCHAR2,
 v_mac_addr VARCHAR2,
 v_port VARCHAR2,
 v_service_name VARCHAR2,
 v_service_product VARCHAR2,
 v_service_version VARCHAR2,
 v_service_confidence VARCHAR2,
 v_run_log_id NUMBER
)

AS

BEGIN
  INSERT INTO NMAP_SCAN_RESULTS VALUES (v_hostname, v_ip_addr, v_mac_addr, v_port, v_service_name, v_service_product, v_service_version, v_service_confidence, v_run_log_id);
  commit;
END;