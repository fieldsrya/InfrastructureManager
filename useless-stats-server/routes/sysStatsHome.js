var express = require('express');
var router = express.Router();
var oracledb = require('oracledb');
var dbConfig = require('./dbconfig.js');

oracledb.extendMetaData = false;
oracledb.fetchAsString = [ oracledb.DATE, oracledb.NUMBER ]; // fetch dates and numbers as strings
oracledb.outFormat =  oracledb.OBJECT;
oracledb.maxRows = 1000;

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
        "SELECT VGUEST_NAME, POWERSTATE, CONFIG_STATUS, VCLUSTER_NAME, VHOST_NAME, DATACENTER_NAME " +
          "FROM  VGUEST_STATUS_VW  ",
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
