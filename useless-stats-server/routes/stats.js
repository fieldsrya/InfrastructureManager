var express = require('express');
var router = express.Router();
var oracledb = require('oracledb');
var dbConfig = require('./dbconfig.js');

oracledb.extendMetaData = false;
oracledb.fetchAsString = [ oracledb.DATE, oracledb.NUMBER ]; // fetch dates and numbers as strings
oracledb.outFormat =  oracledb.OBJECT;

oracledb.getConnection(
  {
    user          : dbConfig.user,
    password      : dbConfig.password,
    connectString : dbConfig.connectString
  },
  function(err, connection)
  {
    if (err) { console.error(err.message); return; }
    router.get('/', function(req, res) {
      connection.execute(
        "SELECT DBNAME, TABLE_COUNT, ROW_COUNT, MB_FREE, MB_USED, MB_ALLOCATED, AS_OF_DATE " +
          "FROM   current_stats " +
          "ORDER BY DBNAME",
        [], // no bind variables
        function(err, result)
        {
          if (err) {
            console.error(err.message);
            doRelease(connection);
            return;
          }
	    res.contentType('application/json').status(200);
	    //res.send(JSON.stringify(result.rows));
	    res.send(result.rows);
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
