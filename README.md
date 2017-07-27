# EPAgent Plugins for RHEL

The EPAgent Plug-ins for RHEL is a set of plug-ins for monitoring the Red Hat Enterprise Linux operating system and application processes (specifically IBM WebSphere Application Server).

rhelDiskStats.pl - gathers I/O statistics for mount points.  
rhelSar.pl - gathers per CPU/core statistics.  
rhelVmStat.pl - gathers memory and some CPU statistics.  
psWASforLinux.pl - gathers usage statistics from WebSphere processes.  
rhelMpStat.pl - gathers per-processor statistics  

## Dependencies
Tested with CA APM 9.7.1/10.5.2 EM, EPAgent 9.7.1/10.5.2, RHEL 6.x/7.3, and Perl 5.16/5.22.

## Known Issues
There have been discussions about the reporting of CPU statistics when running on System z | z/Linux. We are currently looking into alternatives to getting this information for your use.

# Licensing
FieldPacks are provided under the Apache License, version 2.0. See [Licensing](https://www.apache.org/licenses/LICENSE-2.0).

# Prerequisite
An installed and configured EPAgent.

Find the version 9.6 to 10.x documentation on [the CA APM documentation wiki.](https://docops.ca.com)

# Install and Configure EPA Plug-ins for RHEL

1. Extract the plug-ins to \<*EPAgent_Home*\>/epaplugins.
2. Configure the IntroscopeEPAgent.properties file in \<*EPAgent_Home*\> by adding these stateless plug-in properties:

    introscope.epagent.plugins.stateless.names=DISKSTAT,SAR,PSWAS,VMSTAT,MPSTAT (can be appended to a previous entry)  
    introscope.epagent.stateless.DISKSTAT.command=perl <epa_home>/epaplugins/rhel/rhelDiskStats.pl  
    introscope.epagent.stateless.DISKSTAT.delayInSeconds=900  
    introscope.epagent.stateless.PSWAS.command=perl <epa_home>/epaplugins/rhel/psWASforLinux.pl  
    introscope.epagent.stateless.PSWAS.delayInSeconds=900  
    introscope.epagent.stateless.SAR.command=perl <epa_home>/epaplugins/rhel/rhelSar.pl  
    introscope.epagent.stateless.SAR.delayInSeconds=900  
    introscope.epagent.stateless.VMSTAT.command=perl <epa_home>/epaplugins/rhel/rhelVmStat.pl  
    introscope.epagent.stateless.VMSTAT.delayInSeconds=900  
    introscope.epagent.stateless.MPSTAT.command=perl <epa_home>/epaplugins/rhel/rhelMpStat.pl  
    introscope.epagent.stateless.MPSTAT.delayInSeconds=900

3. PSWAS requires that you know the tab location of the WAS application name in the 'ps' output. It is recommended that you speak with your WAS administrator about standardizing the location of that property to ensure consistent results. Adjust the value of '$psCommand' at line 19 of the program.

# Use EPAgent Plug-ins for RHEL
Start the EPAgent using the provided control script in \<*EPAgent_Home*\>/bin.

# Debug and Troubleshoot
Update the root logger in \<epa_home\>/IntroscopeEPAgent.properties from INFO to DEBUG, then save. No need to restart the JVM.
You can also manually execute the plugins from a console and use perl's built-in debugger.

# Limitations
There have been discussions about CPU statistics reporting when running on System z | z/Linux. We are monitoring this situation to provide you with information as it becomes available.

# Support
This document and plug-in are made available from CA Technologies. They are provided as examples at no charge as a courtesy to the CA APM Community at large. This plug-in might require modification for use in your environment. However, this plug-in is not supported by CA Technologies, and inclusion in this site should not be construed to be an endorsement or recommendation by CA Technologies. This plug-in is not covered by the CA Technologies software license agreement and there is no explicit or implied warranty from CA Technologies. The plug-in can be used and distributed freely amongst the CA APM Community, but not sold. As such, it is unsupported software, provided as is without warranty of any kind, express or implied, including but not limited to warranties of merchantability and fitness for a particular purpose. CA Technologies does not warrant that this resource will meet your requirements or that the operation of the resource will be uninterrupted or error free or that any defects will be corrected. The use of this plug-in implies that you understand and agree to the terms listed herein.
Although this plug-in is unsupported, please let us know if you have any problems or questions. You can add comments to the CA APM Community site so that the author(s) can attempt to address the issue or question.
Unless explicitly stated otherwise this plug-in is only supported on the same platforms as the CA APM Java agent.

# Change Log
Changes for each version of the field pack.

Version | Author | Comment
--------|--------|--------
1.0 | Hiko Davis | First bundled version of the field packs.
1.1 | Hiko Davis | Added MPSTAT plugin.
1.2 | Hiko Davis | Updated rhelDiskStats.pl to handle blank line in iostat output.
1.3 | Hiko Davis | rhelDiskStats, rhelMpStat, rhelVmStat (non-numeric values); rhelSar (typo line 114);  and placement of program under epaplugins.
1.4 | Hiko Davis | fixed README format issue; updated rhelDiskStats to handle large volume sizes.
1.5 | Hiko Davis | Updated README for marketplace.
1.6 | Hiko Davis | Updated README for marketplace.

## Support URL
[https://github.com/htdavis/ca-apm-fieldpack-epa-rhel](https://github.com/htdavis/ca-apm-fieldpack-epa-rhel)

## Short Description
Monitor RHEL OS

## Categories
Server Monitoring
