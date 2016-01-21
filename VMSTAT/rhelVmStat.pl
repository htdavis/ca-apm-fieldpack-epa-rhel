#!/bin/perl
#############################################################
# RHEL VMSTAT
# =========================
# Copyright (C) 2011-2013
# =========================
# Description: 
# The program provides detailed vmstat statistics on RHEL only
# =========================
# Usage: perl rhelVmStat.pl
#############################################################
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl");
use Wily::PrintMetric;

use strict;

# vmstat command for table of detailed statistics
my $vmstatCommand='vmstat -s';
# call vmstat
my @vmstatResults=`$vmstatCommand`;

# === begin parsing results ===
# data is presented in a vertical table with 2 columns
#  col1 col2
# value metricname

# count loops through rows and print metric;
my $counter = 0;
my @vals;
foreach my $line (@vmstatResults) {
   # remove trailing newline
   chomp $line; 
   # remove leading and trailing spaces
   $line =~ s/^\s+//;
   $line =~ s/\s+$//;
   #print "line=$line\n"; #for debug
   # split the line on first occurrence of space
   if ($counter >= 10 && $counter <= 23) {
       @vals = split(/\s/, $line, 2);
   } else {
       @vals = split(/\s\s/, $line);
   }
   #print "val1=$vals[0]\n"; #for debug
   #print "val2=$vals[1]\n"; #for debug
   # based on $counter, print metrics to Memory, Swap, CPU, Pages, System
   if ($counter >= 0 && $counter <= 5) {
       Wily::PrintMetric::printMetric( type=>'IntCounter',
                                       resource=>'rhelVMSTAT',
                                       subresource=>'Memory',
                                       name=>$vals[1],
                                       value=>$vals[0],
                                     );
   } elsif ($counter >= 6 && $counter <= 9) {
       Wily::PrintMetric::printMetric( type=>'IntCounter',
                                       resource=>'rhelVMSTAT',
                                       subresource=>'Swap',
                                       name=>$vals[1],
                                       value=>$vals[0],
                                     );
   } elsif ($counter >= 10 && $counter <= 17) {
       Wily::PrintMetric::printMetric( type=>'IntCounter',
                                       resource=>'rhelVMSTAT',
                                       subresource=>'CPU',
                                       name=>$vals[1],
                                       value=>$vals[0],
                                     );
   } elsif ($counter >= 18 && $counter <= 21) {
       Wily::PrintMetric::printMetric( type=>'IntCounter',
                                       resource=>'rhelVMSTAT',
                                       subresource=>'Pages',
                                       name=>$vals[1],
                                       value=>$vals[0],
                                     );
   } elsif ($counter >= 22 && $counter <= 23) {
       Wily::PrintMetric::printMetric( type=>'IntCounter',
                                       resource=>'rhelVMSTAT',
                                       subresource=>'System',
                                       name=>$vals[1],
                                       value=>$vals[0],
                                     );
   }
   $counter++;
}