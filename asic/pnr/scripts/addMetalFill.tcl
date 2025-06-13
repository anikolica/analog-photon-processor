###################################################
##
## Created on Nov  26  2009 
## by Sandro Bonacini
## CERN PH/ESE/ME
##
###################################################

deleteMetalFill -shapes { FILLWIRE FILLWIREOPC } -mode all

set box [split [join [dbGet top.fPlan.corebox]]]
set ne [lindex $box 0]
set nw [lindex $box 1]
set se [lindex $box 2]
set sw [lindex $box 3]


#setMetalFill -layer 6 -minDensity 27.00
#setMetalFill -layer 7 -minDensity 23.00
#setMetalFill -layer 7 -minLength 5 -minWidth 2


#addMetalFill -layer { 1 2 3 4 5 6 7 } -area $ne $nw $se $sw -onCells
addMetalFill -area $ne $nw $se $sw -onCells
