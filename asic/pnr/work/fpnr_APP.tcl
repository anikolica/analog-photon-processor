## file to source before restoring a design -ncd
############################
## defOut command: select object and then run this -ncd
## Note that defIn is pretty smart. It will compare objects being added
## and NOT add them if they already exist
##    defOut -routing -selected my.def
##    defIn my.def
##    defOut -floorplan my.def (*this is the most complete! Includs blockages too)
#############################



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

# DEFINE ADDITIONAL USER LIBRARIES HERE  -ncd
set userLib "APP_lib"
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
#set init_pwr_net {VDD VSS VDDPST VSSPST   }

set init_assign_buffer 1
set conf_qxconf_file NULL
set init_import_mode { -keepEmptyModule 1 -treatUndefinedCellAsBbox 0}
set conf_qxlib_file NULL
set init_layout_view layout
set init_gnd_net {VSS GND AVSS VSSPST}
set init_abstract_view abstract
getenv ENCOUNTER_CONFIG_RELATIVE_CWD
setDoAssign on

## Attempt to fix broken pdk vias -ncd
#250612 setGenerateViaMode -auto true -deleteViaBeforeGeneration  all

## -ncd
init_design

#stop


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
globalNetConnect VSS -type pgpin -pin GND -inst *    ; # add GND -ncd



## add these - BUT DONT WANT THESE CONNECTED -> SO DONT  -ncd
#globalNetConnect VDDPST -type pgpin -pin VDDPST -inst *
#globalNetConnect VSSPST -type pgpin -pin VSSPST -inst *

## Maybe these should be removed --> They generate unneeded cds_thru's -ncd
#globalNetConnect VDD -type net -net VDD! 
#globalNetConnect VSS -type net -net VSS! 
#globalNetConnect VDDPST -type net -net VDDPST! 
#globalNetConnect VSSPST -type net -net VSSPST! 

#stop

## Load IO pads and special routing
loadIoFile 	APP.save.io     ; # padring corners plus some pads -ncd
floorPlan -coreMarginsBy die -site core -d 1860 1860 130 130 130 130 -adjustToSite
fit

#setDrawView ameba  ; # Toggle innovus to wake it up! -ncd
#setDrawView place

# Set pins visible
setLayerPreference node_cell -isVisible 0
setLayerPreference pinObj -isVisible 1
setDrawView fplan 


## PLACE MACROS -ncd

#selectInst amplifier1
#setObjFPlanBox Instance amplifier1 1307.107 1229.966 1367.107 1294.971
placeInstance amplifier1 1300 1200 R0 -fixed
fit  ; # Toggle to wake up Innovus GUI ! -ncd


stop




## defIn special routing -mcd
defIn coldMPW.def   ; # Special routes Beginning
#defIn coldMPW_fp.def ; # Special routes w/ floorplan
##defIn coldMPW_fp_rowcuts.def ; # floorplan w/ rowcuts and row routing
###defIn coldMPW_rowcuts.def ; # Special routes w/ rowcuts 


#stop

# On Macros
#foreach inst [ dbGet [ dbGet -p2 top.insts.cell.baseClass block].name ] {createRouteBlk -cover -name myRtBlk -fills -layer 1 2 3 4 5 6 -cutLayer 2 3 4 5 6 -spacing 4 -inst $inst}
## deleteRouteBlk -name myRtBlk 



## Prepare row rows around macros
##### create routing blockages and cut core rows around each macro ############ -ncd
## Place expanded routing blockages over macros: expand or contracct by SIZE +/-5 -ncd
foreach box [dbShape [dbGet [dbGet -p2 top.insts.cell.baseClass block].boxes] SIZE 4.5] {createRouteBlk -layer all -name myRtBlks -box $box}

## cut core rows around macros in expanded area by "halo"  -ncd
foreach inst [ dbGet [ dbGet -p2 top.insts.cell.baseClass block].name ] {selectInst $inst}
cutRow -selected -halo 5
deselectAll

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

## install I/O filler and pads -ncd
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

source ../scripts/place.tcl
source ../scripts/route.tcl

source ../scripts/dfm.tcl

