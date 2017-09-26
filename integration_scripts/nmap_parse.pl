#!/usr/bin/perl

use strict;
use File::stat;
use DBD::Oracle;
use Text::CSV;
use Nmap::Parser;

my $tmpfile = "/tmp/nmap.xml";

if (-e $tmpfile) {
  unlink $tmpfile;
}

my $dbh = DBI->connect( 'dbi:Oracle:XXXXXXXXX',
                        'XXXXXXXX',
                        'XXXXXXXX',
                      ) || die "Database connection not made: $DBI::errstr";

# Clear the scan table
my $sql = " TRUNCATE TABLE NMAP_SCAN_RESULTS ";
my $sth = $dbh->prepare($sql);
$sth->execute;

# Set runlog info
my $sth = $dbh->prepare("BEGIN ADD_RUN_PROC; END;");
$sth->execute;

my $sql = "SELECT MAX(id) ";
$sql = $sql . " FROM RUN_LOG ";
$sth = $dbh->prepare($sql);
$sth->execute;
my ($run_log_id)=$sth->fetchrow_array();

# Start the NMap scan
system ("nmap -oX $tmpfile -A 192.168.236.0/22");

# Instantiate the parser
my $np = new Nmap::Parser;

$np->parsefile($tmpfile);

# Debug Info
print "Scan Information:\n";
my $si = $np->get_session();
print
'Number of services scanned: '.$si->numservices()."\n",
'Start Time: '.$si->start_str()."\n",
'Finish Time: '.$si->time_str()."\n",
'Scan Arguments: '.$si->scan_args()."\n";

print "Host Name,Ip Address,MAC Address,OS Name,OS Family,OS Generation,OS Accuracy,Port,Service Name,Service Product,Service Version,Service Confidence\n";
for my $host ($np->all_hosts()){
  for my $port ($host->tcp_ports()){
    my $service = $host->tcp_service($port);
    my $os = $host->os_sig;
    print $host->hostname().",".$host->ipv4_addr().",".$host->mac_addr().",".$port.",".$service->name.",".$service->product.",".$service->version.",".$service->confidence()."\n";
    $sth = $dbh->prepare("BEGIN INSERT_NMAP_SCAN(?,?,?,?,?,?,?,?,?); END;");
    $sth->bind_param(1, $host->hostname());
    $sth->bind_param(2, $host->ipv4_addr());
    $sth->bind_param(3, $host->mac_addr());
    $sth->bind_param(4, $port);
    $sth->bind_param(5, $service->name);
    $sth->bind_param(6, $service->product);
    $sth->bind_param(7, $service->version);
    $sth->bind_param(8, $service->confidence());
    $sth->bind_param(9, $run_log_id);
    $sth->execute;
  }	
}

$dbh->disconnect;
#unlink $tempfile;
