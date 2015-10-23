#!/usr/bin/perl
# This script comes from the torque source after unpacking contrib/pam_authuser.tar.gz
# it will be in pam_authuser/epilogue

use Fcntl qw(:flock);

$userName = $ARGV[1];

$accessFile = "/etc/authuser";
$found = 0;
$anotherJobRunning = 0;

$modifiedAccessFile = "";

open( ACCESSFILE, "+<$accessFile") or die("Unable to open user access file ($accessFile): $! ");
# Wait for a exclusive lock.
flock( ACCESSFILE, LOCK_EX) or die("Unable to obtain exclusive lock on user access file ($accessFile): $! ");

while ($line = <ACCESSFILE>){
    # only remove the user once (in the case of multi proc nodes and the same user has another job running)
    if( $line =~ /^$userName$/){
        if( $found == 0){
            $found = 1;
        }else{
            $anotherJobRunning = 1;
            $modifiedAccessFile .= $line;
        }
    }else{
        $modifiedAccessFile .= $line;
    }
}

# Truncate the file and write its modified contents back out
truncate( ACCESSFILE, 0) or die("Unable to truncate access file ($accessFile): $! ");
seek( ACCESSFILE,0,0);
print ACCESSFILE $modifiedAccessFile;

# closing the file releases the file lock
close(ACCESSFILE);

# uncomment to kill all processes owned by user if that user does not have another job running
if( $anotherJobRunning == 0){
    # the user only had one job on this node
    # kill all processes owned by user
    system( "pkill -U ".$userName );
}

exit(0);
