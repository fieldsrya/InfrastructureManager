#!/usr/bin/perl

use strict;
use File::stat;
use DBD::Oracle;
my $dbh = DBI->connect( 'dbi:Oracle:XXXXXX',
                        'XXXXXXXX',
                        'XXXXXXXXX',
                      ) || die "Database connection not made: $DBI::errstr";
printf "Connected....\n";

# Location of the RVTools CSV Files and relevant filenames
my $csvdir = '/home/rvtools';
my @csvfiles = ('RVTools_tabvCluster.csv');#, 'RVTools_tabvHost.csv', 'RVTools_tabvInfo.csv');

# Logfile for the import operation
my $logfile = "import_stats.log";

# Misc Variables and stuff
my $before_row_count;
my $after_row_count;
my $diff_row_count;

# Open the logfile for writing and exit if it can't
open LOGF, ">>$logfile"
  or die "Could not open logfile...$!\n";


foreach my $file (@csvfiles) {
  open CSVF, "$csvdir/$file"
    or die "Could not open csv file $file ..$!\n";

  # Get the current row count for later comparison
  my $sth = $dbh->prepare("SELECT COUNT(*) FROM RVTOOLS_VCLUSTER_STG");
  $sth->execute;
  $before_row_count = $sth->fetchrow_array();

  # Clear out the staging table for new data
  $sth = $dbh->prepare("DELETE FROM RVTOOLS_VCLUSTER_STG");
  $sth->execute;

  # Log the begin and start parsing the file
  printf LOGF "Processing file $file ..\n";
  while (my $line = <CSVF>) {
    # Skip Header Row
    next if $. < 2;
    # Remove extra LF
    chomp($line);
    # Split the line at a comma
    # Not doing any correction for names with a comma because no one should ever ever create a system name with a comma in it
    my @fields = split(',',$line);
    # Execute the Stored Procedure
    my $sth = $dbh->prepare("BEGIN INSERT_VCLUSTER_STG(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?); END;");
    foreach my $i (0 .. $#fields)
    {
      my $bind_id = $i + 1;
      $sth->bind_param($bind_id,$fields[$i]);
    }
    $sth->execute;
  }
  
  # Check the current row count and compare
  # This will validate nothing terrible happened in the parse and insert
  my $sth = $dbh->prepare("SELECT COUNT(*) FROM RVTOOLS_VCLUSTER_STG");
  $sth->execute;
  $after_row_count = $sth->fetchrow_array();

  if ($after_row_count == 0) {
    printf LOGF "ERROR: Final row count is 0! No data processed for file $file!!\n";
  } elsif (($after_row_count - $before_row_count)/$before_row_count*100 > 10) {
    printf LOGF "INFO: There was a greater than 10% differene in row counts for file $file. Could be normal..Could be a problem.\n";
  } else {
    printf LOGF "SUCCESS: Processing for file $file is complete and appears normal.\n";
  }

}

$dbh->disconnect;


###########################################
# Functions and subs go below here
###########################################
