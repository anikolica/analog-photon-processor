## file to source before restoring a design -ncd
############################
## defOut command: select object and then run this -ncd
## Note that defIn is pretobjectty smart. It will compare objects being added
## and NOT add them if they already exist
##    defOut -routing -selected my.def
##    defIn my.def
##    defOut -floorplan my.def (*this is the most complete! Includs blockages too)
#############################
###defOut -cutRow -selected APP1.def

## 2025: Innovus commands that still work -ncd
#get_pins -hierarchical *VSS*

## Add dont touch to some pins to stop innovus from routing to them -ncd 2025
#foreach pin [get_pins -hierarchical *] {
#    if {[regexp {/(IOPAD|VSS|VSSPST|VDD)} $pin]} {
#        puts "Freezing pin: $pin"
#        set_dont_touch $pin
#    }
#}
#

# Can set a net to be dont touch so that innovus wont route it again.
# set_dont_touch VSS


#   editSelect
#   editNet
#   dbGet
#     dbGet selected.net.name
#     dbGet selected.cell.name
#     dbGet head.libCells.name <cell_name>
#     get_db 
#     get
# setAttribute -net VSS -skip_routing true
# setAttribute -net VDD -skip_routing true
#
#  editDelete -net
#  editDelete -selected
#  get_db

#  routeDesign -incremental XXX
#  routeGlobsource ../scripts/place.tclalNet XXX
#  
#  ecoRoute -fix_drc
#  createNet POC   (This will create the net so that globalNetConnect will work)

### To update OS librarys do this:
#  set_db init_oa_ref_libs $userLib  (userLib was st to the list of OA libraries)
#  

set TSMC_PDK $env(TSMC_PDK)
source ../scripts/variables.tcl

#Space for global variables -ncd
namespace eval glv {}
set glv::PVS_QRC "/cad/Technology/TSMC650A.new/V1.7A_1/1p9m6x1z1u/PVS_QRC/QRC/"
set glv::LBS "/cad/Technology/TSMC650A.new/V1.7A_1/1p9m6x1z1u/PVS_QRC/QRC/"

# ptk hack -- 250612
set glv::CellLibPath "/cad/Technology/TSMC650A.new/digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/"
set glv::IOdLibPath "/cad/Technology/TSMC650A.new/digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/"
set glv::IOaLibPath "/cad/Technology/TSMC650A.new/digital/Front_End/timing_power_noise/NLDM/tpan65lpnv2od3_200a/"
set glv::SIcellPath "/cad/Technology/TSMC650A.new/digital/Back_End/celtic/tcbn65lp_200c"
set glv::SIiodPath "/cad/Technology/TSMC650A.new/digital/Back_End/celtic/tpdn65lpnv2od3_200a"
set glv::SIioaPath "/cad/Technology/TSMC650A.new/digital/Back_End/celtic/tadn65lpnv2od3_200a"


####set init_lef_file
# DEFINE ADDITIONAL USER LIBRARIES HERE: must 1st create APP_lib in virtuoso 2025  -ncd
# Must reference all libraries containing macro abstracts here -ncd 2025
set userLib "APP_lib 2025_APP 2025_Chip_area 2025_LEF_ncd tpan65lpnv2od3_Penn"


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

## this is required in flow that might unlock all innovis commands -ncd 2025 
## Edited def file to make followpin routes FIXED so that they dont get deleted... but...
## drc violations with followpins and routes persist and cannot be fixed even when changing back to ROUTED -ncd
# set init_def_file APP_fixed.def



## NOTE TSMC pads force us to use "verilog stitching" whereby one first places
##      IO cells and their bondpads; Create a DEF file freezing placements;
##      and then run a script to find nets attached to underlying IO cells 
##      that should be attached to these bondpads; and then creates 
##      verilog statements instantiating the bondpads. These instantiations 
##      are then appended to the original synthesized verilog, and 
##      innovus *restarted*; DEFin is used to recover placements. 
##      The bondpads are now labeled with the correct nets.
##
##    This all being said, the set init_verilog statement are manually edit 
##    to first provide the original synthesized logic: r2g.v and on the 
##    second run innovus is provided with the 'stiched' 
##    verilog: r2g_with_pads.v
## A cat statement is provided that can be separately run in innous to create
## the stiched verilog. But still needs hand edits to place the bondpad
## instantiations inside the APP module: 

## point to verilog file -ncd
set init_verilog ../../syn/output/r2g.v
#set init_verilog r2g_with_pads.v

## Run to create and Concatenate r2g.v and bondad_stitch.v (verilog for bondpads) -ncd 
# source ../scripts/addPads_VERILOG.tcl
# exec cat ../../syn/output/r2g.v bondpad_stitch.v > r2g_with_pads.v
# defOut -floorplan -netlist stitched_floorplan.def
# Now exit and restart innovus 

## added VSSPST -ncd
#set init_pwr_net {VDD  AVDD VDDPST VSSPST VDDPST! VSSPST! VDD! VSS!}
#set init_gnd_net {VSS AVSS VSSPST}



## Need to declare all global nets here
set init_pwr_net {VDD VDD_1 VDD_2 VDDPST TAVDD, TACVDD AVDD}
set init_gnd_net {VSS VSSPST AVSS}



set init_assign_buffer 1
set conf_qxconf_file NULL
set init_import_mode { -keepEmptyModule 1 -treatUndefinedCellAsBbox 0}
set conf_qxlib_file NULL
set init_layout_view layout


set init_abstract_view abstract




getenv ENCOUNTER_CONFIG_RELATIVE_CWD
setDoAssign on

## Attempt to fix broken pdk vias -ncd
#250612 setGenerateViaMode -auto true -deleteViaBeforeGeneration  all


## -ncd
init_design

# If "stitching" run the following to recover IO cell and bondpad placement
# defIn stitched_floorplan.def


stop


fit
setDrawView fplan
win


## This is obselete -ncd 2025
#if {$MIXED_TRACKS} {
#	loadCPF ../scripts/power.cpf
#	commitCPF
#}



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
#commitConfigfloorPlan -coreMarginsBy die -site core -d 1200 1200 140 140 140 140 -adjustToSite
fit


## Add physical Instances -ncd 2025
#addInst -cell AGIO_GND  -inst GND2

## break ring into analog and digital sections -ncd 2025
#addInst -physical -cell PRCUTA -inst BREAK1
#addInst -physical -cell PRCUTA -inst BREAK2
#addInst -physical -cell PRCUTA -inst BREAK3
#addInst -physical -cell PRCUTA -inst BREAK4

# Must now edit teh IoFile, APP.save.io to include these BREAK's -ncd 2025
## Once loaded, you can move them around with the GUI ! -ncd


#stop

## Load IO pads and special routing
loadIoFile 	APP.save.io     ; # padring corners plus some pads -ncd

fit


##




## These seem to force impossible connection to VDD -ncd 2025
#globalNetConnect VDD -net VDDPST! -inst *
#globalNetConnect VSS -net VSSPST! -inst *

### These dont work since the LEFs dont have power/gnd pins -ncd
##globalNetConnect DVDD -type pgpin -pin VDDPST -inst *
##globalNetConnect VSS -type pgpin -pin VSSESD -inst *

######   LOAD EXISTING FLOORPLAN HERE IF DESIRED ###### 
loadFPlan APP.fp                                    ; #
#defIn APP_fixed.def
#######################################################
#stop


## 
#floorPlan -coreMarginsBy die -site core -d 5000 5500 140 140 140 140 -adjustToSite
#floorPlan -coreMarginsBy die -site core -d 5000 3000 140 140 140 140 -adjustToSite
floorPlan -coreMarginsBy die -site core -d 5000 2800 140 140 140 140 -adjustToSite

fit


## Add physical Instances -ncd 2025
#addInst -cell AGIO_GND  -inst GND2

## break ring into analog and digital sections -ncd 2025
addInst -physical -cell PRCUTA -inst BREAK1
addInst -physical -cell PRCUTA -inst BREAK2
addInst -physical -cell PRCUTA -inst BREAK3
addInst -physical -cell PRCUTA -inst BREAK4
addInst -physical -cell PRCUTA -inst BREAK5
addInst -physical -cell PRCUTA -inst BREAK6

# Must now edit the IoFile, APP.save.io to include these BREAK's -ncd 2025
## Once loaded, you can move them around with the GUI ! -ncd


#stop

## Load IO pads and special routing
loadIoFile 	APP.save.io     ; # padring corners plus some pads -ncd

fit

## DEF out floorplan with placed bondpads for later stitching to verilog -ncd 2025
defOut -floorplan -netlist stitched_floorplan.def
defIn stitched_floorplan.def

## add these - BUT DONT WANT THESE CONNECTED -> SO DONT  -ncd
#globalNetConnect VDDPST -type pgpin -pin VDDPST -inst *
#globalNetConnect VSSPST -type pgpin -pin VSSPST -inst *

## Maybe these should be removed --> They generate unneeded cds_thru's -ncd
#globalNetConnect VDD -type net -net VDD! 
#globalNetConnect VSS -type net -net VSS! 
#globalNetConnect VDDPST -type net -net VDDPST! 
#globalNetConnect VSSPST -type net -net VSSPST! 



## add corners and physical cells (not in verilog) -ncd
if {$CORE_CHIP == "CHIP"} {
	addInst -physical -cell PCORNERA -inst corner1
	addInst -physical -cell PCORNERA -inst corner2
	addInst -physical -cell PCORNERA -inst corner3
	addInst -physical -cell PCORNERA -inst corner4
	loadIoFile ../scripts/corner.io
}
fit




#stop

## Install I/O filler and bondpads -ncd
#if {$CORE_CHIP == "CHIP"} {
#	addIoFiller -cell PFILLER20
#	addIoFiller -cell PFILLER10
#	addIoFiller -cell PFILLER5
#	addIoFiller -cell PFILLER1
#	addIoFiller -cell PFILLER05
#	addIoFiller -cell PFILLER0005 -fillAnyGap
#	
#}
#fit

	# deleteInst pad_* add Bondpads -ncd 2025  
	source ../scripts/addPads.tcl 
        fit



## Fill Digital sections first
        addIoFiller -cell PFILLER20 -side top -from 3115 -to 4530
        addIoFiller -cell PFILLER10 -side top -from 3115 -to 4530
        addIoFiller -cell PFILLER5 -side top -from 3115 -to 4530
        addIoFiller -cell PFILLER1 -side top -from 3115 -to 4530
        addIoFiller -cell PFILLER05 -side top -from 3115 -to 4530
        addIoFiller -cell PFILLER0005 -side top -from 3115 -to 4530 -fillAnyGap

        addIoFiller -cell PFILLER20 -side bottom -from 3115 -to 4530
        addIoFiller -cell PFILLER10 -side bottom -from 3115 -to 4530
        addIoFiller -cell PFILLER5 -side bottom -from 3115 -to 4530
        addIoFiller -cell PFILLER1 -side bottom -from 3115 -to 4530
        addIoFiller -cell PFILLER05 -side bottom -from 3115 -to 4530
        addIoFiller -cell PFILLER0005 -side bottom -from 3115 -to 4530 -fillAnyGap
fit

## Fill remainer with analog filler -ncd
	addiofiller -cell PFILLER20A
	addIoFiller -cell PFILLER10A
	addIoFiller -cell PFILLER5A 
	addIoFiller -cell PFILLER1A 
	addIoFiller -cell PFILLER05A
	addIoFiller -cell PFILLER0005A -fillAnyGap


## Here is how to Delete the IO filler -ncd
# deleteIoFiller -cell {PFILLER20 PFILLER10 PFILLER5 PFILLER1 PFILLER05 PFILLER0005 }
# deleteIoFiller -cell {PFILLER20A PFILLER10A PFILLER5A PFILLER1A PFILLER05A PFILLER0005A }


source ../scripts/variables.tcl
##globalNetConnect VDDH_FUSE -type pgpin -pin DVDD -inst vfuse1 
#globalNetConnect VDD -type pgpin -pin VDD -inst * -region {100 100 4900 5400  } -netlistOverride
#globalNetConnect VSS -type pgpin -pin VSS -inst * -region {100 100 4900 5400  } -netlistOverride
#globalNetConnect VSS -type pgpin -pin GND -inst * -region {100 100 4900 5400  } -netlistOverride  


## THIS IS HOW TO DECLARE GLOBAL NETS -ncd 2025
## globalNetConnect <globalNetName> -net <designNetName> -type net 
globalNetConnect VSSPST -net VSSPST -type net -verbose
globalNetConnect VDDPST -net VDDPST -type net -verbose
globalNetConnect VDD -net VDD -type net -verbose

#globalNetConnect VDD -type pgpin -pin VDD -inst PVDD1CDG -verbose
foreach inst [get_cells -filter {ref_name == PVDD1CDG}] {
  set instName [get_property $inst name]
  globalNetConnect VDD -type pgpin -pin VDD -inst $instName -verbose
}




## Careful: VSS is local in analog ring  and global in digital ring -ncd 2025 
globalNetConnect VSS -net VSS -type net -verbose
## This gets all local VSS pins and attaches them to the now global net VSS -ncd 2025  
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

## this works on my blackbox APP_chan -ncd 
globalNetConnect VSS -type pgpin -pin GND -inst * -netlistOverride 


## These take care of any macro with abstract having signal Type = power/ground -ncd 2025
### FINAL VERSION OF globalNetConnect commands -ncd 2025  *****
globalNetConnect VDD    -type pgpin -pin VDD    -inst * -override
globalNetConnect VSS    -type pgpin -pin VSS    -inst * -override
globalNetConnect VSS    -type pgpin -pin GND    -inst * -override
# Dont need any globalNetConnect if the pins are maked as signalType = signal
## connect APPchan1 pins to VDD_1 -ncd 2025 since pin is signal, not pgpin
globalNetConnect VDD_1 -type net -net VDD_1 -pin VDD -instanceBasename APPchan1
globalNetConnect VDD_2 -type net -net VDD_2 -pin VDDH -instanceBasename APPchan1










## These are not possible due to LEF pins listed as "USE SIGNAL" -ncd
#globalNetConnect TAVDD  -type pgpin -pin TAVDD  -inst * -override
#globalNetConnect TACVDD -type pgpin -pin TACVDD -inst * -override
#globalNetConnect POC    -type net   -pin POC    -inst * -override




#setDrawView ameba  ; # Toggle innovus to wake it up! -ncd
#setDrawView place

# Set pins visible and selectable
setLayerPreference node_cell -isVisible 0
setLayerPreference pinObj -isVisible 1
setLayerPreference node_cell -isSelectable 1
setDrawView fplan 


#stop

#
## PLACE MACROS -ncd

#selectInst amplifier1
#setObjFPlanBox Instance amplifier1 1307.107 1229.966 1367.107 1294.971
placeInstance amplifier1 272.5 650 R0 -fixed
fit  ; # Toggle to wake up Innovus GUI ! -ncd

## defIn special routing -mcd
##defIn APP_fp.def ; # Special routes and blockages then skip to place, etc -ncd
defIn APP.def   
u#defIn APP_selected.def ; # selected only
#defIn myBlockages.def  ; # blockages only

stop


source ../scripts/place.tcl
##source ../scripts/cts_CCOpt.tcl  ; # place these commands into route.tcl 2025 -ncd
source ../scripts/route.tcl

stop

source ../scripts/dfm.tcl
source  ../scripts/innovus2virtuoso.tcl

#########################################################
################## EXTRAS ##############################
#########################################################

## ADD RINGS around CORE area: 10 wide/5 space rings on M9/M8 -ncd 
#addRing -skip_via_on_wire_shape Noshape -use_wire_group_bits 2 -use_interleaving_wire_group 1 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -use_wire_group 1 -type core_rings -jog_distance 2.0 -threshold 2.0 -nets {VDD VSS} -follow io -stacked_via_bottom_layer M1 -layer {bottom M7 top M7 right M6 left M6} -width 10 -spacing 5 -offset 10
#uiSetTool ruler




## ADD STRIPES M9 10-5-10 every 100um -ncd
#addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit M7 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M5 -set_to_set_distance 100 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -padcore_ring_top_layer_limit M7 -spacing 5 -merge_stripes_value 2.0 -layer M6 -block_ring_bottom_layer_limit M5 -width 10 -nets {VDD VSS} -stacked_via_bottom_layer M1

#screate_power_nets -nets VDD -voltage 1.2 -internaltop

## 2025 UPDATE from GUI -ncd
## RINGS for Analog VDD_1, VSS
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer M9 -stacked_via_bottom_layer M1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD_1 VSS} -type core_rings -follow io -layer {top M8 bottom M8 left M9 right M9} -width {top 10 bottom 10 left 10 right 10} -spacing {top 5 bottom 5 left 5 right 5} -offset {top 20 bottom 20 left 20 right 20} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -use_wire_group 1 -use_wire_group_bits 2 -use_interleaving_wire_group 1


## STRIPES (Net VDD_1, VSS)
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer AP -stacked_via_bottom_layer M1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {VDD_1 VSS} -layer M9 -direction vertical -width 10 -spacing 5 -set_to_set_distance 100 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None

##
## RINGS for Digital VDD, VSS
addRing -nets { VDD VSS} -type core_rings -follow io -layer {top M7 bottom M7 left M6 right M6} -width {top 10 bottom 10 left 10 right 10} -spacing {top 5 bottom 5 left 5 right 5} -offset {top 20 bottom 20 left 5 right 5} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -use_wire_group 1 -use_wire_group_bits 2 -use_interleaving_wire_group 1



## Add ring around APPchan1 for a Stripe-target 
#deselectAll
#selectInst APPchan1
#setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer AP -stacked_via_bottom_layer M1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
#addRing -nets {VDD VSS} -type block_rings -around selected -layer {top M7 bottom M7 left M6 right M6} -width {top 10 bottom 10 left 10 right 10} -spacing {top 5 bottom 5 left 5 right 5} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
#deselectAll


##### CREATE ROUTING BLOCKAGE around APP BLOCK then create stripes for VDD/VSS
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass block].boxes] SIZE 0.0] {createRouteBlk -layer all -name myRtBlks -box $box}

## STRIPES for Digital (Net VDD, VSS)
#addStripe -nets {VDD VSS} -layer M6 -direction vertical -width 10 -spacing 5 -set_to_set_distance 100 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None


# Add Digital Stripes VDD VSS : Extend stripes from Macro blockage to rectangular boundary -ncd 2025
deselectAll
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer AP -stacked_via_bottom_layer M1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {VDD VSS} -layer M6 -direction vertical -width 10 -spacing 5 -set_to_set_distance 100 -area {150 130 4856 2665} -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit AP -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit AP -block_ring_bottom_layer_limit M1 -use_wire_group 0 -snap_wire_center_to_grid None
fit


## cut core rows around macros in expanded area by "halo"  -ncd
foreach inst [ dbGet [ dbGet -p2 top.insts.cell.baseClass block].name ] {selectInst $inst}
cutRow -selected -halo 6.0
deselectAll

##### CREATE ROUTING BLOCKAGES and cut core rows around each macro ############ -ncd
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass block].boxes] SIZE 5.0] {createRouteBlk -layer all -name myRtBlks -box $box}

foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass pad].boxes] SIZE 0] {createRouteBlk -layer all -cutLayer all -name myBlksIO -box $box}



## ROUTE rows for standard cells -ncd
sroute -connect {corePin}

deleteRouteBlk -all 
#########################################


##### NCD
## VDD/VSS on VERTICAL EDGES of core -ncd 
addRing -nets {VDD VSS} -type core_rings -follow io -layer {top M2 bottom M2 left M1 right M1} -width {top 1.8 bottom 1.8 left 1.8 right 1.8} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 10 right 10} -center 0 -skip_side {top bottom } -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

## VDD/VSS on VERTICAL EDGES of Macros -ncd
addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M2 bottom M2 left M1 right M1} -width {top 1.8 bottom 1.8 left 1.8 right 1.8} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None


# VDD/VSS Rings around  Macros
#foreach inst [ dbGet [ dbGet -p2 top.insts.cell.baseClass block].name ] {createRouteBlk -cover -name myRtBlk -fills -layer 1 2 3 4 5 6 -cutLayer 2 3 4 5 6 -spacing 4 -inst $inst}
## deleteRouteBlk -name myRtBlk 

## ADD rings around Macros -ncd
addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M2 bottom M2 left M1 right M1} -width {top 1.8 bottom 1.8 left 1.8 right 1.8} -spacing {top 0.5 bottom 0.5 left 0.5 right 0.5} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None













setDrawView fplan
## bottom
cutRow -area 100 100 1735 190
cutRow -area 100 208 1735 270
## top
cutRow -area 100 1590 1735 1653
cutRow -area 100 1670 1735  1735
fit
cutRow -area 1485 265 1735 505


#stop


## Stop Innovus from routing to VDD,VSS on bondpads -ncd 2025
## BUT cannot use setPinNoRoute ! -ncd
# foreach pad [get_cells -hierarchical -filter "name =~ *VDD*"] {
#     setPinNoRoute -inst $pad -pin VSS
# }

## Disable routing of VDD and VSS nets: so wont route to pads  -ncd 2025
setAttribute -net VSS -skip_routing true
setAttribute -net VDD -skip_routing true


# add blockage over io ring -ncd
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass pad].boxes] SIZE 10] {createRouteBlk -layer all -name myBlksIO -box $box}


#stop



## RESTORE encounter design here to continue work (note: verilog is saved in *.enc!!) 
##  But instead must use  'DefIn' to not get back old verilog. -ncd

## RUN To here then File-->Restore Design:
#    This is completed Floorplan:
## coldMPW.enc (FEOADesignlib) 

## DEF FILES for backups
## Can use 'defIn -specialnets/-components' to get only  routing/components 

# Attempt update tracks after DefIn from M6 --> M9 metals -ncd
#generateTracks

## Now manually cut rows using Floorplan -->Rows--> cut core row 
##  (selected objects: space 5)


#  Route VDD/VSS for standard rows. First shrink routeBlk a bit, then sroute rows.
deleteRouteBlk -name myRtBlks
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass block].boxes] SIZE 4.0] {createRouteBlk -layer all -name myRtBlks -box $box}
sroute -connect {corePin}

# Now resize Io blockages
deleteRouteBlk -name myBlksIO 
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass pad].boxes] SIZE 5] {createRouteBlk -layer all -cutLayer all -name myBlksIO -box $box}

## Resize macro blockages
deleteRouteBlk -name myRtBlks 
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass block].boxes] SIZE 1] {createRouteBlk -layer all -name myRtBlks -box $box}


###############################################################################


## finish up
##source ../scripts/import.tcl

## bad idea since pins are located on exterior edge of pads-- and are esd protected anyway -ncd
# Must attach ANTENNA diodes to all inputs -ncd 
##if {$CORE_CHIP != "CHIP"} {source ../scripts/addDiodeOnInputs.tcl}

## Basic method to add antenna diode on a net if needed
#    source addAntennaDiodes_ncd.tcl

clearDrc 


#stop


