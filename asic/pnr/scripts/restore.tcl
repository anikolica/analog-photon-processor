## file to source before restoring a design -ncd

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

## defIn floorplan -ncd
DefIn test.def

## finish up
##source ../scripts/import.tcl
source ../scripts/place.tcl
source ../scripts/route.tcl
source ../scripts/dfm.tcl
