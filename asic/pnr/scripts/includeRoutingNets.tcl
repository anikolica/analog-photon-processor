# set skip_routing true for ALL nets -ncd 2025
# Cancels effect of excludeRoutingNets.tcl script 


foreach net [get_db nets] {
    set netname [get_db $net .name]
    setAttribute -net $netname -skip_routing false
    puts "Cleared skip_routing on net: $netname"
}
