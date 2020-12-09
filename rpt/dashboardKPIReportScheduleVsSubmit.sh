#!/bin/bash

if (($# > 0))
then
        cdrToken=$1
else
        cdrToken=1
fi

submitCDRTableName=$(date --date=${cdrToken}' days ago' '+SUB_CDR_%m_%d')

connectionString="mysql-ib -ucmsuser -pcmsuser -h127.0.0.1 -P5029 --table CMS_CDR -Ae "
sqlString="SELECT SUBCDR.FIELD9 SCHEDULED_USER, CMPCDR.SCHEDULE_TIME SCHEDULE_TIME, CMPCDR.TASK_ID, SUBCDR.FIELD15 TASK_NAME, CMPCDR.TASK_STATUS TASK_STATUS, CMPCDR.SCHEDULED_COUNT SCHEDULED_COUNT, COALESCE(SUBCDR.SUBMIT_COUNT, 0) SUBMIT_COUNT, CMPCDR.BLACKLIST_COUNT, (CMPCDR.SCHEDULED_COUNT - COALESCE(SUBCDR.SUBMIT_COUNT, 0)) DIFFERENCE_COUNT FROM ((SELECT TP.SCHEDULE_TIME, TP.TASK_ID, CPC.RESERVE_MSG_COUNT SCHEDULED_COUNT, CPC.BLACKLIST_COUNT, (CPC.RESERVE_MSG_COUNT-CPC.BLACKLIST_COUNT) SCHEDULED_COUNT_EXCLUDE_BLACKLIST, TP.STATUS, SD.DESCRIPTION TASK_STATUS FROM TASK_PROFILE TP, CAMPAIGN_PROCESSOR_CDR CPC, STATUS_DETAILS SD WHERE CPC.TASK_ID IN (SELECT TASK_ID FROM TASK_PROFILE WHERE DATE(SCHEDULE_TIME) = DATE(DATE_SUB(NOW(), INTERVAL ${cdrToken} DAY)) AND ISPAUSE = 0 AND STATUS IN (7) AND CHANNEL_TYPE_ID NOT IN (3)) AND CPC.TASK_ID = TP.TASK_ID AND SD.STATUS_ID = TP.STATUS ORDER BY TP.SCHEDULE_TIME) CMPCDR LEFT OUTER JOIN (SELECT TASK_ID, FIELD9, FIELD15, COUNT(CREATE_TIME) SUBMIT_COUNT FROM ${submitCDRTableName} GROUP BY TASK_ID, FIELD9, FIELD15) SUBCDR ON CMPCDR.TASK_ID = SUBCDR.TASK_ID) WHERE (CMPCDR.SCHEDULED_COUNT - COALESCE(SUBCDR.SUBMIT_COUNT, 0)) <> 0 ORDER BY CMPCDR.SCHEDULE_TIME;"

echo ${sqlString}
${connectionString} "${sqlString}" | grep -v +- > /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt
if [ -s /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt ]
then
	echo "$(/bin/hostname) :: AIRTEL DIGIMATE CAMPAIGN SCHEDULED Vs SUBMIT COUNT STATISTICS $(date --date=${cdrToken}' days ago' '+%d-%m-%Y')" > /home/cmsuser/.ONM_STATUS/$(/bin/hostname)_CAMPAIGN_SCHEDULEDvsSUBMIT.REPORT
        cat /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt
        cat /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt >> /home/cmsuser/.ONM_STATUS/$(/bin/hostname)_CAMPAIGN_SCHEDULEDvsSUBMIT.REPORT
	echo "[TO:adarsh.rs@6dtech.co.in,roshan.khatri@6dtech.co.in]" >> /home/cmsuser/.ONM_STATUS/$(/bin/hostname)_CAMPAIGN_SCHEDULEDvsSUBMIT.REPORT
	rm -f /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt
else
	ls -ltrh /home/cmsuser/Scripts/.KPIReport_ScheduledVsSubmit.txt
fi
