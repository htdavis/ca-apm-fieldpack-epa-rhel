#!/bin/perl
#############################################################
# WebSphere Usage Statistics
# =========================
# Copyright (C) 2013
# =========================
# Description: 
# The program gathers CPU & RSS statistics from WebSphere
# processes and places them under node "JVM Stats"
# Note:
# The program has been modified from the original (psweb.pl)
# due to an enhancement request to also gather other types of nodes.
# In order for you to successfully use this program, it is necessary
# for you to understand where the node names are positioned in the
# 'ps' output. Adjust the tab stop value in each 'psCommand' to your needs.
# =========================
# Usage: perl <epa_home>/epaplugins/rhel/psWASforLinux.pl
#############################################################
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl");
use Wily::PrintMetric;

use strict;

# grab WAS node at last tab stop
my $psCommand='ps -eaf|awk \'/(WebSphere\/.*\/java)/&&!/grep/{print $2}\'|xargs -n1 ps vww|awk \'NF>5&&!/PID/{printf "%s\t%s\t%s\n",$8,$9,$NF;t+=$7;c+=$11}\'';
my @psResults=`$psCommand`;

# grab WAS node at tab stop 48; looking for "-DSERVER_LOG_ROOT="
my $psCommand2='ps -eaf|awk \'/(-DSERVER_LOG_ROOT)/&&!/grep/{print $2}\'|xargs -n1 ps vww|awk \'NF>5&&!/PID/{printf "%s\t%s\t%s\n",$8,$9,$48;t+=$7;c+=$11}\'';
my @psResults2=`$psCommand2`;

# grab WAS node at tab stop 56; looking for "-Dname.server="
my $psCommand3='ps -eaf|awk \'/(-Dname\.server)/&&!/grep/{print $2}\'|xargs -n1 ps vww|awk \'NF>5&&!/PID/{printf "%s\t%s\t%s\n",$8,$9,$56;t+=$7;c+=$11}\'';
my @psResults3=`$psCommand3`;

# output results
#RSS	 CPU	 AppServer	# HEADER IS NOT DISPLAYED; FOR REFERENCE ONLY
#29272   0.4     app1
#94428   0.4     app2
#45820   0.5     nodeagent
#48476   0.3     app3
#62148   0.6     app4
#55352   0.3     app5

# initialize counter for total resident memory
my $total=0;

my ($property, $nodeName);

# parse first set of results
foreach my $line (@psResults){
	chomp $line;
	# split the row
	my @jvmStats=split /\t/, $line;
	# find the apps that aren't reporting node names
	if ($jvmStats[2] =~ /^(-[a-z]|com\.wily)/io) { 
		# loop to next row
		next;
	}
	# total up the resident memory value
	($total+=$_) for $jvmStats[0];
	# print metrics
	Wily::PrintMetric::printMetric(	type		=> 'StringEvent',
					resource	=> 'JVM Stats',
					subresource	=> $jvmStats[2],
					name		=> 'CPU (%)',
					value		=> $jvmStats[1],
					);
	Wily::PrintMetric::printMetric(	type		=> 'IntCounter',
					resource	=> 'JVM Stats',
					subresource	=> $jvmStats[2],
					name		=> 'RSS',
					value		=> int($jvmStats[0]),
					);
}

# parse second set of results
foreach my $line2 (@psResults2){
	chomp $line2;
	# split the row
	my @jvmStats2=split /\t/, $line2;
	# total up the resident memory value
	($total+=$_) for $jvmStats2[0];
	# split on the last occurrence of "/" and use the WAS node name as subresource
	my ($property2, $nodeName2)=split(/\/([^\/]+)$/, $jvmStats2[2]);
	# print metrics
	Wily::PrintMetric::printMetric(	type		=> 'StringEvent',
					resource	=> 'JVM Stats',
					subresource	=> $nodeName2,
					name		=> 'CPU (%)',
					value		=> $jvmStats2[1],
					);
	Wily::PrintMetric::printMetric(	type		=> 'IntCounter',
					resource	=> 'JVM Stats',
					subresource	=> $nodeName2,
					name		=> 'RSS',
					value		=> int($jvmStats2[0]),
					);
}

# parse third set of results
foreach my $line3 (@psResults3){
	chomp $line3;
	# split the row
	my @jvmStats3=split /\t/, $line3;
	# total up the resident memory value
	($total+=$_) for $jvmStats3[0];
	# split on the last occurrence of "=" and use the WAS node name as subresource
	my ($property3, $nodeName3)=split(/=/, $jvmStats3[2]);
	# print metrics
	Wily::PrintMetric::printMetric(	type		=> 'StringEvent',
					resource	=> 'JVM Stats',
					subresource	=> $nodeName3,
					name		=> 'CPU (%)',
					value		=> $jvmStats3[1],
					);
	Wily::PrintMetric::printMetric(	type		=> 'IntCounter',
					resource	=> 'JVM Stats',
					subresource	=> $nodeName3,
					name		=> 'RSS',
					value		=> int($jvmStats3[0]),
					);
}

# print the total resident memory usage
Wily::PrintMetric::printMetric(	type		=> 'LongCounter',
				resource	=> 'JVM Stats',
				name		=> 'Total Resident Memory (KB)',
				value		=> $total,
				);
