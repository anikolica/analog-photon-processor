# === CONFIGURATION ===
set bondpadCell "PAD50LU_Penn"
set ioVerilog "lvs.v"
set stitchVerilog "bondpad_stitch.v"
set skillOut "addPins.il"
set stitchLog "stitch_debug.log"
set pinLog "addPins_debug.log"

set fpStitch [open $stitchLog "w"]
global fpStitch
proc logStitch {msg} {
    global fpStitch
    puts $msg
    puts $fpStitch $msg
    flush $fpStitch
}

# === STEP 0: Save Verilog netlist from Innovus ===
saveNetlist $ioVerilog -excludeLeafCell -includePowerGround -excludeCellInst PRCUTA
logStitch "? Verilog netlist saved to $ioVerilog"

# === STEP 1: Parse Verilog to build netMap ===
array set pinMap {
    PDB1AC_Penn   AIO
    PDB1A_Penn    AIO
    PDB2AC_Penn   AIO
    PDB2A_Penn    AIO
    PDB3AC_Penn   AIO
    PDB3A_Penn    AIO
    PVDD3AC_Penn  TACVDD
    PVDD3A_Penn   TAVDD
    PVSS2AC_Penn  VSS
    PVSS2A_Penn   VSS
    PVSS3AC_Penn  AVSS
    PVSS3A_Penn   AVSS
    PDDW0408SCDG  PAD
    PVDD2CDG      VDDPST
    PVDD1CDG      VDD
    PVDD1ANA      AVDD
    PVDD2ANA      AVDD
    PVSS1ANA      AVSS
    PVSS1CDG      VSS
    PVSS2ANA      AVSS
    PVSS2CDG      VSSPST
    PVSS3CDG      VSS
    PVDD2POC      VDDPST
}

array set netMap {}
array set cellTypeMap {}

set fpv [open $ioVerilog r]
set verilogLines [split [read $fpv] "\n"]
close $fpv

set insideBlock 0
set currentBlock ""
set instName ""
set cellType ""

foreach line $verilogLines {
    set line [string trim $line]
    if {[regexp {^(\S+)\s+(\S+)\s*\($} $line -> cellType instName]} {
        set insideBlock 1
        set currentBlock "$line\n"
        set cellTypeMap($instName) $cellType
        continue
    }
    if {$insideBlock} {
        append currentBlock "$line\n"
        if {[regexp {\)\s*;} $line]} {
            set insideBlock 0
            foreach blockLine [split $currentBlock "\n"] {
                set blockLine [regsub {[,].*|//.*$} $blockLine ""]
                set blockLine [string trim $blockLine]
                if {[regexp {^\s*\.(\w+)\s*\(\s*([^)]+)\s*\)} $blockLine -> pin net]} {
                    set key "$instName,$pin"
                    set netMap($key) $net
                    logStitch "? Parsed $instName.$pin ? $net"
                }
            }
            set currentBlock ""
            set instName ""
            set cellType ""
        }
    }
}

logStitch "? Total parsed nets: [array size netMap]"

# === STEP 2: Write stitched pad connections to Verilog ===
set fpOut [open $stitchVerilog "w"]
set stitchedCount 0

foreach key [array names netMap] {
    set parts [split $key ","]
    if {[llength $parts] != 2} {
        logStitch "! Malformed key: '$key' ? skipping"
        continue
    }
    set inst [string trim [lindex $parts 0]]
    set pin  [string trim [lindex $parts 1]]
    set net  $netMap($key)

    if {[info exists cellTypeMap($inst)]} {
        set cellTypeLocal [string trim $cellTypeMap($inst)]
        if {[info exists pinMap($cellTypeLocal)]} {
            set expectedPin $pinMap($cellTypeLocal)
            if {$pin eq $expectedPin} {
                puts $fpOut [format "%s pad_%s (.IOPAD(%s));" $bondpadCell $inst $net]
                incr stitchedCount
            } else {
                logStitch "! Skipping $inst.$pin ? pin '$pin' ? expected '$expectedPin'"
            }
        } else {
            logStitch "! Skipping $inst.$pin ? unknown cellType '$cellTypeLocal'"
        }
    } else {
        logStitch "! Skipping $inst.$pin ? missing cellTypeMap entry"
    }
}

close $fpOut
logStitch "? Stitched pad connections written to $stitchVerilog ? total: $stitchedCount"

# === STEP 3: Generate SKILL label placement file from bondpad_stitch.v ===
set skillfd [open $skillOut "w"]
set fpPins [open $pinLog "w"]
global fpPins
proc logPins {msg} {
    global fpPins
    puts $msg
    puts $fpPins $msg
    flush $fpPins
}

set topRoutingLayer 9
set layer_top [lindex [dbGet [dbGet -p head.layers.type routing].name] [expr $topRoutingLayer - 1]]

puts $skillfd ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
puts $skillfd ";; Auto-generated SKILL to label PAD50LU bondpads"
puts $skillfd ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
puts $skillfd ""
puts $skillfd "let((inst bbox llx lly urx ury xc yc layer_top)"
puts $skillfd "  layer_top = \"$layer_top\""
puts $skillfd ""

set fpv [open $stitchVerilog r]
set lines [split [read $fpv] "\n"]
close $fpv

foreach line $lines {
    set line [string trim $line]
    if {[regexp {^PAD50LU_Penn\s+(pad_\S+)\s+\(\.IOPAD\((\S+)\)\);} $line -> inst net]} {
        logPins "? Found bondpad instance $inst with net $net"
        puts $skillfd "  inst = dbFindAnyInstByName(au1 \"$inst\")"
        puts $skillfd "  when(inst"
        puts $skillfd "    bbox = dbGetq(inst bBox)"
        puts $skillfd "    llx = xCoord(lowerLeft(bbox))"
        puts $skillfd "    lly = yCoord(lowerLeft(bbox))"
        puts $skillfd "    urx = xCoord(upperRight(bbox))"
        puts $skillfd "    ury = yCoord(upperRight(bbox))"
        puts $skillfd "    xc = (llx + urx) / 2"
        puts $skillfd "    yc = (lly + ury) / 2"
        puts $skillfd "    dbCreateLabel(au1 list(layer_top \"pin\") list(xc yc) \"$net\" \"centerCenter\" \"R0\" \"stick\" 10)"
        puts $skillfd "    printf(\">>> makeLayout: Adding label $net\\n\")"
        puts $skillfd "  )"
        puts $skillfd ""
        logPins "? Label SKILL written for $inst ? $net"
    } else {
        logPins "! Skipping line: '$line' ? no match"
    }
}

puts $skillfd ") ;; end let"
close $skillfd
close $fpPins
logStitch "? SKILL label file written to $skillOut"
logStitch "? Label debug log written to $pinLog"
