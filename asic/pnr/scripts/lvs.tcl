#######################################################
#                                                     
#  THE RECIPE
#  by Sandro Bonacini
#  CERN PH/ESE/ME
#  Created on 15/10/2013
#                                                     
#######################################################

source ../scripts/variables.tcl

set TSMC_PDK $env(TSMC_PDK)
#set PDK_OPT $env(PDK_OPT)
#exec cat $IBM_PDK/IBM_PDK/cmrf8sf/rel$PDK_OPT/Assura/QRC/32/LVSinclude.rsf >LVS/assura.rsf

set topName [dbGet top.name]

set fd [open "LVS/assura.rsf" "w"]
puts $fd ";----------------------------------------------------------------------------"
puts $fd "; avParameter Section"
puts $fd ";----------------------------------------------------------------------------"
puts $fd 
puts $fd "avParameters("
puts $fd "  ?inputLayout ( \"df2\" \"$oaLibName\" )"
puts $fd "  ?cellName \"$topName\""
puts $fd "  ?viewName \"layout\""
puts $fd "  ?workingDirectory \".\""
puts $fd "  ?technology \"assura_tech\""
puts $fd "  ?techLib \"../assura_tech.lib\""
puts $fd "  ?set (\"STD_LIB_9_TRACK\" \"top2_thick\")"
puts $fd "  ?avrpt t"
puts $fd ")"
close $fd

exec cat $TSMC_PDK/Assura/lvs_rcx/compare.rul >>LVS/assura.rsf

set fd [open "LVS/assura.rsf" "a"]
puts $fd ";----------------------------------------------------------------------------"
puts $fd "; avCompareRules Section"
puts $fd ";----------------------------------------------------------------------------"
puts $fd ""
puts $fd "avCompareRules("
puts $fd "  schematic("
puts $fd "     filterDevice(\"cds_thru(RES)\" short(\"src\" \"dst\"))"
puts $fd "  )"
puts $fd ")"
puts $fd ""
puts $fd "avCompareRules("
puts $fd "  schematic("
puts $fd "    netlist( dfII \"$topName.vlr\" )"
puts $fd "  )"
puts $fd "  bindingFile(\"$TSMC_PDK/Assura/lvs_rcx/bind.rul\")"
puts $fd ")"
puts $fd 
puts $fd "avLVS()"
close $fd

#exec cat $IBM_PDK/IBM_PDK/cmrf8sf/rel$PDK_OPT/Assura/QRC/32/deviceInfo.rul >LVS/$topName.vlr

set fd [open "LVS/$topName.vlr" "w"]
puts $fd "avSimName = \"auLvs\""
puts $fd "avDisableWildcardPG = nil"
puts $fd "avLibName  = \"$oaLibName\""
puts $fd "avCellName = \"$topName\""
puts $fd "avViewName = \"schematic\""
puts $fd "avViewList = \"auLvs schematic symbol\""
puts $fd "avStopList = \"auLvs\""
puts $fd "avVldbFile = \"$topName.sdb\""
close $fd

cd LVS
exec assura assura.rsf -cdslib ../cds.lib >@stdout 2>@stdout
wait
exec tail -5 $topName.csm  >@stdout
cd ..
