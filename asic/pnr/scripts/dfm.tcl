#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15/10/2013
#                                                     
#######################################################

source ../scripts/variables.tcl


# via optimization 
setNanoRouteMode  -drouteFixAntenna false
setNanoRouteMode  -routeInsertAntennaDiode false
setNanoRouteMode  -droutePostRouteSwapVia multiCut
setNanoRouteMode  -drouteUseMultiCutViaEffort high


## NOT VALLID ANY MORE -ncd
#setNanoRouteMode -droutePostRouteMinimizeViaCount false
#optDesign -postRoute -viaOpt

setNanoRouteMode  -routeWithEco true
#setNanoRouteMode  -drouteMinimizeViaCount false
setNanoRouteMode -routeReserveSpaceForMultiCut false
setNanoRouteMode -routeWithViaInPin false
#setNanoRouteMode -drouteMinimizeViaCount true
#setNanoRouteMode -droutePostRouteMinimizeViaCount true
#setNanoRouteMode -routeConcurrentMinimizeViaCountEffort high


routeDesign -globalDetail -viaOpt
setNanoRouteMode  -droutePostRouteSwapVia none
win
# fillers
setFillerMode -reset
setFillerMode -corePrefix FILLER -createRows 1 -doDRC 1  -ecoMode 0
#DCAP16 DCAP8 DCAP4 DCAP2 DCAP1


## remove DCAP filler -ncd
#if {$ONLY_9TRACKS} {addFiller -cell DCAP64 DCAP32   FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER}
if {$ONLY_9TRACKS} {addFiller -cell FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER}


if {$ONLY_7TRACKS} {
	#addFiller -cell TAPCELLBWP7T  -util 0.1

## dont allow extra DCAPs for now until passing LVS -ncd
#	addFiller -cell DCAP64BWP7THVT DCAP32BWP7THVT FILL64BWP7THVT FILL32BWP7THVT FILL16BWP7THVT FILL8BWP7THVT FILL4BWP7THVT FILL2BWP7THVT FILL1BWP7THVT -prefix FILLER
	addFiller -cell FILL64BWP7THVT FILL32BWP7THVT FILL16BWP7THVT FILL8BWP7THVT FILL4BWP7THVT FILL2BWP7THVT FILL1BWP7THVT -prefix FILLER

}


if {$MIXED_TRACKS} {
	addFiller -cell DCAP64 DCAP32   FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER -powerDomain core9t
	#addFiller -cell TAPCELLBWP7T  -util 0.1 -powerDomain core7thvt
	addFiller -cell DCAP64BWP7THVT DCAP32BWP7THVT FILL64BWP7THVT FILL32BWP7THVT FILL16BWP7THVT FILL8BWP7THVT FILL4BWP7THVT FILL2BWP7THVT FILL1BWP7THVT -prefix FILLER -powerDomain core7thvt
}

win

# clean up any DRC violations -ncd 2025
ecoRoute -target

stop


## MUST EDIT makePins according to pad names in design  -ncd
source ../scripts/makePins.tcl

# Remove macro routing blockages before adding fill
deleteRouteBlk -name myRtBlks
#source ../scripts/addMetalFill.tcl
win

# signoff timing analysis
#timeDesign -si -signoff -pathReports -drvReports -slackReports -numPaths 50 -prefix signoff -outDir ../report/timingReports
#timeDesign -si -signoff -hold -pathReports -slackReports -numPaths 50 -prefix signoff -outDir ../report/timingReports
#set_analysis_view -setup {view_max view_typ} -hold {view_min view_max}

write_sdf -min_view av_min -max_view av_max -typ_view av_typ  ../output/dfm.sdf


# verifications
verifyGeometry -noOverlap -area [split [join [dbGet top.fPlan.iobox]]]
verifyConnectivity -type all 
verifyProcessAntenna

#source ../scripts/changeFillLayer.tcl

saveNetlist ../output/dfm.v
#saveDesign ../output/dfm.enc
saveDesign -cellview "output [dbGet top.name] dfm " -enc ../output/dfm.enc


## This is dangerous -ncd 2025
##exec cp -r ../scripts/emptyLib $oaLibName
## proper way to copy library -ncd
#catch {exec rm -r $oaLibName}
#catch {exec ../scripts/del_mklib.sh cds.lib}
#createLib mklib -copyTech output



##stop

## MAKE LAYOUT FOR VIRTUOSO -ncd 2025
### saveOaDesign $el::oaLibName [dbGet top.name] dfm
#saveOaDesign $oaLibName [dbGet top.name] dfm

## This will generate virtuoso abstract view -ncd 2025
setOaxMode -allowTechUpdate true
update_oa_lib mklib -tech_attach_to_reference  ; # give permission to attach new vias to mklib instead of tsmcN65 -ncd 2025   
##saveDesign -cellview {mklib APP  dfm}  ; # save layout directly to virtuoso as abstracts XX CRASHES!



## This will never work to export layout to Virtuoso since it requires the techfile to be writable -ncd 2025
##saveDesign -cellview " $oaLibName [dbGet top.name] dfm "

# Instead, create Virtuoso Layout by exporting a DEF file out of Innovus and into Virtuoso:
set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
defOut -floorplan -netlist -routing APP.def


### output directory must exist; This creates a DEF file that can import the layout into Virtuoso  -ncd  2015
#if {$CORE_CHIP != "CHIP"} { saveModel -dir ../output/layout }
if {$CORE_CHIP != "CHIP"} { saveModel -dir ../output }



if {$ONLY_9TRACKS} { 
#saveNetlist lvs.v -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA -includePhysicalCell {DCAP64 DCAP32 } 
## dont write out dcaps, and later manually in virtuosos - too much clutter -ncd
	saveNetlist lvs.v -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA  
}


if {$ONLY_7TRACKS} { 
	saveNetlist lvs.v -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA -includePhysicalCell {DCAP64BWP7THVT  DCAP32BWP7THVT}
}

if {$MIXED_TRACKS} { 
	saveNetlist lvs.v -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA -includePhysicalCell {DCAP64 DCAP32 DCAP64BWP7THVT  DCAP32BWP7THVT}
}

#stop
## reconnect VSSPST/VDDPST to pads complements of Paul: 
exec ../scripts/foo.sh lvs.v


exec ../scripts/lvs_postprocess.py $CORE_CHIP <lvs.v >lvs_pp.v

## THIS NO LONGER WORKS since it requires write permission on techfile -ncd 2025.
## Instead import Layout into Virtuoso using a DEF file -ncd

#puts "Making final virtuoso layout view... (check makeLayout.log for details)"

defOut -floorplan -netlist -routing dfm.def
catch {exec rm -rf $oaLibName/[dbGet top.name]/layout} 
#oaOut $oaLibName [dbGet top.name] layout -leafViewNames layout -noConnectivity ; # create dfm view with abstracts -ncd 20225
##exec defin -def dfm.def -lib $oaLibName -cell [dbGet top.name] -view dfm -masterLibs tcbn65lp_lef -overwrite -log defin.log

exec defin -def dfm.def -lib $oaLibName -cell [dbGet top.name] -view dfm -overwrite -log defin.log
catch {exec virtuoso -nograph -log makeLayout.log -replay ../scripts/makeLayout.il}


puts "Making final virtuoso schematic view... (check verilogIn.log for details)"
catch {exec rm -rf $oaLibName/*/symbol}
catch {exec rm -rf $oaLibName/*/schematic}
catch {exec rm -rf $oaLibName/*/functional}

## ihdlParamFile must contain user library also -ncd
catch {exec ihdl +DUMB_SCH -PARAM ../scripts/ihdlParamFile lvs_pp.v}
puts "Done."
puts "Remember to put your chipring/chipedge in virtuoso and run DRC/LVS :)"
puts "You can run now DRC/LVS (w/o chipring!) with drc.tcl and lvs.tcl."
if {$CORE_CHIP != "CHIP"} {puts "You can find LEF/abstract and timing/.lib for top-level use in ../output/layout/library/"}
