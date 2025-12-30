## Add bondpads for double-wide ESD pads -ncd 2025

deselectAll

## Select IO pads by instance name patterns
catch { selectInstByCellName ESD_DIFF_Penn2}

foreach ioInst [dbGet selected] {
    set name [string map { \{ _ \} _ \[ _ \] _ } [dbGet $ioInst.name]]
    set x [lindex [lindex [dbGet $ioInst.pt] 0] 0]
    set y [lindex [lindex [dbGet $ioInst.pt] 0] 1]
    set orient [dbGet $ioInst.orient]

    ## Apply orientation-specific offset
    if {$orient == "R270"} {
        ## First pad at x+25
        addInst -physical -cell PAD50LU -inst pad_${name}_a \
            -loc [expr {$x + 0}] [expr {$y + 145}] -ori $orient -status fixed

        ## Second pad at x+125
        addInst -physical -cell PAD50LU -inst pad_${name}_b \
            -loc [expr {$x + 0}] [expr {$y + 45}] -ori $orient -status fixed
    } 



    if {$orient == "R90"}  {
        ## First pad at x+25
        addInst -physical -cell PAD50LU -inst pad_${name}_a \
            -loc [expr {$x + 121.5}] [expr {$y + 25}] -ori $orient -status fixed

        ## Second pad at x+125
        addInst -physical -cell PAD50LU -inst pad_${name}_b \
            -loc [expr {$x + 121.5}] [expr {$y + 125}] -ori $orient -status fixed
    } 



    if {$orient == "R180"} {
        ## First pad at x+25
        addInst -physical -cell PAD50LU -inst pad_${name}_a \
            -loc [expr {$x + 50}] [expr {$y + 111.1}] -ori $orient -status fixed

        ## Second pad at x+125
        addInst -physical -cell PAD50LU -inst pad_${name}_b \
            -loc [expr {$x + 150}] [expr {$y + 111.1}] -ori $orient -status fixed
    } 

    
    if {$orient == "R0"}   {
        ## First pad at x+25
        addInst -physical -cell PAD50LU -inst pad_${name}_a \
            -loc [expr {$x + 0}] $y -ori $orient -status fixed

        ## Second pad at x+125
        addInst -physical -cell PAD50LU -inst pad_${name}_b \
            -loc [expr {$x + 100}] $y -ori $orient -status fixed
    } 







    ## Place bond pad
#    addInst -physical -cell PAD50LU -inst pad_$name -loc $x $y -ori $orient -status fixed
}

deselectAll
