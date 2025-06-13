#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15/10/2013
#                                                     
#######################################################

source ../scripts/variables.tcl

catch {exec rm $oaLibName.gds }
catch {exec strmout -library $oaLibName -strmFile $oaLibName.gds -topCell [dbGet top.name] -view layout}

catch {exec mkdir DRC}

set env(LAYOUT_PATH)   		../$oaLibName.gds
set env(RESULTS_DATABASE)  	calibre.drc.results
set env(SUMMARY_REPORT)    	calibre.drc.summary
set env(TECHDIR)           	$env(TSMC_PDK)/Calibre/drc/

#set env(BEOL_STACK)    		3_2_3
#set env(IOTYPE)            	WB_INLINE
#set env(DESIGN_TYPE)       	CELL
#set env(DENSITY_LOCAL)     	ON
#set env(CHECK_RECOMMENDED) 	OFF

cd DRC
exec calibre -drc -hier -turbo -turbo_all -64 ../../scripts/calibreDRC.cal >@stdout 2>@stdout
cd ..
exec cat DRC/$env(SUMMARY_REPORT) >@stdout

loadViolationReport -type Calibre -filename DRC/$env(RESULTS_DATABASE)
