#!/usr/bin/perl
=head1 NAME

 rhelDiskStats.pl

=head1 SYNOPSIS

 IntroscopeEPAgent.properties configuration

 introscope.epagent.plugins.stateless.names=DISKSTATS
 introscope.epagent.stateless.DISKSTATS.command=perl <epa_home>/epaplugins/rhel/rhelDiskStats.pl [/filesystem1 /filesystem2 ...]
 introscope.epagent.stateless.DISKSTATS.delayInSeconds=15

=head1 DESCRIPTION

 The program will create two nodes --
 Device, which provides metrics by device name
 Disk, which provides metrics by mount point

 To see help information:

 perl <epa_home>/epaplugins/rhel/rhelDiskStats.pl --help

 or run with no commandline arguments.

 To test against sample output, use the DEBUG flag:

 perl <epa_home>/epaplugins/rhel/rhelDiskStats.pl --debug

=head1 CAVEATS

 I've noticed a weird bug when attempting to filter on only root filesystem "/".
 I don't think you'll ever want to do this, but just know that it doesn't work.

=head1 AUTHOR

 Hiko Davis, Principal Services Consultant, CA Technologies

=head1 COPYRIGHT

 Copyright (c) 2011-2014

 This plug-in is provided AS-IS, with no warranties, so please test thoroughly!

=cut

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/lib/perl", "$FindBin::Bin/../lib/perl");
use Wily::PrintMetric;

use Getopt::Long;


sub usage {
    print "Unknown option: @_\n" if ( @_ );
    print "usage: $0 [/filesystem1 /filesystem2 ...] [--help|-?] [--debug]\n\n";
    print "\tAdding a filesystem to the commandline will cause the program to\n";
    print "\tonly report metrics for the specified device and/or disk.\n";
    exit;
}

my ($help, $debug);
&usage if ( not GetOptions( 'help|?' => \$help,
                            'debug!' => \$debug,
                          )
            or defined $help );

# get the mounted disks specified on the command line
my $mountedDisksRegEx = '.'; # default is match all
if ( scalar(@ARGV) > 0 ) {
    foreach my $item ( @ARGV ) {
        if ( $item eq $debug ) { next; } else {
            $mountedDisksRegEx = join('|', @ARGV);
        }
    }
}

my ($iostatCommand, @iostatResults);
my ($dfCommand, @dfResults);

if ( $debug ) {
    # use here-docs for command results
    @iostatResults = <<"EOF" =~ m/(^.*\n)/mg;
Linux 2.6.18-128.el5 (xxxxx)        03/22/2011

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda               3.52        13.12        83.98  109986042  703796236
sda1              0.00         0.09         0.00     790834       6354
sda2              3.52        13.03        83.98  109186080  703789882
EOF

    @dfResults = <<"EOF" =~ m/(^.*\n)/mg;
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mapper/VolGroup00-LogVol00
                       5078656    455620   4360892  10% /
/dev/mapper/VolGroup00-lv_var
                       2031440    251980   1674604  14% /var
/dev/mapper/VolGroup00-lv_opt
                       2031440    852272   1074312  45% /opt
/dev/mapper/VolGroup00-lv_home
                       2031440     97196   1829388   6% /home
/dev/mapper/VolGroup00-lv_tmp
                       1236864    469836    703136  41% /tmp
/dev/mapper/VolGroup00-lv_usr
                       4411048   3083976   1100996  74% /usr
/dev/mapper/VolGroup00-lv_audit
                         63461      5403     54782   9% /audit
/dev/sda1               101086     15564     80303  17% /boot
tmpfs                  2987952         0   2987952   0% /dev/shm
EOF

} else {
    # iostat command for Linux disks
    $iostatCommand = 'iostat -d';
    # Get the device stats
    @iostatResults = `$iostatCommand`;
    # df command for RHEL
    $dfCommand = 'df -k';
    # Get the disk stats
    @dfResults = `$dfCommand`;
}


for my $l ( 3..$#iostatResults ) {
    chomp $iostatResults[$l]; # remove trailing new line
    my @deviceStats = split (/\s+/, $iostatResults[$l]);
    my $deviceName = $deviceStats[0];

    # if the user specified this device on the command line.
    next if $deviceName !~ /$mountedDisksRegEx/i;

    # report iostats
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Device',
                                    subresource => $deviceName,
                                    name        => 'Blk_wrtn',
                                    value       => int ($deviceStats[5]),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Device',
                                    subresource => $deviceName,
                                    name        => 'Blk_read',
                                    value       => int ($deviceStats[4]),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Device',
                                    subresource => $deviceName,
                                    name        => 'Blk_wrtn/s',
                                    value       => int ($deviceStats[3]),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Device',
                                    subresource => $deviceName,
                                    name        => 'Blk_read/s',
                                    value       => int ($deviceStats[2]),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Device',
                                    subresource => $deviceName,
                                    name        => 'tps',
                                    value       => int ($deviceStats[1]),
                                  );
}


my $h = 0;
my @holdVal;
for my $i ( 1..$#dfResults ) {
    chomp $dfResults[$i]; # remove trailing new line
    my @dfStats = split (/\s+/, $dfResults[$i]);
    my $fsName = $dfStats[0];
    my $diskName = $dfStats[5];

    # if line is just the filesystem, hold until next loop
    if ( not defined $diskName ) {
        $holdVal[$i] = $fsName;
        $h++;
        next;
    }

    # check to see if the user specified this disk on the command line
    next if $diskName !~ /$mountedDisksRegEx/i;

    # report the df stats
    # chop gets rid of '%' in the capacity metric
    chop $dfStats[4];
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Disk',
                                    subresource => $diskName,
                                    name        => 'Used Disk Space (%)',
                                    value       => $dfStats[4],
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Disk',
                                    subresource => $diskName,
                                    name        => 'Free Disk Space (MB)',
                                    value       => int ($dfStats[3] / 1024),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Disk',
                                    subresource => $diskName,
                                    name        => 'Used Disk Space (MB)',
                                    value       => int ($dfStats[2] / 1024),
                                  );
    Wily::PrintMetric::printMetric( type        => 'IntCounter',
                                    resource    => 'Disk',
                                    subresource => $diskName,
                                    name        => 'Total Disk Space (MB)',
                                    value       => int ($dfStats[1] / 1024),
                                  );
    if ($h >= 1) {
        Wily::PrintMetric::printMetric( type        => 'StringEvent',
                                        resource    => 'Disk',
                                        subresource => $diskName,
                                        name        => 'Filesystem',
                                        value       => $holdVal[$i - 1],
                                      );
    } else {
        Wily::PrintMetric::printMetric( type        => 'StringEvent',
                                        resource    => 'Disk',
                                        subresource => $diskName,
                                        name        => 'Filesystem',
                                        value       => $dfStats[0],
                                      );
    }
$h=0;
}
