#!/bin/csh

echo ''
echo '***    Setting up environment variables for TSMC65 ***'

#setenv PDK_PATH /cad/Technology/TSMC650A
setenv PDK_PATH /cad/Technology/TSMC650A.new

## add for encounter-ncd
#setenv TSMC_PDK /cad/Technology/TSMC650A
setenv TSMC_PDK /cad/Technology/TSMC650A.new


setenv OSS_IRUN_BIND2 YES
setenv pvs_source_added_place TRUE

##already set correctly -ncd
#setenv AMSHOME $INCISIVE_HOME

setenv OPTION 1p9m6x1z1u
#setenv OPTION 1p6m3x1z1u

#setenv PDK_PATH /projects/cern/PDK_Updates_tsmcN65/PDK/TSMC65OA
#setenv PDK_PATH /cad/Technology/TSMC650A

setenv PDK_RELEASE V1.7A_1

### Set the default netlisting mode to "Analog" - the recommended default 
### Default may be "Digital" depending on the virtuoso executable. 
setenv CDS_Netlisting_Mode Analog

setenv QRC_ENABLE_EXTRACTION





