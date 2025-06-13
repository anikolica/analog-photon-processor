#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15 Oct 2013
#                                                     
#######################################################

source ../scripts/variables.tcl

## and Decoupling caps -ncd
#capacitance in fF
#addDeCapCellCandidates DECAP_CG 275 

# MUST CHECK cap value of this decap!!! -ncd
#addDeCapCellCandidates  DCAP64BWP7THVT 275
addDeCapCellCandidates  DCAP32 275


## add 1941 decaps -ncd
#addDeCap -totCap 6000 -cells DCAP64BWP7THVT  -area 0 0  1200 1200 
#addDeCap -totCap 240000 -cells DCAP64  -area 0 0  1730 1730 

## about 20 decaps
#addDeCap -totCap 5000 -cells DCAP32  -area 0 0  1730 1730 
## about 2000 decaps
#addDeCap -totCap 500000 -cells DCAP32  -area 0 0  1730 1730 
## about 4000 
addDeCap -totCap 1000000 -cells DCAP32  -area 0 0  1730 1730 



##

## DCAP64BWP7THVT DCAP32BWP7THVT DCAP16BWP7THVT DCAP8BWP7THVT DCAP4BWP7THVT

## put this in import.tcl -ncd
#sroute -connect { padPin } -layerChangeRange { M2 AP } -padPinPortConnect { allPort allGeom } 

#setSrouteMode -signalPinAsPG true
#sroute -connect { blockPin padPin  } -nets { AVDD AVSS } 

## put this in import.tcl -ncd
#sroute -connect {corePin}


#sroute -nets { VDD }
#sroute -jogControl { preferWithChanges sameLayer } -nets { GND }
win

## -ncd
#if {$MIXED_TRACKS} { addWellTap -cell TAPCELLBWP7T -maxGap 14 -inRowOffset 7 -startRowNum 1 -prefix WELLTAP -checkerBoard -powerDomain core7thvt }
#if {$ONLY_7TRACKS} { addWellTap -cell TAPCELLBWP7T -maxGap 14 -inRowOffset 7 -startRowNum 1 -prefix WELLTAP -checkerBoard }
if {$MIXED_TRACKS} { addWellTap -cell TAPCELLBWP7T -cellInterval 14 -inRowOffset 7 -startRowNum 1 -prefix WELLTAP -checkerBoard -powerDomain core7thvt }
if {$ONLY_7TRACKS} { addWellTap -cell TAPCELLBWP7T -cellInterval 14 -inRowOffset 7 -startRowNum 1 -prefix WELLTAP -checkerBoard }

win
setPlaceMode -reset
setPlaceMode -congEffort high -timingDriven 1 -modulePlan 1  -clkGateAware 0 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 1 -placeIOPins 1 -moduleAwareSpare 0 -checkPinLayerForAccess {  1 } -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

setTrialRouteMode -highEffort false -floorPlanMode false -detour true -maxRouteLayer $preferredTopRoutingLayer -minRouteLayer $bottomRoutingLayer -handlePreroute true -autoSkipTracks false -handlePartition false -handlePartitionComplex false -useM1 false -keepExistingRoutes false -ignoreAbutted2TermNet false -pinGuide true -honorPin false -selNet {} -selNetOnly {} -selMarkedNet false -selMarkedNetOnly false -ignoreObstruct false -PKS false -updateRemainTrks false -ignoreDEFTrack false -printWiresOnRTBlk false -usePagedArray false -routeObs true -routeGuide {} -blockageCostMultiple 1 -maxDetourRatio 0

setOptMode  -bufferAssignNets true
setOptMode -allEndPoints true

catch { defIn ../../syn/output/scan.def }
#scanTrace -compLogic -verbose
scanTrace

setDrawView place
placeDesign  -prePlaceOpt
scanReorder -allowSwapping -highEffort -skipTwoPinCell
setTieHiLoMode -maxDistance 20

if {$ONLY_9TRACKS} {addTieHiLo -cell "TIEH TIEL" }
if {$ONLY_7TRACKS} {addTieHiLo -cell "TIEHBWP7THVT TIELBWP7THVT" }
if {$MIXED_TRACKS} { 
	addTieHiLo -cell "TIEH TIEL" -powerDomain core9t
	addTieHiLo -cell "TIEHBWP7THVT TIELBWP7THVT" -powerDomain core7thvt
}

win
saveNetlist ../output/place.v

## -ncd
setOaxMode -allowBitConnection true

# dont save to OA yet -ncd
saveDesign -cellview "output [dbGet top.name] place " -enc ../output/place.enc
## 
