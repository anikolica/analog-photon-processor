#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15/10/2013
#                                                     
#######################################################

set oaLibName mklib
set CORE_CHIP CHIP
#set CORE_CHIP MACRO

# turn on ONLY_9TRACKS if you are only using the tcbn65lp library
set ONLY_9TRACKS 1
# turn on ONLY_7TRACKS if you are only using the tcbn65lpbwp7thvt library
set ONLY_7TRACKS 0
# turn on MIXED_TRACKS if you are using both libraries -> this requires a CPF file
set MIXED_TRACKS 0

#set numCpu 4
set numCpu 16
setDesignMode -process 65
#setReleaseMultiCpuLicense 0

# -ncd
#setMultiCpuUsage -cpuAutoAdjust true -localCpu $numCpu -keepLicense true
setMultiCpuUsage -keepLicense true -localCpu max

#setMultiCpuUsage -numThreads $numCpu -numHosts 1 -superThreadsNumThreads $numCpu -superThreadsNumHosts 1
#specifyScanChain test_scan -start SCAN_IN -stop SCAN_OUT
#specifyScanChain test_scan -start SCAN_IN_pad/Z -stop SCAN_OUT_pad/A


## database is empty at this time so topRoutingLayer gets set to "0" -ncd

#set topRoutingLayer [expr [llength [dbGet -p head.layers.type routing]] - 1]
set topRoutingLayer 7

set preferredTopRoutingLayer [expr $topRoutingLayer - 2]
set clockTopRoutingLayer 4
set clockBottomRoutingLayer 3
set bottomRoutingLayer 1
