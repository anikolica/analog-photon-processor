;###################################################
;##
;## Created on Aug  26  2013 
;## by Sandro Bonacini
;## CERN PH/ESE/ME
;##
;###################################################

viewName = "dfm"
load("defCellLib.il")

l0= ddGetObj(designLib)
 
;############ process autoLayout ###########
au0 = dbOpenCellViewByType(l0 cellName viewName "maskLayout" "a")
dbSave(au0 designLib cellName "layout")
dbClose(au0)

au1 = dbOpenCellViewByType(l0 cellName "layout" "maskLayout" "a")
load("addPins.il")
;# 1. add labels for each pin
foreach(sh0 au1~>shapes
	if((sh0~>pin) then
		bBox = sh0~>bBox
		xLL = xCoord(lowerLeft(bBox))
		yLL = yCoord(lowerLeft(bBox))
		xUR = xCoord(upperRight(bBox))
		yUR = yCoord(upperRight(bBox))
		xPinCenter = (xUR - xLL)/2 + xLL
		yPinCenter = (yUR - yLL)/2 + yLL
		pinFill = dbCreateRect( au1 list(car(sh0~>lpp) "drawing") bBox )
		label0 = dbCreateLabel(au1 list(car(sh0~>lpp) "pin") list(xPinCenter yPinCenter ) sh0~>net~>term~>name "centerCenter" "R0" "stick" 0.2)
		printf(">>> makeLayout: Adding label %s to %s pin\n" sh0~>net~>term~>name car(sh0~>lpp))
	)

	if(((sh0~>purpose) == "fill") then
		sh0~>purpose = "drawing"
	)
)

dbSave(au1)
dbClose(au1)

;#au1 = dbOpenCellViewByType(l0 cellName viewName "maskLayout" "a")
;#dbSave(au1 designLib cellName "layout")
;#dbClose(au1)
 
au2 = dbOpenCellViewByType(l0 cellName "layout" "maskLayout" "a")
;# 2. swap out all abstracts for layouts
foreach( i0 au2~>instances
         if( i0~>viewName == "abstract" then
             ;#printf(">>> makeLayout: Replacing abstract view with layout for %s %s\n" i0~>name i0~>cellName)
             leReplaceAnyInstMaster(i0 i0~>libName nil "layout")
         )
)
 
dbSave(au2 designLib cellName "layout")
dbClose(au2)
