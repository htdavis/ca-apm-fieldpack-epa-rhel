#!/usr/bin/perl
=head1 NAME

 rhelVmStat.pl

=head1 SYNOPSIS

 IntroscopeEPAgent.properties configuration

 introscope.epagent.plugins.stateless.names=VMSTAT
 introscope.epagent.stateless.VMSTAT.command=perl <epa_home>/epaplugins/rhel/rhelVmStat.pl
 introscope.epagent.stateless.VMSTAT.delayInSeconds=15

=head1 DESCRIPTION

 Pulls network IO statistics

 To see help information:

 perl <epa_home>/epaplugins/rhel/rhelVmStat.pl --help

 or run with no commandline arguments.

 To test against sample output, use the DEBUG flag:

 perl <epa_home>/epaplugins/rhel/rhelVmStat.pl --debug

=head1 CAVEATS

 NONE

=head1 ISSUE TRACKING

 Submit any bugs/enhancements to: https://github.com/htdavis/ca-apm-fieldpack-epa-rhel/issues

=head1 AUTHOR

 Hiko Davis, Principal Services Consultant, CA Technologies

=head1 COPYRIGHT

 Copyright (c) 2017

 This plug-in is provided AS-IS, with no warranties, so please test thoroughly!

=cut

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl", "$FindBin::Bin/../../lib/perl");
use Wily::PrintMetric;

use Getopt::Long;

=head2 SUBROUTINES

=cut

=head3 USAGE

 Prints help information for this program

=cut
sub usage {
    print "Unknown option: @_\n" if ( @_ );
    print "usage: $0 <epa_home>/epaplugins/rhel/rhelVmStat.pl[--help|-?] [--debug]\n\n";
    exit;
}

my ($help, $debug);
&usage if ( not GetOptions( 'help|?' => \$help,
                            'debug!' => \$debug,
                          )
            or defined $help );
            
my ($vmstatCommand, @vmstatResults);

if ($debug) {
    @vmstatResults = <<END_VMSTAT =~ m/(^.*\n)/mg;
 1  0      0 1204408 718368 7678556    0    0     0  1148 1590 2685  3  1 96  0  0
END_VMSTAT
} else {
    $vmstatCommand = "vmstat 1 2";
    @vmstatResults = `$vmstatCommand`;
}

@vmstatResults = @vmstatResults[2..$#vmstatResults];
for my $line (@vmstatResults) {
    # remove EOL char
    chomp $line;
    # remove leading & trailing space
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    # split on spaces; place values to array
    my @values = split( /\s+/, $line);
    # report zero if value is blank/null
    if (!defined($values[17])) { $values[17] = 0; }
    if (!defined($values[18])) { $values[18] = 0; }
    # return results
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Procs',
                                    name            => 'Waiting Threads',
                                    value           => $values[0],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Procs',
                                    name            => 'Running Threads',
                                    value           => $values[1],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Used Virtual Memory',
                                    value           => $values[2],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Idle Memory',
                                    value           => $values[3],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Buffer  Memory',
                                    value           => $values[4],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Cache Memory',
                                    value           => $values[5],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Inactive  Memory',
                                    value           => $values[6],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Memory',
                                    name            => 'Active Virtual Memory',
                                    value           => $values[7],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Swap',
                                    name            => 'Memory Read/s',
                                    value           => $values[8],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'Swap',
                                    name            => 'Memory Write/s',
                                    value           => $values[9],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'IO',
                                    name            => 'Blocks Read/s',
                                    value           => $values[10],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'IO',
                                    name            => 'Blocks Write/s',
                                    value           => $values[11],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'System',
                                    name            => 'Interrupts/s',
                                    value           => $values[12],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'System',
                                    name            => 'Context Switches/s',
                                    value           => $values[13],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'CPU',
                                    name            => 'User Time %',
                                    value           => $values[14],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'CPU',
                                    name            => 'System Time %',
                                    value           => $values[15],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'CPU',
                                    name            => 'Idle Time %',
                                    value           => $values[16],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'CPU',
                                    name            => 'Wait Time %',
                                    value           => $values[17],
                                 );
    Wily::PrintMetric::printMetric( type            => 'PerIntervalCounter',
                                    resource        => 'rhelVMSTAT',
                                    subresource     => 'CPU',
                                    name            => 'Stolen Time %',
                                    value           => $values[18],
                                 );
}

