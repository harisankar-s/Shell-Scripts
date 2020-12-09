#!/bin/bash

userInfo=$(/usr/bin/whoami)

if [[ ${userInfo} != "root" ]]
then 
        echo "******************************HELLO!!! PLEASE RUN ME FROM ROOT USER******************************"
        exit 0
fi

echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] STARTING... POPULATING TABLE RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY for SMS."
#sh /home/cmsuser/Scripts/RA_CDR_REPORTS/manualPopulateRACDR.sh
mysql-ib -ucmsuser -pcmsuser -P5029 -h127.0.0.1 CMS_CDR -Ae "call Populate_Enterprise_RECON();"

echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] POPULATING TABLE RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY for VOICE/BPCL AND OTHER RECON TABLES"
sh /home/cmsuser/Scripts/RA_CDR_REPORTS/ReconReports.sh

connectionString="mysql-ib -ucmsuser -pcmsuser -h127.0.0.1 -P5029 CMS_CDR -Ae "
sqlStringCloud="UPDATE RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY SET CHANNEL='VMN' WHERE ENTERPRISE_NAME='SYNIVERSE' and CDR_DATE = DATE(DATE_SUB(NOW(), INTERVAL 2 DAY));"
sqlStringCloud1="UPDATE RECON_ACTIVE_SUBSCRIBER_LIST SET PRODUCT='VMN' WHERE CUSTOMER_NAME='SYNIVERSE';"
sqlStringCloud2="UPDATE RECON_CUSTOMER_QUOTA_REPORT SET PRODUCT='VMN' WHERE CUSTOMER_NAME='SYNIVERSE';"
sqlStringCloud3="UPDATE RECON_DAILY_CDR_COUNT SET PRODUCT='VMN',TYPE_ID='82310' WHERE CUSTOMER_NAME='SYNIVERSE' and CDR_DATE = DATE(DATE_SUB(NOW(), INTERVAL 2 DAY));" 
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] UPDATING TABLES RECON_ACTIVE_SUBSCRIBER_LIST, RECON_CUSTOMER_QUOTA_REPORT, RECON_DAILY_CDR_COUNT For -- SYNIVERSE--"
${connectionString} "${sqlStringCloud}"
${connectionString} "${sqlStringCloud1}" 
${connectionString} "${sqlStringCloud2}" 
${connectionString} "${sqlStringCloud3}" 
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] COMPLETING... POPULATING TABLE RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY TABLE"
