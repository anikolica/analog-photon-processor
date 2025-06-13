## This script adds bond pads overtop of each I/O instance -ncd
deselectAll
## add catch to ignore nonexistant pad name matches -ncd 
catch { selectInstByCellName P*CDG }  
catch { selectInstByCellName PVDD*POC }  
catch { selectInstByCellName PDB*A*  }
catch { selectInstByCellName PVDD*A*  }
catch { selectInstByCellName PVSS*A*  }
foreach ioInst [dbGet selected] {
	set name [string map { \{ _ \} _ \[ _ \] _} [dbGet $ioInst.name]]
	set x [lindex [lindex [dbGet $ioInst.pt] 0] 0]
	set y [lindex [lindex [dbGet $ioInst.pt] 0] 1]
	set orient [dbGet $ioInst.orient]
	if {$orient == "R180"} {set y [expr $y + 31.5]}
	if {$orient == "R90"} {set x [expr $x + 31.5]}
	addInst -physical -cell PAD50LU -inst pad_$name -loc $x $y -ori $orient -status fixed 		 
}
deselectAll
