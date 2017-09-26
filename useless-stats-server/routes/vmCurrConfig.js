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
    router.get('/:VMNAME', function(req, res) {
      var vmName = req.params.VMNAME;
      //console.log(databaseName);

      connection.execute(
        "SELECT guest_name, cpus, memory_mb, provisioned_gb, used_gb, free_space_gb  " +
        "FROM VGUEST_STATS_VW " +
        "WHERE GUEST_NAME = :NAME ",
        [vmName], // database name as bind variable
        function(err, result)
        {
          if (err) {
            console.error(err.message);
            doRelease(connection);
            return;
          }
	
	  res.contentType('application/json').status(200);
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
