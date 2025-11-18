## Add bondpads for double-wide ESD pads -ncd 2025

deselectAll

## Select IO pads by instance name patterns
catch { selectInstByCellName ESD_PDB1AC_Penn }

foreach ioInst [dbGet selected] {
    set name [string map { \{ _ \} _ \[ _ \] _ } [dbGet $ioInst.name]]
    set x [lindex [lindex [dbGet $ioInst.pt] 0] 0]
    set y [lindex [lindex [dbGet $ioInst.pt] 0] 1]
    set orient [dbGet $ioInst.orient]

    ## Apply orientation-specific offset
    if {$orient == "R270"} { set y [expr {$y + 70}] }
    if {$orient == "R90"}  {
        set y [expr {$y - 70}]
        set x [expr {$x + 31.5}]
    }
    if {$orient == "R180"} {
        set x [expr {$x + 70}]
        set y [expr {$y + 31.5}]
    }
    if {$orient == "R0"}   { set x [expr {$x - 70}] }

    ## Place bond pad
    addInst -physical -cell PAD50LU -inst pad_$name -loc $x $y -ori $orient -status fixed
}

deselectAll
