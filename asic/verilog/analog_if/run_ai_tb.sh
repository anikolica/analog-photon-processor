#!/bin/sh

#
# Run the script plan to bring up the GUI or
#   run as "env GUI=0 ./run_ai_tb.sh" to disable the GUI
#

if [ "x$GUI" = "x" ] ; then
    GUI=1
fi

if [ $GUI = 1 ] ; then
    GUI_OPT="+gui"
else
    GUI_OPT=""
fi

xrun $GUI_OPT -access +rw tb_analog_if.v analog_if.v cmp_sync.v \
     cmp_latch.v clk_cnter.v controller.sv \
     ../LI_control.v ../trig_cont.v \
     ../amem_core.v ../prio_enc_mod8.v ../one_shot_3.v
