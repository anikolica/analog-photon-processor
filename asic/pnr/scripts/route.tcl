#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15/10/2013
#                                                     
#######################################################

source ../scripts/variables.tcl

if {$ONLY_7TRACKS} { generateTracks -m1HOffset 0.1 }

setPlaceMode -reset

setPlaceMode -congEffort medium -timingDriven 1 -clkGateAware 0 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 1 -placeIOPins 0 -moduleAwareSpare 0 -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

setTrialRouteMode -highEffort false -floorPlanMode false -detour true -maxRouteLayer $preferredTopRoutingLayer -minRouteLayer $bottomRoutingLayer -handlePreroute true -autoSkipTracks false -handlePartition false -handlePartitionComplex false -useM1 false -keepExistingRoutes false -ignoreAbutted2TermNet false -pinGuide true -honorPin false -selNet {} -selNetOnly {} -selMarkedNet false -selMarkedNetOnly false -ignoreObstruct false -PKS false -updateRemainTrks false -ignoreDEFTrack false -printWiresOnRTBlk false -usePagedArray false -routeObs true -routeGuide {} -blockageCostMultiple 1 -maxDetourRatio 0


#setNanoRouteMode  -drouteOptimizeUseMultiCutVia true
setNanoRouteMode  -droutePostRouteSwapVia true

if {$MIXED_TRACKS} { setNanoRouteMode -routeHonorPowerDomain true }
setNanoRouteMode  -droutePostRouteSwapVia none
setNanoRouteMode  -drouteStartIteration default
setNanoRouteMode  -routeInsertAntennaDiode false
setNanoRouteMode  -routeInsertDiodeForClockNets false
setNanoRouteMode  -routeAntennaCellName {}
setNanoRouteMode  -drouteFixAntenna true
setNanoRouteMode  -routeBottomRoutingLayer $bottomRoutingLayer
setNanoRouteMode  -routeTopRoutingLayer $preferredTopRoutingLayer
setNanoRouteMode  -drouteEndIteration default
setNanoRouteMode  -droutePostRouteWidenWireRule NA
setNanoRouteMode  -routeWithTimingDriven false
setNanoRouteMode  -routeWithSiDriven false

#setNanoRouteMode  -drouteViaOnGridOnly true
setNanoRouteMode  -route_detail_on_grid_only via

setNanoRouteMode  -drouteOnGridOnly via   
setNanoRouteMode  -routeStrictlyHonorNonDefaultRule true

setNanoRouteMode -droutePostRouteSwapVia multicut
setNanoRouteMode -drouteUseMultiCutViaEffort high
setNanoRouteMode -routeReserveSpaceForMultiCut false
setNanoRouteMode -routeWithViaInPin false


##setNanoRouteMode -drouteMinimizeViaCount true
##setNanoRouteMode -droutePostRouteMinimizeViaCount true
setNanoRouteMode -routeConcurrentMinimizeViaCountEffort high

#stop

## Attempt to generate good Tracks for 9 metals and Vias -ncd
#generateTracks
#setGenerateViaMode -auto true
#generateVias -deleteViaBeforeGeneration all
#setNanoRouteMode -drouteAutoStop false
#setNanoRouteMode -routeTopRoutingLayer 6
## 



setCTSMode -specMultiMode true -traceDPinAsLeaf false -traceIoPinAsLeaf false -routeClkNet true -routeGuide true \
	-topPreferredLayer $clockTopRoutingLayer -bottomPreferredLayer $clockBottomRoutingLayer \
	-useLefACLimit false -routePreferredExtraSpace 1 -opt true -optAddBuffer true -moveGate true -useHVRC true \
	-fixLeafInst true -fixNonLeafInst true -verbose false -reportHTML false -addClockRootProp false \
	-nameSingleDelim false -honorFence false -useLibMaxFanout false -useLibMaxCap false

setOptMode -effort high -leakagePowerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist true -setupTargetSlack 0 -holdTargetSlack 0 -maxDensity 0.95 -drcMargin 0 -usefulSkew false
setCTSMode -powerAware true

## don't extact caps for SI analysis here -ncd 
setDelayCalMode -siAware false
## do extract caps for  SI analysis here
#setExtractRCMode -coupled true


# timing optimization
optDesign -preCTS  -drv
win
# clock tree generation

#addCTSCellList {CKBD0 CKBD1 CKBD12 CKBD16 CKBD2 CKBD20 CKBD24 CKBD3 CKBD4 CKBD6 CKBD8 CKND0 CKND1 CKND12 CKND16 CKND2 CKND20 CKND24 CKND3 CKND4 CKND6 CKND8}
#clockDesign -genSpecOnly Clock.ctstch



createClockTreeSpec  -file Clock.ctstch  -clkGroup
createClockTreeSpec  -file Clock.ctstch.default_mode  -clkGroup

clockDesign -specFile Clock.ctstch -outDir ../report/clock_report -fixedInstBeforeCTS
#set_clock_uncertainty 0 -from [all_clocks] -to [all_clocks]
win

# dont save to OA yet -ncd
saveDesign -cellview "output [dbGet top.name] postCTS" -enc ../output/postCTS.enc

timeDesign -postRoute -prefix postCTS -outDir ../report/timingReports -timingDebugReport
timeDesign -hold -postRoute -prefix postCTS -outDir ../report/timingReports -timingDebugReport

# timing optimization
optDesign -postCTS  -drv
win
# routing
setNanoRouteMode  -routeTopRoutingLayer $preferredTopRoutingLayer
routeDesign -globalDetail
win

# dont save to OA yet -ncd
#saveDesign -cellview "output [dbGet top.name] route_thin" -enc ../output/route_thin.enc

setNanoRouteMode  -routeTopRoutingLayer $topRoutingLayer
ecoroute
# analyze timing
timeDesign -postRoute -pathReports -drvReports -prefix pre_hold_fix -outDir ../report/timingReports -timingDebugReport
win
# optimization
setOptMode -effort high -leakagePowerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist true -setupTargetSlack 0.01 -holdTargetSlack 0.01 -maxDensity 0.95 -drcMargin 0 -usefulSkew false
optDesign -postRoute  -drv
optDesign -postRoute -hold
win

# antenna fix
setNanoRouteMode  -drouteFixAntenna true
setNanoRouteMode  -routeInsertAntennaDiode true
setNanoRouteMode  -routeInsertDiodeForClockNets true
setNanoRouteMode  -routeAntennaCellName ANTENNA
#setNanoRouteMode  -drouteViaOnGridOnly false
#setNanoRouteMode  -drouteOnGridOnly none
routeDesign -globalDetail
timeDesign -hold -postRoute -prefix postroute -outDir ../report/timingReports -timingDebugReport
timeDesign -postRoute -prefix postroute -outDir ../report/timingReports -timingDebugReport
load_timing_debug_report  ../report/timingReports/postroute.mtarpt.gz

saveNetlist ../output/route.v
#delayCal -sdf ../output/route.sdf -idealclock
#saveOaDesign $oaLibName [dbGet top.name] route

# dont save to OA yet -ncd
saveDesign -cellview "output [dbGet top.name] route" -enc ../output/route.enc

