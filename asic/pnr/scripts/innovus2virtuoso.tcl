
set TSMC_PDK $env(TSMC_PDK)
source ../scripts/variables.tcl





## MUST EDIT makePins according to pad names in design  -ncd
#source ../scripts/makePins.tcl
source ../scripts/generatePadLabels2.tcl  ; # copilot verions


write_sdf -min_view av_min -max_view av_max -typ_view av_typ  ../output/dfm.sdf
saveNetlist ../output/dfm.v

saveDesign -cellview "output [dbGet top.name] dfm " -enc ../output/dfm.enc

## Enables updates to the tech file after the design has been loaded. -ncd 2025
#setOaxMode -allowTechUpdate true

#update_oa_lib mklib -tech_attach_to_reference  ; # give permission to attach new vias to mklib instead of tsmcN65 -ncd 2025   


set dbgLefDefOutVersion 5.8
global dbgLefDefOutVersion
defOut -floorplan -netlist -routing dfm.def
##defOut -floorplan -netlist -routing APP.def

#### save verilog
saveNetlist lvs.v -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA 

## reconnect VSSPST/VDDPST to pads complements of Paul: 
exec ../scripts/foo.sh lvs.v 
exec ../scripts/lvs_postprocess.py $CORE_CHIP <lvs.v >lvs_pp.v


## Write out all LEFs for Macros and auto-generated vias 
#write_lef_library custom_vias.lef -all_auto_generated_via

# Optional step to get ONLY via definitions -ncd
#    awk '/^VIA /,/^END VIA/' custom_vias.lef > custom_only_vias.lef
#exec awk {/^VIA /,/^END VIA/} custom_vias.lef > custom_only_vias.lef
#### MUST PUT BACK PADS!! -ncd any macro missing lef may be a problem??

# Issue is that mklib needs to "Reference" not "Attach" to 
# techfile "tcbn65lp" as a minimum instead of "tsmcN65"
# so that all vias are defined. Referecing allows writing special vias.
# -ncd 2025

#stop

# Now open virtuoso; IN GUI do this:
#   Created mklib attached to techfile "tsmc65N" --> changed by "update_oa_lib"
#   import "custom_vias.lef" using GUI

## Now back in innovus: Create "dfm" abstract view 
exec defin -def dfm.def -lib $oaLibName -cell [dbGet top.name] -view dfm -overwrite -log defin.log

#This step creates virtuoso Layout view from virtuoso dfm (abstract view)
catch {exec virtuoso -nograph -log makeLayout.log -replay ../scripts/makeLayout.il}


# Generate Schematic view 
catch {exec ihdl +DUMB_SCH -PARAM ../scripts/ihdlParamFile lvs_pp.v}
# Check verilogIn.log for any problems with schematic
