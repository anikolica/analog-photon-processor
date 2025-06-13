#!/bin/sh
###################################################
##
## Created on Oct  29  2013 
## by Sandro Bonacini
## CERN PH/ESE/ME
##
###################################################
for i in *
do
	if test -L $i
	then
 		rm $i
	fi
done

#set NMETALS=`echo $TSMC_PDK | sed -e "s/.*1p//" | sed -e "s/m.*//"`
#ln -s $TSMC_PDK/../../digital/Back_End/lef/tcbn65lp_200a/techfiles/captable/cln65lp_1p0${NMETALS}m+alrdl_top2_rcbest.captable
#ln -s $TSMC_PDK/../../digital/Back_End/lef/tcbn65lp_200a/techfiles/captable/cln65lp_1p0${NMETALS}m+alrdl_top2_rcworst.captable
#ln -s $TSMC_PDK/../../digital/Back_End/lef/tcbn65lp_200a/techfiles/captable/cln65lp_1p0${NMETALS}m+alrdl_top2_typical.captable
#ln -s $TSMC_PDK/../../digital/Back_End/lef/tcbn65lp_200a/techfiles/Virtuoso/techfXL_UTM/Vir65nm_6M_3X1Z1U_v1.4b.042508.tf 
#ln -s $TSMC_PDK/../../digital/Back_End/lef/tcbn65lp_200a/lef/tcbn65lp_6lmT2.lef 

ln -s $TSMC_PDK/PVS_QRC/lvs/source.added
ln -s $TSMC_PDK/PVS_QRC/QRC/rcbest
ln -s $TSMC_PDK/PVS_QRC/QRC/rcworst
ln -s $TSMC_PDK/PVS_QRC/QRC/typical
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/ECSM/tcbn65lp_200a/tcbn65lpbc_ecsm.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/ECSM/tcbn65lp_200a/tcbn65lptc_ecsm.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/ECSM/tcbn65lp_200a/tcbn65lpwc_ecsm.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/ECSM/tcbn65lp_200a/tcbn65lplt_ecsm.lib
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lp_200c/tcbn65lptc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lp_200c/tcbn65lpwc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lp_200c/tcbn65lplt.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lp_200c/tcbn65lpbc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvttc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtbc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtwc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtlt.cdb
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvttc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtwc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtlt.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvtbc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lpbc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lptc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lpwc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tcbn65lp_200a/tcbn65lplt.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3bc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3tc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3wc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a/tpdn65lpnv2od3lt.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpan65lpnv2od3_200a/tpan65lpnv2od3wc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpan65lpnv2od3_200a/tpan65lpnv2od3lt.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpan65lpnv2od3_200a/tpan65lpnv2od3tc.lib
ln -s $TSMC_PDK/../../digital/Front_End/timing_power_noise/NLDM/tpan65lpnv2od3_200a/tpan65lpnv2od3bc.lib
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tpdn65lpnv2od3_200a/tpdn65lpnv2od3tc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tpdn65lpnv2od3_200a/tpdn65lpnv2od3wc.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tpdn65lpnv2od3_200a/tpdn65lpnv2od3lt.cdb
ln -s $TSMC_PDK/../../digital/Back_End/celtic/tpdn65lpnv2od3_200a/tpdn65lpnv2od3bc.cdb
ln -s $TSMC_PDK/tsmcN65/tsmcN65.layermap
ln -s $TSMC_PDK/../../digital/Back_End/spice/tpan65lpnv2od3_200b/tpan65lpnv2od3.spi
ln -s $TSMC_PDK/../../digital/Back_End/spice/tpdn65lpnv2od3_140b/tpdn65lpnv2od3_1_2.spi
ln -s $TSMC_PDK/../..//digital/Back_End/spice/tcbn65lp_200a/tcbn65lp_200a.spi
ln -s $TSMC_PDK/../..//digital/Back_End/spice/tcbn65lpbwp7thvt_141a/tcbn65lpbwp7thvt_141a.spi

echo $TSMC_PDK

rm cds.lib
MSTACK=`echo $TSMC_PDK | sed -e "s/.*1p/1p/"`
echo INCLUDE ../scripts/project.lib >cds.lib
echo DEFINE tcbn65lp $TSMC_PDK/../../digital/Back_End/cdk/tcbn65lp_200a_oa/$MSTACK/tcbn65lp >>cds.lib
echo DEFINE tcbn65lpbwp7thvt $TSMC_PDK/../../digital/Back_End/cdk/tcbn65lpbwp7thvt_200a_oa/tcbn65lpbwp7thvt >>cds.lib
echo DEFINE tpan65lpnv2od3 $TSMC_PDK/../../digital/Back_End/cdk/tpan65lpnv2od3_200a_oa/$MSTACK/mt_2/*/tpan65lpnv2od3 >>cds.lib
echo DEFINE tpdn65lpnv2od3 $TSMC_PDK/../../digital/Back_End/cdk/tpdn65lpnv2od3_140b_oa/$MSTACK/mt_2/*/tpdn65lpnv2od3 >>cds.lib
echo DEFINE tpbn65v $TSMC_PDK/../../digital/Back_End/cdk/tpbn65v_200b_oa/$MSTACK/tpbn65v >>cds.lib

