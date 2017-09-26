var express = require('express');
var router = express.Router();
var oracledb = require('oracledb');
var dbConfig = require('./dbconfig.js');

oracledb.extendMetaData = true;
//oracledb.fetchAsString = [ oracledb.DATE, oracledb.NUMBER ]; // fetch dates and numbers as strings
//oracledb.fetchAsString = [ oracledb.NUMBER ];
oracledb.outFormat =  oracledb.ARRAY;

oracledb.getConnection(
  {
    user          : dbConfig.user,
    password      : dbConfig.password,
    connectString : dbConfig.connectString
  },
  function(err, connection)
  {
    if (err) { console.error(err.message); return; }
    router.get('/:DBNAME', function(req, res) {
      var databaseName = req.params.DBNAME;
      //console.log(databaseName);

      connection.execute(
        "SELECT to_number(to_char(r.run_date,'YYYY') || to_char(r.run_date, 'DDD')) AS RUN_DATE, s.ROW_COUNT, s.MB_USED " +
        //"SELECT 'new Date(' || to_number(substr(to_char(r.RUN_DATE,'YYYY-MM-DD'),0,4)) || ', ' || (to_number(substr(to_char(r.RUN_DATE,'YYYY-MM-DD'),6,2)) - 1) || ', ' || to_number(substr(to_char(r.RUN_DATE,'YYYY-MM-DD'),9,2)) || ')' AS RUN_DATE, s.ROW_COUNT, s.MB_USED " +
        "FROM database_info d, stats s, run_log r " +
        "WHERE d.ID = s.DATABASEID " +
        "AND r.id = s.run_log_id " +
        "AND d.name = :NAME " +
        "AND s.run_log_id > (select min(id) from run_log where run_date > sysdate - 360) " +
        "ORDER BY r.run_date desc ",
        [databaseName], // database name as bind variable
        //{ outFormat: oracledb.ARRAY },
        { outFormat: oracledb.ARRAY,
	  fetchinfo:
	  {
	    "RUN_DATE":		{ type : oracledb.NUMBER },
	    "ROW_COUNT":	{ type : oracledb.NUMBER },
            "MB_USED":	        { type : oracledb.NUMBER }
	  }
	},
        function(err, result)
        {
          if (err) {
            console.error(err.message);
            doRelease(connection);
            return;
          }
	
	  //res.contentType('application/json').status(200);
	  console.log(result.rows);
	  res.send(result.rows);
	 //});
         });
      });
    });

module.exports = router;


function doRelease(connection)
{
  connection.release(
    function(err)
    {
      if (err) { console.error(err.message); }
    });
}

function doClose(connection, resultSet)
{
  resultSet.close(
    function(err)
    {
      if (err) { console.error(err.message); }
      doRelease(connection);
    });
}
