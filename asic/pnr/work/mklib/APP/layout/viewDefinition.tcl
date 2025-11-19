if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name libs_typ_9t\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn65lptc.lib\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3tc.lib\
    ${::IMEX::libVar}/mmmc/tpan65lpnv2od3tc.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/tcbn65lptc.cdb\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3tc.cdb]
create_library_set -name libs_min_9t\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn65lplt.lib\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3lt.lib\
    ${::IMEX::libVar}/mmmc/tpan65lpnv2od3lt.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/tcbn65lplt.cdb\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3lt.cdb]
create_library_set -name libs_max_9t\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn65lpwc.lib\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3wc.lib\
    ${::IMEX::libVar}/mmmc/tpan65lpnv2od3wc.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/tcbn65lpwc.cdb\
    ${::IMEX::libVar}/mmmc/tpdn65lpnv2od3wc.cdb]
create_op_cond -name oc_typ_9t -library_file ${::IMEX::libVar}/mmmc/tcbn65lptc.lib -P 1 -V 1.2 -T 25
create_op_cond -name oc_min_9t -library_file ${::IMEX::libVar}/mmmc/tcbn65lplt.lib -P 1 -V 1.32 -T 0
create_op_cond -name oc_max_9t -library_file ${::IMEX::libVar}/mmmc/tcbn65lpwc.lib -P 1 -V 1.08 -T -25
create_rc_corner -name RC_BEST\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_BEST/qrcTechFile
create_rc_corner -name RC_TYP\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_TYP/qrcTechFile
create_rc_corner -name RC_WORST\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/RC_WORST/qrcTechFile
create_delay_corner -name av_min_dc\
   -library_set libs_min_9t\
   -opcond_library tcbn65lplt\
   -opcond oc_min_9t\
   -rc_corner RC_BEST
update_delay_corner -name av_min_dc -power_domain core9t\
   -library_set libs_min_9t\
   -opcond_library tcbn65lplt\
   -opcond oc_min_9t
create_delay_corner -name av_max_dc\
   -library_set libs_max_9t\
   -opcond_library tcbn65lpwc\
   -opcond oc_max_9t\
   -rc_corner RC_WORST
update_delay_corner -name av_max_dc -power_domain core9t\
   -library_set libs_max_9t\
   -opcond_library tcbn65lpwc\
   -opcond oc_max_9t
create_delay_corner -name av_typ_dc\
   -library_set libs_typ_9t\
   -opcond_library tcbn65lptc\
   -opcond oc_typ_9t\
   -rc_corner RC_TYP
update_delay_corner -name av_typ_dc -power_domain core9t\
   -library_set libs_typ_9t\
   -opcond_library tcbn65lptc\
   -opcond oc_typ_9t
create_constraint_mode -name default_mode\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/r2g.sdc]
create_analysis_view -name av_typ -constraint_mode default_mode -delay_corner av_typ_dc
create_analysis_view -name av_min -constraint_mode default_mode -delay_corner av_min_dc
create_analysis_view -name av_max -constraint_mode default_mode -delay_corner av_max_dc
set_analysis_view -setup [list av_min av_typ] -hold [list av_min av_max]
