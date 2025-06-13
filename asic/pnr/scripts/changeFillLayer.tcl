set swirelist [dbGet -p top.nets.sWires.shape fillwire]
if {$swirelist != 0x0} {
	foreach swire $swirelist {
		dbSetStripBoxShape $swire notype
	}
}
 
set svialist [dbGet -p top.nets.sVias.shape fillwire]
if {$svialist != 0x0} {
	foreach sviainst $vialist { 
		dbSetStripBoxShape $sviainst notype
	}
}


#Be VERY careful to do this at the very last stage, otherwise you will not be able to delete Metal fill using deleteMetalFill. I really do not recommand to do it as it a big source of mistake. People will really have to be aware of this, and additionnaly IBM will not be able to check DRC metal fill properly!
