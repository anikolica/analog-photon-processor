#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15 Oct 2013
#                                                     
#######################################################
############################
## defOut command: select object and then run this -ncd
## Note that defIn is pretty smart. It will compare objects being added
## and NOT add them if they already exist
##    defOut -routing -selected my.def
##    defIn my.def

#############################


source ../scripts/variables.tcl

#Space for global variables -ncd
namespace eval glv {}
set glv::PVS_QRC "/cad/Technology/TSMC650A/V1.7A_1/1p9m6x1z1u/PVS_QRC/QRC/"
set glv::LBS "/cad/Technology/TSMC650A/V1.7A_1/1p9m6x1z1u/PVS_QRC/QRC/"



# DEFINE ADDITIONAL USER LIBRARIES HERE  -ncd
set userLib "coldMPW_lib"
if {$ONLY_9TRACKS} {
	set init_oa_ref_lib "tcbn65lp  tpdn65lpnv2od3  tpan65lpnv2od3 tpbn65v $userLib"
	set init_mmmc_file ../scripts/mmmc.view
} 
if {$ONLY_7TRACKS} {
	set init_oa_ref_lib "tcbn65lpbwp7thvt tpdn65lpnv2od3 tpan65lpnv2od3 tpbn65v $userLib"
	set init_mmmc_file ../scripts/mmmc7t.view
}
if {$MIXED_TRACKS} {
	set init_oa_ref_lib "tcbn65lp tcbn65lpbwp7thvt tpdn65lpnv2od3  tpan65lpnv2od3 tpbn65v $userLib"
	set init_mmmc_file ../scripts/mmmc.view
}


## point to verilog file -ncd
set init_verilog ../../syn/output/r2g.v

## added VSSPST -ncd
set init_pwr_net {VDD  AVDD VDDPST VSSPST VDDPST! VSSPST! VDD! VSS!}

set init_assign_buffer 1
set conf_qxconf_file NULL
set init_import_mode { -keepEmptyModule 1 -treatUndefinedCellAsBbox 0}
set conf_qxlib_file NULL
set init_layout_view layout
set init_gnd_net {VSS  AVSS VSSPST}
set init_abstract_view abstract
getenv ENCOUNTER_CONFIG_RELATIVE_CWD
setDoAssign on


## -ncd
init_design




fit
setDrawView fplan
win

if {$MIXED_TRACKS} {
	loadCPF ../scripts/power.cpf
	commitCPF
}



## Ok import the design the old way -ncd
#loadConfig /tape/mitch_sim/cds_proto/tsmc/digital/pnr/scripts/oa.conf 0
#setImportMode -bufferTieAssign true


## these are not being supported in the future, use init_* cmds -ncd
#global rda_Input
#set rda_Input(import_mode) {-treatUndefinedCellAsBbox 0 -keepEmptyModule 1 }
#set rda_Input(ui_netlist) "../../syn/output/r2g.v"
#set rda_Input(ui_netlisttype) {Verilog}
#set rda_Input(ui_timingcon_file) "../../syn/output/r2g.sdc"
#setImportMode -bufferTieAssign true
#set rda_Input(ui_settop) {0}
#set rda_Input(ui_topcell) {}
#commitConfig
##



source ../scripts/variables.tcl

globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *

## add these -ncd
globalNetConnect VDDPST -type pgpin -pin VDDPST -inst *
globalNetConnect VSSPST -type pgpin -pin VSSPST -inst *

globalNetConnect VDD -type net -net VDD! 
globalNetConnect VSS -type net -net VSS! 
globalNetConnect VDDPST -type net -net VDDPST! 
globalNetConnect VSSPST -type net -net VSSPST! 


stop



if {$ONLY_7TRACKS} {setTieHiLoMode -maxDistance 20 -cell "TIEHBWP7THVT TIELBWP7THVT"}

#globalNetConnect AVDD -type pgpin -pin VDD -inst * -module analog -override
#globalNetConnect AVSS -type pgpin -pin GND -inst * -module analog -override

if {$CORE_CHIP == "CHIP"} {
	addInst -physical -cell PCORNER -inst corner1
	addInst -physical -cell PCORNER -inst corner2
	addInst -physical -cell PCORNER -inst corner3
	addInst -physical -cell PCORNER -inst corner4
	#loadIoFile ../scripts/corner.io

##NOTES
# PVDD1CDG = Vdd Pad for Core Power Supply
# PVSS1CDG = Vss pad for Core Ground Supply

# PVDD2CDG = Power Pad for I/O Power Supply
# PVSS2CDG = Ground Pad for I/O Ground Supply

# PVDD2POC = Power-on Control Power Pad for I/O Power Supply

# PVSS1ANA = Deditcated ground Suppy for PVDD1ANA

# PVDD2ANA = Dedicated power Supply to Internal macro with I/0 Voltage
# PVSS2ANA = Dedicated ground Supply for PVDD2ANA

# PVSS3CDG = Ground Pad for I/O and Core ground Supply
# PXOE1CDG = Crystal Oscillator Cell (High Enable, without Feedback Resistor)
# PXOE2CDG = Crystao Oscillator Cell (High Enable, with Feedback resistor)

# PRCUT = Power-cut cell between digital domain A and digital domain B 
#         with VSS shorted adn the rest of rails cut


## Power and Ground pads	
#	addInst -cell PRCUTA -inst break1
#	addInst -cell PRCUTA -inst break2

## Power/Gnd pads now driven by verilog -ncd
#        addInst -cell PVDD1CDG  -inst VDD1
#        addInst -cell PVDD1CDG  -inst VDD2
#        addInst -cell PVDD1CDG  -inst VDD3
#        addInst -cell PVDD1CDG  -inst VDD4
#        addInst -cell PVDD1CDG  -inst VDD5
#
#        addInst -cell PVSS1CDG  -inst VSS1
#        addInst -cell PVSS1CDG  -inst VSS2
#        addInst -cell PVSS1CDG  -inst VSS3
#        addInst -cell PVSS1CDG  -inst VSS4
#        addInst -cell PVSS1CDG  -inst VSS5
#        addInst -cell PVSS1CDG  -inst VSS6
#        addInst -cell PVSS1CDG  -inst VSS7
#        addInst -cell PVSS1CDG  -inst VSS8
#        addInst -cell PVSS1CDG  -inst VSS9
#        addInst -cell PVSS1CDG  -inst VSS10

## external driver rings VDDPST!, VSSPST!
#        addInst -cell PVDD2CDG  -inst VDDPST1
#        addInst -cell PVDD2CDG  -inst VDDPST2
#        addInst -cell PVDD2CDG  -inst VDDPST3
#        addInst -cell PVDD2CDG  -inst VDDPST4
#        addInst -cell PVDD2CDG  -inst VDDPST5
#
#        addInst -cell PVSS2CDG  -inst VSSPST1
#        addInst -cell PVSS2CDG  -inst VSSPST2
#        addInst -cell PVSS2CDG  -inst VSSPST3
#        addInst -cell PVSS2CDG  -inst VSSPST4
#        addInst -cell PVSS2CDG  -inst VSSPST5


## Clamps
#    globalNetConnect VDD -type pgpin -pin VDDESD -inst *
#    globalNetConnect VSS -type pgpin -pin VSSESD -inst *
#   globalNetConnect VDD -type net -pin VDDESD
#   globalNetConnect VSS -type net -pin VSSESD
#    addInst -cell PCLAMP1ANA  -inst CLAMP2c




#loadIoFile chip.save.io
 loadIoFile 	coldMPW.save.io

}




## adjusted density 0.85 --> 0.55 in floorPlan cmd -ncd
#set io2core 70
#if {$ONLY_7TRACKS} {
#
#
#	floorPlan -site core7T -r .5 .65 $io2core $io2core $io2core $io2core
#
#
#
#
#} else {
#	floorPlan -site core -r .6 .85 $io2core $io2core $io2core $io2core
#}
#

## SPECIAL floorplan (choose 'core' NOT 'core7T' if using standard tsmc cells) -ncd
  deselectAll
#  floorPlan -coreMarginsBy die -site core7T -d 1860 1860 130 130 130 130
   floorPlan -coreMarginsBy die -site core -d 1860 1860 130 130 130 130 -adjustToSite

  fit



if {$CORE_CHIP == "CHIP"} {
	addIoFiller -cell PFILLER20
	addIoFiller -cell PFILLER10
	addIoFiller -cell PFILLER5
	addIoFiller -cell PFILLER1
	addIoFiller -cell PFILLER05
	addIoFiller -cell PFILLER0005 -fillAnyGap

	
	# deleteInst pad_*  
	source ../scripts/addPads.tcl 
}




## Add rings around core area: 10 wide/5 space rings on M6/M5 -ncd 
addRing -skip_via_on_wire_shape Noshape -use_wire_group_bits 2 -use_interleaving_wire_group 1 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -use_wire_group 1 -type core_rings -jog_distance 2.0 -threshold 2.0 -nets {VDD VSS} -follow io -stacked_via_bottom_layer M1 -layer {bottom M5 top M5 right M6 left M6} -width 10 -spacing 5 -offset 10
uiSetTool ruler

addRing -skip_via_on_wire_shape Noshape -use_wire_group_bits 2 -use_interleaving_wire_group 1 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -use_wire_group 1 -type core_rings -jog_distance 2.0 -threshold 2.0 -nets {VDD VSS} -follow io -stacked_via_bottom_layer M1 -layer {bottom M5 top M5 right M6 left M6} -width 10 -spacing 5 -offset 90
fit

## add stripes
win
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit M7 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M5 -set_to_set_distance 100 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -padcore_ring_top_layer_limit M7 -spacing 5 -merge_stripes_value 2.0 -layer M6 -block_ring_bottom_layer_limit M5 -width 10 -nets {VDD VSS} -stacked_via_bottom_layer M1


# connect pads to rings - taken from import.tcl -ncd
sroute -connect { padPin } -layerChangeRange { M2 AP } -padPinPortConnect { allPort allGeom } 


## place macros -ncd

placeInstance xorCntr1 360 1500 R0 -fixed 



placeInstance ringOsc1 275 1373.5 MY -fixed 
placeInstance ringOsc2 475 1373.5 MY -fixed 
placeInstance ringOsc3 675 1373.5 MY -fixed 

placeInstance ringOsc4 275 1273.5 MY -fixed 
placeInstance ringOsc5 475 1273.5 MY -fixed 
placeInstance ringOsc6 675 1273.5 MY -fixed 

placeInstance ringOsc7 275 1173.5 MY -fixed 
placeInstance ringOsc8 475 1173.5 MY -fixed 
placeInstance ringOsc9 675 1173.5 MY -fixed 

placeInstance ringOsc10 275 1073.5 MY -fixed 
placeInstance ringOsc11 475 1073.5 MY -fixed 
placeInstance ringOsc12 675 1073.5 MY -fixed 

placeInstance ringOsc13 275 973.5 MY -fixed 
placeInstance ringOsc14 475 973.5 MY -fixed 
placeInstance ringOsc15 675 973.5 MY -fixed 

placeInstance ringOsc16 275 873.5 MY -fixed 
placeInstance ringOsc17 475 873.5 MY -fixed 
placeInstance ringOsc18 675 873.5 MY -fixed 

placeInstance ringOsc19 275 773.5 MY -fixed 
placeInstance ringOsc20 475 773.5 MY -fixed 
placeInstance ringOsc21 675 773.5 MY -fixed 

placeInstance ringOsc22 275 673.5 MY -fixed 
placeInstance ringOsc23 475 673.5 MY -fixed 
placeInstance ringOsc24 675 673.5 MY -fixed 

placeInstance ringOsc25 275 573.5 MY -fixed 
placeInstance ringOsc26 475 573.5 MY -fixed 
placeInstance ringOsc27 675 573.5 MY -fixed 

placeInstance ringOsc28 275 473.5 MY -fixed 
placeInstance ringOsc29 475 473.5 MY -fixed 
placeInstance ringOsc30 675 473.5 MY -fixed 

placeInstance ringOsc31 275 373.5 MY -fixed 
placeInstance ringOsc32 475 373.5 MY -fixed 





placeInstance delay1 965 1373.5 R0 -fixed 
placeInstance delay2 1065 1373.5 R0 -fixed 
placeInstance delay3 1165 1373.5 R0 -fixed 

placeInstance delay4 965 1273.5 R0 -fixed 
placeInstance delay5 1065 1273.5 R0 -fixed 
placeInstance delay6 1165 1273.5 R0 -fixed 

placeInstance delay7 965 1173.5 R0 -fixed 
placeInstance delay8 1065 1173.5 R0 -fixed 
placeInstance delay9 1165 1173.5 R0 -fixed 

placeInstance delay10 965 1073.5 R0 -fixed 
placeInstance delay11 1065 1073.5 R0 -fixed 
placeInstance delay12 1165 1073.5 R0 -fixed 

placeInstance delay13 965 973.5 R0 -fixed 
placeInstance delay14 1065 973.5 R0 -fixed 
placeInstance delay15 1165 973.5 R0 -fixed 

placeInstance delay16 965 873.5 R0 -fixed 
placeInstance delay17 1065 873.5 R0 -fixed 
placeInstance delay18 1165 873.5 R0 -fixed 

placeInstance delay19 965 773.5 R0 -fixed 
placeInstance delay20 1065 773.5 R0 -fixed 
placeInstance delay21 1165 773.5 R0 -fixed 

placeInstance delay22 965 673.5 R0 -fixed 
placeInstance delay23 1065 673.5 R0 -fixed 
placeInstance delay24 1165 673.5 R0 -fixed 

placeInstance delay25 965 573.5 R0 -fixed 
placeInstance delay26 1065 573.5 R0 -fixed 
placeInstance delay27 1165 573.5 R0 -fixed 

placeInstance delay28 965 473.5 R0 -fixed 
placeInstance delay29 1065 473.5 R0 -fixed 
placeInstance delay30 1165 473.5 R0 -fixed 



placeInstance CLAMP1c 335 130 MY -fixed 
placeInstance CLAMP2c 463 130 MY -fixed 
placeInstance CLAMP3c 591 130 MY -fixed 
placeInstance CLAMP4c 719 130 MY -fixed 

placeInstance CLAMP3b 847 130 MY -fixed 
placeInstance CLAMP4b 975 130 MY -fixed 
placeInstance CLAMP5b 1103 130 MY -fixed 
placeInstance CLAMP6b 1231 130 MY -fixed 
placeInstance CLAMP7b 1359 130 MY -fixed 

placeInstance CLAMP3a 847 1675 MY -fixed  
placeInstance CLAMP4a 975 1675 MY -fixed 
placeInstance CLAMP5a 1103 1675 MY -fixed 
placeInstance CLAMP6a 1231 1675 MY -fixed 
placeInstance CLAMP7a 1359 1675 MY -fixed 



#
## defIn bussesAll8.def //has M4 + M6
# defIn busses_VSS.def
# defIn -specialnets bussesAll12.def



# On Macros
#foreach inst [ dbGet [ dbGet -p2 top.insts.cell.baseClass block].name ] {createRouteBlk -cover -name myRtBlk -fills -layer 1 2 3 4 -cutLayer 2 3 4 -spacing 4 -inst $inst}

## deleteRouteBlk -name myRtBlk 

stop

# route standard cell rows -ncd
sroute -connect {corePin}




## add rings around selected macros -ncd
deselectAll
#selectInst ringOsc1

#addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer AP -around selected -jog_distance 2.0 -threshold 2.0 -type block_rings -follow core -stacked_via_bottom_layer M1 -layer {bottom M5 top M5 right M4 left M4} -width 5 -spacing 2 -offset 2.0 -nets {VDD VSS}
deselectAll
## Connect selected macros to rings -ncd
#sroute -connect { blockPin } -layerChangeRange { M1 AP } -blockPinTarget { nearestTarget } -allowJogging 1 -crossoverViaLayerRange { M1 AP } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -block { ringOsc1 } -targetViaLayerRange { M1 AP }

#sroute -connect { blockPin } -layerChangeRange { M1 AP } -blockPinTarget { nearestTarget } -allowJogging 1 -crossoverViaLayerRange { M1 AP } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -block { CLAMP1c } -targetViaLayerRange { M1 AP } -padPinPortConnect {allPort}




#set width [expr (($io2core - 3) / 2)  ]
#set nwires [expr int ($width / 13.5) + 1]
#set width1 [expr int( $width/ $nwires * 10)*0.1 -1.5]
#set wires [string repeat "VSS VDD " $nwires]
#
#addRing -around core -type core_rings -nets "$wires" -spacing 2 -width $width1  -layer {bottom M5 top M5 left M4 right M4}  -center 1  -offset 0.2
#addStripe -number_of_sets 2 -spacing 2 -xleft_offset 10 -xright_offset 10 -layer M6 -width 10 -nets { VSS  VDD } 



#set box [split [join [dbGet top.fPlan.corebox]]]
#set x1 [lindex $box 0]
#set y1 [lindex $box 1]
#set x2 [lindex $box 2]
#set y2 [lindex $box 3]

# ADDITIONAL FLOORPLAN COMMANDS


#if {$MIXED_TRACKS} {  
#	set yCore7t [expr ($y1+$y2)/2]
##	setObjFPlanBox Module core_digital/CSR $x1 $y1 $x2 $yCore7t 
##	#setObjFPlanBox Module core_digital/slave/slave1/synch $x1 $y1 $x2 [expr ($y1+$y2)/4 - 10] 
	#modifyPowerDomainAttr core7thvt -box  $x1 $y1 $x2 [expr ($y1+$y2)/4 ] -minGaps 2 2 2 2
#	deleteRow -site core7T
#    deleteRow -site gacore7T
#	createRow -site core7T -area $x1 [expr $y1 + 0.1] $x2 $yCore7t
#}

## Nice! -ncd 
if {$CORE_CHIP != "CHIP"} {source ../scripts/addDiodeOnInputs.tcl}
 

## first create OA library called "output"
## exec cp -r ../scripts/emptyLib output

#Create OA database "output" that references a local copy of the techonogy database.-ncd
### createLib output -referenceTech {tsmcN65} -libPath ../output


# "output" OA database must have been created with 
#  cp -r ../scripts/emptyLib ../output      -ncd
saveDesign -cellview "output [dbGet top.name] floorplan" -enc ../output/floorplan.enc
