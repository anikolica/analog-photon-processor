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
catch {exec mkdir LVS}

set topCell          [dbGet top.name]
set env(TOPCELL)          [dbGet top.name]
set env(LAYOUT_PATH)   		../$oaLibName.gds
set env(SOURCE_PATH)   		$topCell.src.net
set env(TECHDIR)           	$env(TSMC_PDK)/Calibre/lvs/
#set env(oaLibName)          $oaLibName

exec cp ../scripts/si.env LVS/
set fd [open "LVS/si.env" "a"]
puts $fd "hnlNetlistFileName = \"$topCell.src.net\""
puts $fd "simCellName = \"$topCell\""
puts $fd "simLibName = \"$oaLibName\""
close $fd

cd LVS
exec si . -cdslib ../cds.lib -batch -command netlist   
exec echo SOURCE PRIMARY $topCell > calibre.lvs
exec cat ../../scripts/calibreLVS.cal >> calibre.lvs
exec calibre -lvs -hier -turbo -turbo_all -64 calibre.lvs >@stdout 2>@stdout
cd ..
