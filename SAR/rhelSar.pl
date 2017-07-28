#!/usr/bin/perl
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
 Stats are actually floating point values, so all values are rounded up or down

 To see help information:

 perl <epa_home>/epaplugins/rhel/rhelSar.pl --help

 or run with no commandline arguments.

 To test against sample output, use the DEBUG flag:

 perl <epa_home>/epaplugins/rhel/rhelSar.pl --debug
 
=head1 CAVEATS

 None

=head1 ISSUE TRACKING

 Submit any bugs/enhancements to: https://github.com/htdavis/ca-apm-fieldpack-epa-rhel/issues

=head1 AUTHOR

 Hiko Davis, Sr Engineering Services Architect, CA Technologies

=head1 COPYRIGHT

 Copyright (c) 2014

 This plug-in is provided AS-IS, with no warranties, so please test thoroughly!

=cut

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl", "$FindBin::Bin/../../lib/perl");
use Wily::PrintMetric;

use Getopt::Long;


sub usage {
    print "Unknown option: @_\n" if ( @_ );
    print "usage: $0 [--debug] [--help|-?]\n";
    exit;
}


# command to be executed
my ($sarCommand, @sarResults);

my ($help, $debug);
# get commandline parameters or display help
&usage if ( not GetOptions( 'help|?' => \$help,
                            'debug!' => \$debug,
                          )
            or defined $help );

# run debug if called; else execute 'sar'
if ( $debug ) {
    @sarResults = << "EOF" =~ m/(^.*\n)/mg;
Average:        all      0.03      0.00      0.04      0.01      0.00     99.93
Average:          0      0.03      0.00      0.03      0.00      0.00     99.93
Average:          1      0.04      0.00      0.05      0.01      0.00     99.89
Average:          2      0.02      0.00      0.03      0.01      0.00     99.94
Average:          3      0.03      0.00      0.02      0.00      0.00     99.94
EOF
} else {
    $sarCommand = "sar -P ALL | grep Average";
    # execute command; place results into array
    @sarResults = `$sarCommand`;
}


# skip 3 lines; iterate through sarResults
for my $i ( 0..$#sarResults ) {
    # remove trailing newline
    chomp $sarResults[$i];
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
                                        name        => 'Avg %user',
                                        value       => sprintf("%.0f", $sarData[2]),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %nice',
                                        value       => sprintf("%.0f", $sarData[3]),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %system',
                                        value       => sprintf("%.0f", $sarData[4]),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %iowait',
                                        value       => sprintf("%.0f", $sarData[5]),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %steal',
                                        value       => sprintf("%.0f", $sarData[6]),
                                      );
        Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                        resource    => 'rhelSAR',
                                        subresource => 'CPU ' . $sarData[1],
                                        name        => 'Avg %idle',
                                        value       => sprintf("%.0f", $sarData[7]),
                                      );
    }
}
