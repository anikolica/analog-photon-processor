###################################################
##
## Created on Nov  26  2009 
## by Sandro Bonacini
## CERN PH/ESE/ME
##
###################################################

# Some possible ways to recover VDDPST VSSPST labels -ncd
# 
# dbGet [dbGet selected].cell.terms.name
#

## OK, now set top level back to 9 so that labels get put proper level -ncd
set topRoutingLayer 9

set layer_top [lindex  [dbGet [dbGet -p head.layers.type routing].name] [expr $topRoutingLayer - 1]]

set skillfd [open "addPins.il" "w"]
foreach p [dbGet top.terms] {
	set pinName [string map { [ < ] > } [join [dbGet $p.name]]]
	set instTerm [dbGet -p [dbGet -p $p.net.allTerms.objType instTerm].inst.instTerms.name */PAD]
	set layer [dbGet $p.layer.name]

	if {$instTerm != 0x0} {
		set pinPos [join [dbGet $instTerm.pt]]
		#puts "$pinName $pinPos"
		##puts $fd "editPin -cell chip -pin $pinName -assign $pinPos -layer 8 -pinWidth 4 -pinDepth 4  -fixedPin 1" 
		##puts $fd "addCustomText M8 $pinName $pinPos 10"
		#puts $skillfd "label0 = dbCreateLabel(au1 list(\"AP\" \"pin\") list( $pinPos ) \"$pinName\" \"centerCenter\" \"R0\" \"stick\" 10)"

# remove -ncd
#		puts $skillfd "label0 = dbCreateLabel(au1 list(\"$layer\" \"pin\") list( $pinPos ) \"$pinName\" \"centerCenter\" \"R0\" \"stick\" 10)"

		puts $skillfd "label0 = dbCreateLabel(au1 list(\"$layer_top\" \"pin\") list( $pinPos ) \"$pinName\" \"centerCenter\" \"R0\" \"stick\" 10)"
		puts $skillfd "printf(\">>> makeLayout: Adding label $pinName\\n\")"
		puts "$instTerm $pinName $pinPos"
	}
}

if {$CORE_CHIP == "CHIP"} {
    deselectAll
    catch {selectInstByCellName PVDD2POC}  
    catch {selectInstByCellName PVDD2CDG}  
    catch {selectInstByCellName PVSS2CDG}  
    catch {selectInstByCellName PVDD1CDG}  
    catch {selectInstByCellName PVSS1CDG}  
## removed -ncd
#        selectInstByCellName PVDD1ANA   
#	selectInstByCellName PVDD3A  
#	selectInstByCellName PVSS3A  

	foreach pInst [dbGet selected] {
		set pinName [dbGet $pInst.pgTermNets.name]

##              Fixed: This is generating labels named UNCONNECTEDxx -ncd
#		if {$pinName == 0x0} {set pinName [dbGet $pInst.instTerms.net.name]}
		if {$pinName == 0x0} {set pinName [dbGet $pInst.cell.terms.name]}

	    if {$pinName != 0x0} {
		set box [lindex [dbGet $pInst.box] 0]
		set xc [expr ( [lindex $box 0] + [lindex $box 2] ) /2 ]
		set yc [expr ( [lindex $box 1] + [lindex $box 3] ) /2 ]
		set pinPos "$xc $yc"
		puts $skillfd "label0 = dbCreateLabel(au1 list(\"$layer_top\" \"pin\") list( $pinPos ) \"$pinName\" \"centerCenter\" \"R0\" \"stick\" 10)"
		puts $skillfd "printf(\">>> makeLayout: Adding label $pinName\\n\")"
		puts "$pinName $pinPos"
#	    }
	}
	deselectAll
}





##### ####

close $skillfd

puts "  "

#####
#####

set skillfd [open "defCellLib.il" "w"]
puts $skillfd "designLib =\"$oaLibName\""
puts $skillfd [format "%s%s%s" "cellName = \"" [dbGet top.name] "\""]
close $skillfd

#set fd [open "temp.tcl" "w"]

## I dont think this is doing anything -ncd
foreach p [concat [dbGet -p top.nets.name *VDD*] [dbGet -p top.nets.name *VSS*]] {
	set pinGeom [lindex [dbGet $p.sWires.box] 0]
	set pinName [dbGet $p.name]
	puts "$pinName $pinGeom"
	if {$pinGeom != 0x0} {
		set pinLayer [string index [lindex [dbGet $p.sWires.layer.name] 0] 1]
		set nw [lindex $pinGeom 0]
		set ne [lindex $pinGeom 1]
		set sw [lindex $pinGeom 2]
		set se [lindex $pinGeom 3]
		createPGPin [dbGet $p.name] -geom $pinLayer $nw $ne $sw $se
		puts "$pinName $pinLayer $nw $ne $sw $se"
	} else { 
		set term [lindex [dbGet $p.allTerms] 0]
		if {$term != 0x0} {
			set pinPt [lindex [dbGet $term.pt] 0]
			set nw [expr [lindex $pinPt 0] - 0.1]
			set ne [expr [lindex $pinPt 1] - 0.1]
			set sw [expr [lindex $pinPt 0] + 0.1]
			set se [expr [lindex $pinPt 1] + 0.1]
			set pinLayer [string index [lindex [dbGet $term.layer.name] 0] 1]
			catch {createPGPin $pinName -geom $pinLayer $nw $ne $sw $se}
			puts "$pinName $pinLayer $nw $ne $sw $se"
		}
	}
}



#close $fd
#source temp.tcl

