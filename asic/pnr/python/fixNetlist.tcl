

## private namespace "ec" to prevent name clash
#namespace eval el {}


#set el::add_nw_sx_options { -n -H SUB -m AGIO_\\w*,PIO_PADRING_CONNECTOR3,PIO_PADRING_CONNECTOR2,CoarseFineDelay_macro,FDelay_macro,fineDelay_macro,AutoMon_top,HCC_ePll,PIO_ANA,PIO_ANA_50,PIO_INP,PIO_INP_PD,PIO_REC160,PIO_REC160_hcc,PIO_DRV160,PIO_DRV160_hcc,PIO_HYSTREC,PIO_PRE_EMPH,halfFineDelay_macro,RC_delay_HCC,temp_Measure,Amplifier_HV,PM_promptCell2x50u50u,AGIO_VDD_halfVDD -r ../config/netlist_regexp_ncd.cfg}


set add_nw_sx_options {-n -H SUB -m -r ../python/netlist_regexp_ncd.cfg}

#eval "exec ../scripts/AddNWSX.py $el::add_nw_sx_options <lvs.v >lvs_nw_sx.v"
eval "exec ../python/AddNWSX.py add_nw_sx_options <lvs.v >lvs_apple.v"


#### ./AddNWSX.py -n -H -m -r ./netlist_regexp_ncd.cfg < lvs.v > lvs_out.v
