## New CCOpt method for creating clock trees -ncd
## Date: 12/2017



source ../scripts/variables.tcl

setPlaceMode -reset

## This followed by source fix_antennal works! why??## -ncd
#### FORCE clocktree to use metal 4 -ncd
#set el::clockTopRoutingLayer 4

setPlaceMode -congEffort medium -timingDriven 1 -clkGateAware 0 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 1 -placeIOPins 0 -moduleAwareSpare 0  -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0



## This  is obselete now: use setRouteMode instead -ncd 2-25
#setTrialRouteMode -highEffort false -floorPlanMode false -detour true -maxRouteLayer $preferredTopRoutingLayer -minRouteLayer $bottomRoutingLayer -handlePreroute true -autoSkipTracks false -handlePartition false -handlePartitionComplex false -useM1 false -keepExistingRoutes false -ignoreAbutted2TermNet false -pinGuide true -honorPin false -selNet {} -selNetOnly {} -selMarkedNet false -selMarkedNetOnly false -ignoreObstruct false -PKS false -updateRemainTrks false -ignoreDEFTrack false -printWiresOnRTBlk false -usePagedArray false -routeObs true -routeGuide {} -blockageCostMultiple 1 -maxDetourRatio 0

setRouteMode -earlyGlobalEffortLevel standard



#setNanoRouteMode  -drouteOptimizeUseMultiCutVia true
setNanoRouteMode  -droutePostRouteSwapVia none
#setNanoRouteMode  -drouteStartIteration default


#### mess with these
setNanoRouteMode  -routeInsertAntennaDiode false
#setNanoRouteMode  -routeInsertAntennaDiode false

setNanoRouteMode  -routeInsertDiodeForClockNets false
#  setNanoRouteMode  -routeInsertDiodeForClockNets true

## THIS LOOKS INTERESTING 
#-routeReserveSpaceForMultiCut {true | false}

##     Antenna Diode name: FGTIE_G_A
#setNanoRouteMode  -routeAntennaCellName {}
setNanoRouteMode  -routeAntennaCellName ANTENNA


setNanoRouteMode  -drouteFixAntenna true


## -ncd
#setNanoRouteMode  -routeBottomRoutingLayer 1
#setNanoRouteMode  -routeTopRoutingLayer M8

setDesignMode -bottomRoutingLayer $bottomRoutingLayer
setDesignMode -topRoutingLayer $topRoutingLayer






setNanoRouteMode  -drouteEndIteration default
setNanoRouteMode  -droutePostRouteWidenWireRule NA

setNanoRouteMode  -routeWithTimingDriven false
setNanoRouteMode  -routeWithSiDriven false
#setNanoRouteMode  -drouteViaOnGridOnly true

setNanoRouteMode  -drouteOnGridOnly via   
setNanoRouteMode  -routeStrictlyHonorNonDefaultRule true


## add "-routeLeafTopPreferredLayer -routeLeafBottomPreferredLayer 2" -ncd 2019 tor 
#setCTSMode   -topPreferredLayer M6 -bottomPreferredLayer M3 -routeNonDefaultRule {} -useLefACLimit false -routePreferredExtraSpace 1 -opt true -optAddBuffer true -moveGate true -useHVRC true -fixLeafInst true -fixNonLeafInst true -verbose false -reportHTML false -addClockRootProp false -nameSingleDelim false -honorFence false -useLibMaxFanout false -useLibMaxCap false -routeLeafTopPreferredLayer 6 -routeLeafBottomPreferredLayer 3





#setOptMode -effort high -powerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist true -setupTargetSlack 0.35 -holdTargetSlack 0.20 -maxDensity 0.95 -drcMargin 0.1 -usefulSkew false 

## dont simplify netlist 2020 -ncd
#setOptMode -effort high -powerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist false -setupTargetSlack 0.35 -holdTargetSlack 0.20 -maxDensity 0.95 -drcMargin 0.1 -usefulSkew false -fixFanoutLoad true -maxLength 500 -preserveModuleFunction true -restruct false

##  Backoff on hold time, and setup time, usefulSkew true  2021 -ncd
#setOptMode -effort high -powerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist false -setupTargetSlack 0.35 -holdTargetSlack 0.25 -maxDensity 0.95 -drcMargin 0.1 -usefulSkew true -fixFanoutLoad true -maxLength 500 -preserveModuleFunction true -restruct false


##  add -usefulSkewCCOpt extreme    2021-06-13 -ncd
setOptMode -effort high -powerEffort none -yieldEffort none -reclaimArea true -simplifyNetlist false -setupTargetSlack 0.35 -holdTargetSlack 0.25 -maxDensity 0.95 -drcMargin 0.1 -usefulSkew true -fixFanoutLoad true -maxLength 500 -preserveModuleFunction true -restruct false  -usefulSkewCCOpt extreme

# timing optimization
stop

optDesign -preCTS -drv -outDir ../report -prefix preCTS
win
catch { check_write_layout_and_stop "pre_cts_opt" }


############################ NEW METHOD ##############################


#### LIMIT CTS buffers/inverters to weaker values to reduce clock tree fanout -ncd
## Specify Buffers
#set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E BUFFER_F BUFFER_H BUFFER_I BUFFER_J BUFFER_K BUFFER_L BUFFER_M BUFFER_N BUFFER_O  CLKI_I CLKI_K CLKI_M CLKI_O CLKI_Q CLK_I CLK_K CLK_M CLK_O CLK_Q}



set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E CLKI_I CLK_Q} ;# GOLDEN 
#set_ccopt_property buffer_cells { CLK_Q BUFFER_E} ;# TRIAL 


#set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E CLKI_I} -ncd Never comes back
#set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E CLKI_I CLK_Q} -ncd leaves 12 antennas
#set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E CLKI_I CLK_M} -ncd leaves 24 antennas
#set_ccopt_property buffer_cells {BUFFER_C BUFFER_D BUFFER_E CLKI_I CLKI_K CLKI_M CLKI_O CLKI_Q CLK_I CLK_K CLK_M CLK_O CLK_Q} -ncd leaves 28 antennas

## Specify Inverters
set_ccopt_property inverter_cells { INVERTBAL_E INVERT_A INVERT_C INVERT_D INVERT_E } ;# GOLDEN
#set_ccopt_property inverter_cells {  INVERT_E } ;# TRIAL



#set_ccopt_property inverter_cells { INVERTBAL_E INVERTBAL_J INVERT_A INVERT_C INVERT_D INVERT_E INVERT_F INVERT_H INVERT_I INVERT_J INVERT_K INVERT_L INVERT_M INVERT_N INVERT_O}
#set_ccopt_property inverter_cells { INVERTBAL_E INVERT_A INVERT_C INVERT_D INVERT_E } -ncd This works
#set_ccopt_property inverter_cells { INVERTBAL_E INVERT_A INVERT_C INVERT_D INVERT_E INVERT_F INVERT_H INVERT_I  }


## Specify transitions and skew 
set_ccopt_property target_max_trans 225ps
set_ccopt_property target_skew 225ps

## Print out clocks
get_ccopt_clock_trees *   

## Create clock spec that can be edited before sourcing 
#create_ccopt_clock_tree_spec -file myCLOCKspec -keep_all_sdc_clocks -views viewList
create_ccopt_clock_tree_spec -file myCLOCKspec -keep_all_sdc_clocks 


## Uncomment this to update clock spec with a 160MHzABC clock group -2021
exec cat myCLOCKspec clockSkewUpdateSpec_2021 >  myCLOCKspec2
 
## source clock spec
source myCLOCKspec2
######source myCLOCKspec_addSkewGroup_ncd

## Clock the design
ccopt_design 


##NEW -ncd
## check for hold violations
timeDesign -postCTS -hold -outDir $el::timingReportDir -prefix postCTS
## fix any hold violations
optDesign -postCTS -hold -outDir  $el::timingReportDir  -prefix postCTS_OPT

#
saveDesign $el::outputDir/cts.enc


