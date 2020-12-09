#!/bin/bash

if (($# == 1))
then
        noOfDays=$1
else
        noOfDays=1
fi

day=$(date --date=${noOfDays}' days ago' '+%d')
month=$(date --date=${noOfDays}' days ago' '+%m')
year=$(date --date=${noOfDays}' days ago' '+%Y')

if [ -f /home/cmsuser/Scripts/.GENERATE_PENDING_DLVR_DETAILS ]
then
        exit 0
fi

touch /home/cmsuser/Scripts/.GENERATE_PENDING_DLVR_DETAILS
rm -f /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT
. $(find ~/ -maxdepth 1 -type f -iname '.bash_profile')

connectionString="mysql-ib -ucmsuser -pcmsuser -h127.0.0.1 -P5029 --table CMS_CDR -Ae "
recreateONMTableSQLString="DROP TABLE ONM_DELIVER_PENDING_DETAILS_OFFLINE_IB; CREATE TABLE ONM_DELIVER_PENDING_DETAILS_OFFLINE_IB LIKE TMP_DELIVER_PENDING_DETAILS_IB;"

insertOnONMTableSQLString="INSERT INTO ONM_DELIVER_PENDING_DETAILS_OFFLINE_IB (CREATE_TIME, USER_NAME, INTERFACE_ID, ACK_ID, SMSC_ID, DA ,OA) SELECT A.CREATE_TIME, A.FIELD9, A.INTERFACE_ID, A.ACK_ID, A.SMSC_ID, A.DA, A.OA FROM (SELECT SUB.CREATE_TIME CREATE_TIME, SUB.FIELD9 FIELD9, SUB.INTERFACE_ID INTERFACE_ID, SUB.ACK_ID ACK_ID, SUB.SMSC_ID SMSC_ID, SUB.DA DA, DEL.ACK_ID DEL_ACK_ID, SUB.OA OA FROM (SELECT CREATE_TIME, FIELD9, INTERFACE_ID, ACK_ID, SMSC_ID, DA, OA  FROM SUB_CDR_${month}_${day} WHERE STATUS_CODE = 0 AND CREATE_TIME BETWEEN '${year}-${month}-${day} 00:00:00' AND '${year}-${month}-${day} 23:59:59' AND SUBMIT_DATE = '${year}-${month}-${day}' GROUP BY ACK_ID) SUB LEFT OUTER JOIN (SELECT DISTINCT ACK_ID ACK_ID FROM DEL_CDR_${month}_${day}) DEL ON SUB.ACK_ID=DEL.ACK_ID) A  WHERE A.DEL_ACK_ID IS NULL;"

dlvrPendingSQLString="SELECT CONCAT(DATE(ONM.CREATE_TIME), ' ', HOUR(ONM.CREATE_TIME)) HOUR, ONM.USER_NAME SCHEDULED_USER, ID.INTERFACE_NAME INTERFACE_NAME, COUNT(ONM.ACK_ID) DLVR_PENDING_COUNT FROM ONM_DELIVER_PENDING_DETAILS_OFFLINE_IB ONM, INTERFACE_DETAILS ID WHERE ONM.INTERFACE_ID = ID.INTERFACE_ID GROUP BY HOUR(ONM.CREATE_TIME), ONM.USER_NAME, ONM.INTERFACE_ID, ONM.SMSC_ID ORDER BY HOUR(ONM.CREATE_TIME), ONM.USER_NAME, ONM.INTERFACE_ID;"
echo "ONM TABLE SQL :: ${insertOnONMTableSQLString}"
echo "DLVR PENDING SQL :: ${dlvrPendingSQLString}"
${connectionString} "${recreateONMTableSQLString} ${insertOnONMTableSQLString} ${dlvrPendingSQLString}" | grep -v +- > /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT
if [ -s /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT ]
then
	alertFile="/home/cmsuser/.ONM_STATUS/DLVR_Report_Pending_Statitics.REPORT"
	totalDLVRPendingCount=$(awk -F'|' 'NR > 1 {sum+=$5}END {print sum;}' /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT)
	echo "| TOTAL COUNT | ALL USERS | ALL CHANNEL | ${totalDLVRPendingCount} |" >> /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT

        echo "AIRTEL - DIGIMATE :: SMSC Delivery Reports Pending Statitics - Yesterday ($(date --date=${noOfDays}' days ago' '+%d-%b-%y'))" > ${alertFile}
        cat /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT >> ${alertFile}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFile}
	rm -f /home/cmsuser/Scripts/DLVR_Report_Pending_Statitics.REPORT
	cat /home/cmsuser/.ONM_STATUS/DLVR_Report_Pending_Statitics.REPORT
fi
rm -f /home/cmsuser/Scripts/.GENERATE_PENDING_DLVR_DETAILS
