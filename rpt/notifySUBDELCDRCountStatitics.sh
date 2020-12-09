#!/bin/bash
function callRptFunction
{
noOfDays=$1

day=$(date --date=${noOfDays}' days ago' '+%d')
month=$(date --date=${noOfDays}' days ago' '+%m')
year=$(date --date=${noOfDays}' days ago' '+%y')

if [ -f /home/cmsuser/Scripts/.NOTIFY_SUB-DEL-CDR_COUNT_STATITICS ]
then
        exit 0
fi

touch /home/cmsuser/Scripts/.NOTIFY_SUB-DEL-CDR_COUNT_STATITICS
. $(find ~/ -maxdepth 1 -type f -iname '.bash_profile')

connectionString01="mysql-ib -ucmsuser -pcmsuser -h10.3.60.16 -P5029 CMS_CDR -Ae "
connectionString02="mysql-ib -ucmsuser -pcmsuser -h10.3.60.17 -P5029 CMS_CDR -Ae "
connectionString03="mysql-ib -ucmsuser -pcmsuser -h10.3.111.14 -P5029 CMS_CDR -Ae "
connectionString04="mysql-ib -ucmsuser -pcmsuser -h10.3.111.15 -P5029 CMS_CDR -Ae "

totalCountSUBCDRDBSQL="SELECT COUNT(*) FROM SUB_CDR_${month}_${day};"
successCountSUBCDRDBSQL="SELECT COUNT(*) FROM SUB_CDR_${month}_${day} WHERE STATUS_CODE = 0;"
totalCountDELCDRDBSQL="SELECT COUNT(*) FROM DEL_CDR_${month}_${day};"
successCountDELCDRDBSQL="SELECT COUNT(*) FROM DEL_CDR_${month}_${day} WHERE STATUS_ID = 0;"

totalCountSUBCDRDB01=$(${connectionString01} "${totalCountSUBCDRDBSQL}")
totalCountSUBCDRDB02=$(${connectionString02} "${totalCountSUBCDRDBSQL}")
totalCountSUBCDRDB03=$(${connectionString03} "${totalCountSUBCDRDBSQL}")
totalCountSUBCDRDB04=$(${connectionString04} "${totalCountSUBCDRDBSQL}")

successCountSUBCDRDB01=$(${connectionString01} "${successCountSUBCDRDBSQL}")
successCountSUBCDRDB02=$(${connectionString02} "${successCountSUBCDRDBSQL}")
successCountSUBCDRDB03=$(${connectionString03} "${successCountSUBCDRDBSQL}")
successCountSUBCDRDB04=$(${connectionString04} "${successCountSUBCDRDBSQL}")

totalCountDELCDRDB01=$(${connectionString01} "${totalCountDELCDRDBSQL}")
totalCountDELCDRDB02=$(${connectionString02} "${totalCountDELCDRDBSQL}")
totalCountDELCDRDB03=$(${connectionString03} "${totalCountDELCDRDBSQL}")
totalCountDELCDRDB04=$(${connectionString04} "${totalCountDELCDRDBSQL}")

successCountDELCDRDB01=$(${connectionString01} "${successCountDELCDRDBSQL}")
successCountDELCDRDB02=$(${connectionString02} "${successCountDELCDRDBSQL}")
successCountDELCDRDB03=$(${connectionString03} "${successCountDELCDRDBSQL}")
successCountDELCDRDB04=$(${connectionString04} "${successCountDELCDRDBSQL}")

totalCountSUBCDRDB01=$(echo ${totalCountSUBCDRDB01} | awk '{print $2}')
totalCountSUBCDRDB02=$(echo ${totalCountSUBCDRDB02} | awk '{print $2}')
totalCountSUBCDRDB03=$(echo ${totalCountSUBCDRDB03} | awk '{print $2}')
totalCountSUBCDRDB04=$(echo ${totalCountSUBCDRDB04} | awk '{print $2}')

successCountSUBCDRDB01=$(echo ${successCountSUBCDRDB01} | awk '{print $2}')
successCountSUBCDRDB02=$(echo ${successCountSUBCDRDB02} | awk '{print $2}')
successCountSUBCDRDB03=$(echo ${successCountSUBCDRDB03} | awk '{print $2}')
successCountSUBCDRDB04=$(echo ${successCountSUBCDRDB04} | awk '{print $2}')

totalCountDELCDRDB01=$(echo ${totalCountDELCDRDB01} | awk '{print $2}')
totalCountDELCDRDB02=$(echo ${totalCountDELCDRDB02} | awk '{print $2}')
totalCountDELCDRDB03=$(echo ${totalCountDELCDRDB03} | awk '{print $2}')
totalCountDELCDRDB04=$(echo ${totalCountDELCDRDB04} | awk '{print $2}')

successCountDELCDRDB01=$(echo ${successCountDELCDRDB01} | awk '{print $2}')
successCountDELCDRDB02=$(echo ${successCountDELCDRDB02} | awk '{print $2}')
successCountDELCDRDB03=$(echo ${successCountDELCDRDB03} | awk '{print $2}')
successCountDELCDRDB04=$(echo ${successCountDELCDRDB04} | awk '{print $2}')

diffTotalCountSUBCDRDB=$(( totalCountSUBCDRDB01 - totalCountSUBCDRDB02 ))
diffSuccessCountSUBCDR=$(( successCountSUBCDRDB01 - successCountSUBCDRDB02 ))
diffTotalCountDELCDR=$(( totalCountDELCDRDB01 - totalCountDELCDRDB02 ))
diffSuccessCountDELCDR=$(( successCountDELCDRDB01 - successCountDELCDRDB02 ))

echo totalCountSUBCDRDB01 :: ${totalCountSUBCDRDB01} totalCountSUBCDRDB02 :: ${totalCountSUBCDRDB02}
echo successCountSUBCDRDB01 :: ${successCountSUBCDRDB01} successCountSUBCDRDB02 :: ${successCountSUBCDRDB02}
echo totalCountDELCDRDB01 :: ${totalCountDELCDRDB01} totalCountDELCDRDB02 :: ${totalCountDELCDRDB02} 
echo successCountDELCDRDB01 :: ${successCountDELCDRDB01} successCountDELCDRDB02 :: ${successCountDELCDRDB02}

if ((${totalCountSUBCDRDB01} == ${totalCountSUBCDRDB02})) && ((${totalCountDELCDRDB01} == ${totalCountDELCDRDB02}))
then
	alertFileName="/home/cmsuser/.ONM_STATUS/$(/bin/hostname)_CDR_TABLE_COUNTS_STATITICS.MESSAGE"
	echo "$(/bin/hostname) :: CDR TABLE COUNTS MATCHING FOR ${day}-${month}-${year}." > ${alertFileName}
	echo "DB01 Counts :: Total Submit - ${totalCountSUBCDRDB01}, Submit Success - ${successCountSUBCDRDB01}, Total Delivery - ${totalCountDELCDRDB01}, Delivery Success - ${successCountDELCDRDB01}." >> ${alertFileName}
	echo "DB02 Counts :: Total Submit - ${totalCountSUBCDRDB02}, Submit Success - ${successCountSUBCDRDB02}, Total Delivery - ${totalCountDELCDRDB02}, Delivery Success - ${successCountDELCDRDB02}." >> ${alertFileName}
	echo "DR DB01 Counts :: Total Submit - ${totalCountSUBCDRDB03}, Submit Success - ${successCountSUBCDRDB03}, Total Delivery - ${totalCountDELCDRDB03}, Delivery Success - ${successCountDELCDRDB03}." >> ${alertFileName}
	echo "DR DB02 Counts :: Total Submit - ${totalCountSUBCDRDB04}, Submit Success - ${successCountSUBCDRDB04}, Total Delivery - ${totalCountDELCDRDB04}, Delivery Success - ${successCountDELCDRDB04}." >> ${alertFileName}
	 echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
else
	alertFileName="/home/cmsuser/.ONM_STATUS/CDR_TABLE_COUNTS_STATITICS.REPORT"
	echo "$(/bin/hostname) :: CDR TABLE COUNTS NOT MATCHING FOR ${day}-${month}-${year}." > ${alertFileName}
	echo "|TABLE INFO|TYPE|DB01 COUNT|DB02 COUNT|COUNT DIFFERENCE (DB01-DB02)|" >> ${alertFileName}
	echo "|SUB_CDR_${month}_${day}|SUBMIT TOTAL|${totalCountSUBCDRDB01}|${totalCountSUBCDRDB02}|${diffTotalCountSUBCDRDB}|" >> ${alertFileName}
	echo "|SUB_CDR_${month}_${day}|SUBMIT SUCCESS|${successCountSUBCDRDB01}|${successCountSUBCDRDB02}|${diffSuccessCountSUBCDR}|" >> ${alertFileName}
	echo "|DEL_CDR_${month}_${day}|DELIVERY TOTAL|${totalCountDELCDRDB01}|${totalCountDELCDRDB02}|${diffTotalCountDELCDR}|" >> ${alertFileName}
	echo "|DEL_CDR_${month}_${day}|DELIVERY SUCCESS|${successCountDELCDRDB01}|${successCountDELCDRDB02}|${diffSuccessCountDELCDR}|" >> ${alertFileName}
	echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
fi
rm -f /home/cmsuser/Scripts/.NOTIFY_SUB-DEL-CDR_COUNT_STATITICS
}

if (($# == 1))
then
	callRptFunction $1

elif (($# == 2  ))
then
   echo Start Date $1 to $2
   iVarInc=$1
   while [ $iVarInc -le $2 ]
      do        
	   echo $iVarInc days ago
           callRptFunction "$iVarInc"
	   sleep 1
           wait 
	   iVarInc=$(( iVarInc + 1 ))
	   echo $iVarInc
       done
else
	callRptFunction 1
fi


