#!/usr/bin/perl
# This script comes from the torque source after unpacking contrib/pam_authuser.tar.gz
# it will be in pam_authuser/prologue

use Fcntl qw(:flock);

$userName = $ARGV[1];

$accessFile = "/etc/authuser";

open( ACCESSFILE, ">>$accessFile") or die("Unable to open user access file ($accessFile): $! ");
# Wait for a exclusive lock.
flock( ACCESSFILE, LOCK_EX) or die("Unable to obtain exclusive lock on user access file ($accessFile): $! ");

print ACCESSFILE $userName . "\n";

# closing the file releases the file lock
close(ACCESSFILE);

exit(0);

