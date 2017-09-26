#!/usr/bin/perl

use strict;
use File::stat;
use DBD::Oracle;
use Text::CSV;
my $dbh = DBI->connect( 'dbi:Oracle:XXXXXXX',
                        'XXXXXXX',
                        'XXXXXXX',
                      ) || die "Database connection not made: $DBI::errstr";
printf "Connected....\n";

# Location of the RVTools CSV Files and relevant filenames
my $csvdir = '/home/rvtools';
my $csv = Text::CSV->new( { binary => 1 } );

# Logfile for the import operation
my $logfile = "rvtools_import.log";

## Enter into the run log table
my $sth = $dbh->prepare("BEGIN ADD_RUN_PROC; END;");
$sth->execute;

# Misc Variables and stuff
my $before_row_count;
my $after_row_count;
my $diff_row_count;
my $parms;

# Lets try a multi-dimensional array :)
my @parse_info = (
  ['RVTools_tabvCluster.csv', 'RVTools_tabvHost.csv', 'RVTools_tabvInfo.csv'],
  ['RVTOOLS_VCLUSTER_STG','RVTOOLS_VHOST_STG','RVTOOLS_VINFO_STG'],
  ['INSERT_VCLUSTER_STG(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    'INSERT_VHOST_STG(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    'INSERT_VINFO_STG(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)']
);

# Open the logfile for writing and exit if it can't
open LOGF, ">>$logfile"
  or die "Could not open logfile...$!\n";

# Loop the parse_info array and do work
for my $i(0..2) {
  for my $n (0..2) {
    # Logic to check for first elemt to avoid a preceeding comma
    if ($n != 0 ) {
      $parms = $parms . "," . $parse_info[$n][$i];
    } else {
      $parms = $parse_info[$n][$i];
    }
  }
  my @arr_parms = split /,/,$parms,3;
  ParseDataFile($arr_parms[0], $arr_parms[1], $arr_parms[2]);
}


$dbh->disconnect;
close LOGF;

###########################################
# Functions and subs go below here
###########################################
sub ParseDataFile {
  my $file = shift;
  my $stgtable = shift;
  my $proc_exec = shift;
  printf "$file...$stgtable...$proc_exec..\n";
  open my $io, "$csvdir/$file"
    or die "Could not open csv file $file ..$!\n";

  # Get the current row count for later comparison
  my $sql = "SELECT COUNT(*) FROM $stgtable";
  my $sth = $dbh->prepare($sql);
  $sth->execute;
  $before_row_count = $sth->fetchrow_array();

  # Clear out the staging table for new data
  $sql = "DELETE FROM $stgtable";
  $sth = $dbh->prepare($sql);
  $sth->execute;

  # Log the begin and start parsing the file
  printf LOGF "Processing file $file ..\n";
  
  # Skip the header by just grabbing it and doing nothing
  $csv->getline($io);

  # Parse the rest of the csv file
  while (my $line = $csv->getline($io)) {
    my @fields = @$line;
    # Execute the Stored Procedure
    my $sth = $dbh->prepare("BEGIN $proc_exec; END;");
    foreach my $i (0 .. $#fields)
    {
      my $bind_id = $i + 1;
      $sth->bind_param($bind_id,$fields[$i]);
    }
    $sth->execute;
  }
  close $io;
  
  # Check the current row count and compare
  # This will validate nothing terrible happened in the parse and insert
  $sql = "SELECT COUNT(*) FROM $stgtable";
  my $sth = $dbh->prepare($sql);
  $sth->execute;
  $after_row_count = $sth->fetchrow_array();

  if ($after_row_count == 0) {
    printf LOGF "ERROR: Final row count is 0! No data processed for file $file!!\n";
  } elsif ($before_row_count == 0) {
    printf LOGF "INFO: No previous row count for comparison. Should be ok.\n";
  } elsif (($after_row_count - $before_row_count)/$before_row_count*100 > 10) {
    printf LOGF "INFO: There was a greater than 10 percent difference in row counts for file $file. Could be normal..Could be a problem ¯\\_(ツ)_/¯ \n";
  } else {
    printf LOGF "SUCCESS: Processing for file $file is complete and appears normal.\n";
  }
}
