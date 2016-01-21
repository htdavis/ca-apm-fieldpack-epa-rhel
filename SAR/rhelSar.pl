#!/bin/perl

=head1 NAME

 rhelSar.pl

=head1 SYNOPSIS

 IntroscopeEPAgent.properties configuration

 introscope.epagent.plugins.stateless.names=SAR
 introscope.epagent.stateless.SAR.command=perl <epa_home>/epaplugins/rhel/rhelSar.pl
 introscope.epagent.stateless.SAR.delayInSeconds=15 (or greater)

=head1 DESCRIPTION

 Pulls stats from commandline tool 'sar'
 Stats will be displayed per CPU/Core
 Stats are actually floating point values, so all values have been multiplied by 100

 To see help information:

 perl <epa_home>/epaplugins/rhel/rhelSar.pl --help

 or run with no commandline arguments.

 To test against sample output, use the DEBUG flag:

 perl <epa_home>/epaplugins/rhel/rhelSar.pl --debug

=head1 AUTHOR

 Hiko Davis, Principal Services Consultant, CA Technologies

=head1 COPYRIGHT

 Copyright (c) 2014

 This plug-in is provided AS-IS, with no warranties, so please test thoroughly!

=cut

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl");
use Wily::PrintMetric;

use strict;
use warnings;

use Getopt::Long;
use File::Spec;
use Cwd qw(abs_path);


sub usage {
    print "Unknown option: @_\n" if ( @_ );
    print "usage: $0 [--debug] [--help|-?]\n";
    exit;
}


# command to be executed
my ($sarCommand, @sarResults);

my ($help, $debug);
# get commandline parameters or display help
usage () if ( @ARGV < 1 or
    ! GetOptions( 'help|?'  =>  \$help,
                  'debug!'  =>  \$debug,
                )
    or defined $help );

# run debug if called; else execute 'sar'
if ( $debug ) {
    @sarResults = do { open my $fh, '<', File::Spec->catfile(abs_path, "epaplugins", "rhel", "samples", "sar_out"); <$fh>; };
} else {
    $sarCommand = "sar -P ALL";
    # execute command; place results into array
    @sarResults = `$sarCommand`;
}


# skip 5 lines; iterate through sarResults
for my $i ( 5..$#sarResults ) {
    # remove trailing newline
    chomp $sarResults[$i];
    # check for blank line & skip
    if ($sarResults[$i] =~ /^$/) { next; }
    # split on space " "
    my @sarData = split(/\s+/, $sarResults[$i]);
    # check metrics are averages or not
    if ( $sarData[0] =~ "Average:") {
        #skip first row
        if ($sarData[1] =~ "CPU") { next; }
        # return results
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %user (100x)',
                                        value       => int($sarData[2] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %nice (100x)',
                                        value       => int($sarData[3] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %system (100x)',
                                        value       => int($sarData[4] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %iowait (100x)',
                                        value       => int($sarData[5] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %steal (100x)',
                                        value       => int($sarData[6] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %idle (100x)',
                                        value       => int($sarData[7] * 100),
                                      );
    } else {
        # return results
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%user (100x)',
                                        value       => int($sarData[3] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%nice (100x)',
                                        value       => int($sarData[4] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%system (100x)',
                                        value       => int($sarData[5] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%iowait (100x)',
                                        value       => int($sarData[6] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%steal (100x)',
                                        value       => int($sarData[7] * 100),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[2],
                                        name        => '%idle (100x)',
                                        value       => int($sarData[8] * 100),
                                      );
    }
}
