### This excludes nets matching the patterns: -ncd OK!2025
### by setting "skip_routing true" attribute
# === CONFIG ===
set patterns {"*VDD*" "*VSS*" "*AVDD*" "*AVSS*" "POC"} ;# Adjust as needed
set log_file "excluded_nets.log"

# === LOGGING SETUP ===
set fp [open $log_file w]
puts $fp "# Nets excluded from routing and optimization"
puts $fp "# Timestamp: [clock format [clock seconds]]"
puts $fp ""

# === GET AND FILTER NETS ===
set all_nets [get_db nets]
set matched_nets [list]

foreach net $all_nets {
    # Extract flat net name from handle like net:APP/VDD or net:APP/a_i[3]
    if {[regexp {^net:.*?/([^/\[\]]+)(?:\[.*\])?$} $net -> netname]} {
        foreach pat $patterns {
            if {[string match $pat $netname]} {
                setAttribute -net $netname -skip_routing true
#		setAttribute -net $net -special true
#                setAttribute -net $netname -skip_opt true
                puts $fp $netname
                lappend matched_nets $netname
                break
            }
        }
    }
}

close $fp
puts "Excluded [llength $matched_nets] nets from routing and optimization. See '$log_file' for details."

