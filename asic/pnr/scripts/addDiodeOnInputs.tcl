set inlist [dbGet [dbGet -p top.terms.isInput 1].name]
foreach i ${inlist} {
#	echo $i
	set newcell [string map {\[ _} [string map {\] _} $i]]
	addInst -cell ANTENNA -inst antenna_${newcell}
	attachTerm antenna_${newcell} I ${i}
	#attachDiode -diodeCell ANTENNA -pin antenna_$i
}
