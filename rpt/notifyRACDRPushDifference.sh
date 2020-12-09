#!/bin/bash

if (($# == 1))
then
	dayIndex=${1}
else
	dayIndex=2
fi

echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] RACDR (RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY) vs RPT_SUBMIT_DELIVERY_FACT_IB [ ${dayIndex} ]"
connectionString="mysql-ib -ucmsuser -pcmsuser -h10.3.60.16 -P5029 --table CMS_CDR -Ae "
compareSQLString="SELECT CDR.USER_ID, CDR.TYPE USER_NAME, RA.ENTERPRISE_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.PUSH_COUNT RA_PUSH_COUNT, RA.PUSH_COUNT-CDR.PUSH_COUNT DIFF_DELIVER FROM (SELECT CMS.STATUS USER_ID, CMS.TYPE, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, CMS_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = CMS.STATUS AND UD.USER_ID = CMS.STATUS AND CDR_DATE = DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY) GROUP BY CMS.STATUS ORDER BY CMS.STATUS) CDR, (SELECT USER_ID, ENTERPRISE_ID, SUM(TOTAL_COUNT) PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE = DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY) AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY USER_ID ORDER BY USER_ID) RA WHERE RA.USER_ID = CDR.USER_ID AND (CDR.PUSH_COUNT <> RA.PUSH_COUNT) GROUP BY CDR.USER_ID ORDER BY CDR.USER_ID;"
#compareSQLString="SELECT CDR.USER_ID, CDR.TYPE USER_NAME, RA.ENTERPRISE_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.PUSH_COUNT RA_PUSH_COUNT, RA.PUSH_COUNT-CDR.PUSH_COUNT DIFF_DELIVER FROM (SELECT RPT.TYPE, RPT.STATUS, SUM(PUSH_COUNT) PUSH_COUNT FROM (SELECT CMS.TYPE, CMS.STATUS, UD.SMS_BILLING_MODE, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, RA_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = UD.USER_ID AND UD.USER_ID = CMS.STATUS AND CDR_DATE = DATE_SUB(CURDATE(), INTERVAL ${dayIndex} DAY) GROUP BY CMS.STATUS) RPT ORDER BY RPT.STATUS) CDR, (SELECT USER_ID, ENTERPRISE_ID, SUM(TOTAL_COUNT) PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE = DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY) AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY USER_ID ORDER BY USER_ID) RA WHERE RA.USER_ID = CDR.USER_ID AND (CDR.PUSH_COUNT <> RA.PUSH_COUNT) GROUP BY CDR.USER_ID ORDER BY CDR.USER_ID;"
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] USER Count SQLString :: ${compareSQLString}"
${connectionString} "${compareSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.RACDR_PUSH_COUNT_MISMATCH.TXT
if [ -s /home/cmsuser/Scripts/ONM/.RACDR_PUSH_COUNT_MISMATCH.TXT ]
then
	alertFileName="/home/cmsuser/.ONM_STATUS/RACDR_USER_PUSH_COUNT_MISMATCH.REPORT"
	echo "$(/bin/hostname) :: RA-CDR PUSH USERWISE COUNT MISMATCH $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
	cat /home/cmsuser/Scripts/ONM/.RACDR_PUSH_COUNT_MISMATCH.TXT >> ${alertFileName}
	echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
	rm -f /home/cmsuser/Scripts/ONM/.RACDR_PUSH_COUNT_MISMATCH.TXT
else
	ls -ltrh /home/cmsuser/Scripts/ONM/.RACDR_PUSH_COUNT_MISMATCH.TXT
fi

#compareEXTERNALIDCountSQLString="SELECT RA.EXTERNAL_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.RA_PUSHCOUNT RA_CDR_COUNT, CDR.PUSH_COUNT-RA.RA_PUSHCOUNT DIFF FROM (SELECT CMS.TYPE, CMS.STATUS, CMS.EXTERNAL_ID, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, RA_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = UD.USER_ID AND UD.USER_ID = CMS.STATUS AND CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) GROUP BY CMS.EXTERNAL_ID ORDER BY CMS.EXTERNAL_ID) CDR, (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA WHERE CDR.EXTERNAL_ID=RA.EXTERNAL_ID AND CDR.PUSH_COUNT<>RA.RA_PUSHCOUNT;"
compareEXTERNALIDCountSQLString="SELECT RA.EXTERNAL_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.RA_PUSHCOUNT RA_CDR_COUNT, CDR.PUSH_COUNT-RA.RA_PUSHCOUNT DIFF FROM (SELECT RPT.TYPE, RPT.STATUS, RPT.EXTERNAL_ID, SUM(PUSH_COUNT) PUSH_COUNT FROM (SELECT CMS.TYPE, CMS.STATUS, CMS.EXTERNAL_ID, UD.SMS_BILLING_MODE, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, RA_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = UD.USER_ID AND UD.USER_ID = CMS.STATUS AND CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) GROUP BY CMS.STATUS, CMS.EXTERNAL_ID) RPT GROUP BY RPT.EXTERNAL_ID ORDER BY RPT.EXTERNAL_ID) CDR, (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA WHERE CDR.EXTERNAL_ID=RA.EXTERNAL_ID AND CDR.PUSH_COUNT<>RA.RA_PUSHCOUNT;"
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] EXTERNAL_ID Count SQLString :: ${compareEXTERNALIDCountSQLString}"
${connectionString} "${compareEXTERNALIDCountSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
if [ -s /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.REPORT"
        echo "$(/bin/hostname) :: RA-CDR PUSH COUNT (EXTERNAL_ID) MISMATCH $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
fi

identifyEXTERNALSQLString="SELECT D2.CDR_DATE, D2.USER_ID, D3.ENTERPRISE_ID OLD_ENTERPRISE_ID, D2.ENTERPRISE_ID NEW_ENTERPRISE_ID, D3.ENTERPRISE_NAME OLD_ENTERPRISE_NAME, D2.ENTERPRISE_NAME NEW_ENTERPRISE_NAME, D3.CHANNEL OLD_CHANNEL, D2.CHANNEL NEW_CHANNEL, D3.TOTAL_COUNT OLD_TOTAL_COUNT, D2.TOTAL_COUNT NEW_TOTAL_COUNT FROM  (SELECT CDR_DATE, USER_ID, ENTERPRISE_ID, ENTERPRISE_NAME, CHANNEL, TOTAL_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE = DATE_SUB(CURDATE(), INTERVAL 2 DAY)) D2, (SELECT CDR_DATE, USER_ID, ENTERPRISE_ID, ENTERPRISE_NAME, CHANNEL, TOTAL_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE = DATE_SUB(CURDATE(), INTERVAL 3 DAY)) D3 WHERE D2.USER_ID = D3.USER_ID AND D2.CHANNEL IN ('SMS', 'VMN') AND D2.ENTERPRISE_ID <> D3.ENTERPRISE_ID;"

${connectionString} "${identifyEXTERNALSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_CHANGE.TXT

if [ -s /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_CHANGE.TXT ]
then
	alertFileName="/home/cmsuser/.ONM_STATUS/RACDR_EXTERNALID_CHANGE.REPORT"
        echo "$(/bin/hostname) :: RA-CDR PUSH EXTERNAL_ID MAPPING WRONG $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_CHANGE.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_CHANGE.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.RACDR_EXTERNALID_CHANGE.TXT
fi

#comapreRADAILYCOUNTSQLString="SELECT RA_CDR.EXTERNAL_ID, RA_CDR.ENTERPRISE_NAME, DAILY_CDR.ENTERPRISE_NAME, RA_CDR.RA_PUSHCOUNT, DAILY_CDR.TOTAL_CDRCOUNT, (RA_CDR.RA_PUSHCOUNT- DAILY_CDR.TOTAL_CDRCOUNT) 'RACDR-DAILYCDR' FROM (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA_CDR, (SELECT EXTERNAL_ID, CUSTOMER_NAME ENTERPRISE_NAME, SUM(CDR_COUNT) TOTAL_CDRCOUNT FROM RECON_DAILY_CDR_COUNT WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND EXTERNAL_ID LIKE '7%' AND PRODUCT NOT IN ('OBD', 'IVR') GROUP BY EXTERNAL_ID ORDER BY EXTERNAL_ID) DAILY_CDR WHERE RA_CDR.EXTERNAL_ID = DAILY_CDR.EXTERNAL_ID AND RA_CDR.RA_PUSHCOUNT <> DAILY_CDR.TOTAL_CDRCOUNT GROUP BY RA_CDR.EXTERNAL_ID;"
comapreRADAILYCOUNTSQLString="SELECT RA_CDR.EXTERNAL_ID, RA_CDR.ENTERPRISE_NAME RA_ENTERPRISE_NAME, DAILY_CDR.ENTERPRISE_NAME CDR_ENTERPRISE_NAME, RA_CDR.RA_PUSHCOUNT, DAILY_CDR.TOTAL_CDRCOUNT, (RA_CDR.RA_PUSHCOUNT- DAILY_CDR.TOTAL_CDRCOUNT) 'RACDR-DAILYCDR' FROM (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA_CDR, (SELECT EXTERNAL_ID, CUSTOMER_NAME ENTERPRISE_NAME, SUM(CDR_COUNT) TOTAL_CDRCOUNT FROM RECON_DAILY_CDR_COUNT WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND EXTERNAL_ID LIKE '7%' AND PRODUCT NOT IN ('OBD', 'IVR') GROUP BY EXTERNAL_ID ORDER BY EXTERNAL_ID) DAILY_CDR WHERE RA_CDR.EXTERNAL_ID = DAILY_CDR.EXTERNAL_ID AND RA_CDR.RA_PUSHCOUNT <> DAILY_CDR.TOTAL_CDRCOUNT GROUP BY RA_CDR.EXTERNAL_ID;"
${connectionString} "${comapreRADAILYCOUNTSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.RACDR_DAILYCDR_MISMATCH.TXT

if [ -s /home/cmsuser/Scripts/ONM/.RACDR_DAILYCDR_MISMATCH.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/RACDR_DAILYCDR_MISMATCH.REPORT"
        echo "$(/bin/hostname) :: RA-PUSH CDR Count vs DAILY CDR Count $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.RACDR_DAILYCDR_MISMATCH.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.RACDR_DAILYCDR_MISMATCH.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.RACDR_DAILYCDR_MISMATCH.TXT
fi

selectRACDRCOUNTSQLString="SELECT ENTERPRISE_ID EXTERNAL_ID, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID;"
${connectionString} "${selectRACDRCOUNTSQLString}" | grep -v +- | awk -F'|' -v OFS='|' 'NR>1 {print $2,$3}' | sed 's/ //g' | sort -nk2 > /home/cmsuser/Scripts/ONM/.RACDR_TOTAL_COUNT_INFO.TXT
cat /data/ADARSH/Mediation_CDR/MIS_6d_Digimate_$(date --date='2 days ago' '+%Y%m*.csv')| egrep "SMS-BLENDED|VMN" | awk -F',' -v OFS=',' '{print $2,$4}' | awk -F',' -v OFS='|' '{a[$1]+=$2}END{for(i in a) print i,a[i]}' | sort -nk2 > /home/cmsuser/Scripts/ONM/.FILERACDR_TOTAL_COUNT_INFO.TXT
dos2unix /home/cmsuser/Scripts/ONM/.RACDR_TOTAL_COUNT_INFO.TXT /home/cmsuser/Scripts/ONM/.FILERACDR_TOTAL_COUNT_INFO.TXT
comm -3 /home/cmsuser/Scripts/ONM/.RACDR_TOTAL_COUNT_INFO.TXT /home/cmsuser/Scripts/ONM/.FILERACDR_TOTAL_COUNT_INFO.TXT > /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP
dos2unix /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP
#ls -ltrh /home/cmsuser/Scripts/ONM/.RACDR_TOTAL_COUNT_INFO.TXT /home/cmsuser/Scripts/ONM/.FILERACDR_TOTAL_COUNT_INFO.TXT /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP

if [ -s /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP ]
then
	sed 's/\t//g'  /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP | awk -F'|' -v OFS='|' '{x=$1;$1="";a[x]=a[x]$0}END{for(x in a)print x,a[x]}' | sed 's/||/|/g' | awk -F'|' -v OFS='|' '{print $1,$3,$2,$3-$2}' | sed 's/^/|/g' | sed 's/$/|/g' | awk -F'|' '{if(length($2) == 8) print }' > /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TXT
	if [ -s /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TXT ]
	then
	        alertFileName="/home/cmsuser/.ONM_STATUS/TOTAL_RACDR_vs_FILECOUNT_INFO.REPORT"
        	echo "$(/bin/hostname) :: RA TABLE CDR Count vs RA FILE CDR Count $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
		echo "|EXTERNAL_ID|RA_TABLE_TOTAL|RA_FILE_TOTAL|TABLE_TOTAL-FILE_TOTAL|" >> ${alertFileName}
		cat /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TXT >> ${alertFileName}
	        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
	fi
        rm -f /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.TOTAL_RACDR_vs_FILECOUNT_INFO.TEMP
fi


compareONMEXTERNALIDCountSQLString="SELECT RA.EXTERNAL_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.RA_PUSHCOUNT RA_CDR_COUNT, CDR.PUSH_COUNT-RA.RA_PUSHCOUNT DIFF FROM (SELECT RPT.TYPE, RPT.STATUS, RPT.EXTERNAL_ID, SUM(PUSH_COUNT) PUSH_COUNT FROM (SELECT CMS.TYPE, CMS.STATUS, CMS.EXTERNAL_ID, UD.SMS_BILLING_MODE, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, RA_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = UD.USER_ID AND UD.USER_ID = CMS.STATUS AND CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) GROUP BY CMS.STATUS, CMS.EXTERNAL_ID) RPT GROUP BY RPT.EXTERNAL_ID ORDER BY RPT.EXTERNAL_ID) CDR, (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM ONM_RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL ${dayIndex} DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA WHERE CDR.EXTERNAL_ID=RA.EXTERNAL_ID AND CDR.PUSH_COUNT<>RA.RA_PUSHCOUNT;"
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] EXTERNAL_ID Count SQLString :: ${compareONMEXTERNALIDCountSQLString}"
${connectionString} "${compareONMEXTERNALIDCountSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
if [ -s /home/cmsuser/Scripts/ONM/.ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.REPORT"
        echo "$(/bin/hostname) :: ONM RA-CDR PUSH COUNT (EXTERNAL_ID) MISMATCH $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.ONM_RACDR_EXTERNALID_PUSH_COUNT_MISMATCH.TXT
fi

#comapreONMRADAILYCOUNTSQLString="SELECT RA.EXTERNAL_ID, CDR.PUSH_COUNT FACT_CDR_COUNT, RA.RA_PUSHCOUNT RA_CDR_COUNT, CDR.PUSH_COUNT-RA.RA_PUSHCOUNT DIFF FROM (SELECT CMS.TYPE, CMS.STATUS, CMS.EXTERNAL_ID, CASE WHEN UD.SMS_BILLING_MODE = 'Submitted' THEN SUM(CASE WHEN STATUS_CODE = 0 THEN SUBMIT_COUNT ELSE 0 END) WHEN UD.SMS_BILLING_MODE = 'Delivered' THEN SUM(CASE WHEN (STATUS_CODE = 0 AND DEL_STATUS = 0) THEN DELIVERY_COUNT ELSE 0 END) ELSE 0 END PUSH_COUNT FROM RPT_SUBMIT_DELIVERY_FACT_IB RPT, RA_REPORT_STATUS CMS, USER_DETAILS UD WHERE RPT.USER_ID = UD.USER_ID AND UD.USER_ID = CMS.STATUS AND CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) GROUP BY CMS.EXTERNAL_ID ORDER BY CMS.EXTERNAL_ID) CDR, (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM ONM_RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA WHERE CDR.EXTERNAL_ID=RA.EXTERNAL_ID AND CDR.PUSH_COUNT<>RA.RA_PUSHCOUNT;"
comapreONMRADAILYCOUNTSQLString="SELECT RA_CDR.EXTERNAL_ID, RA_CDR.ENTERPRISE_NAME RA_ENTERPRISE_NAME, DAILY_CDR.ENTERPRISE_NAME CDR_ENTERPRISE_NAME, RA_CDR.RA_PUSHCOUNT, DAILY_CDR.TOTAL_CDRCOUNT, (RA_CDR.RA_PUSHCOUNT- DAILY_CDR.TOTAL_CDRCOUNT) 'RACDR-DAILYCDR' FROM (SELECT ENTERPRISE_ID EXTERNAL_ID, ENTERPRISE_NAME, SUM(TOTAL_COUNT) RA_PUSHCOUNT FROM ONM_RPT_SUBMIT_DELIVERY_FACT_RECON_FINAL_SUMMARY WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND ENTERPRISE_ID LIKE '7%' AND CHANNEL NOT IN ('OBD', 'IVR') GROUP BY ENTERPRISE_ID ORDER BY ENTERPRISE_ID) RA_CDR, (SELECT EXTERNAL_ID, CUSTOMER_NAME ENTERPRISE_NAME, SUM(CDR_COUNT) TOTAL_CDRCOUNT FROM RECON_DAILY_CDR_COUNT WHERE CDR_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND MONTH(CDR_DATE) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND YEAR(CDR_DATE)= YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) AND EXTERNAL_ID LIKE '7%' AND PRODUCT NOT IN ('OBD', 'IVR') GROUP BY EXTERNAL_ID ORDER BY EXTERNAL_ID) DAILY_CDR WHERE RA_CDR.EXTERNAL_ID = DAILY_CDR.EXTERNAL_ID AND RA_CDR.RA_PUSHCOUNT <> DAILY_CDR.TOTAL_CDRCOUNT GROUP BY RA_CDR.EXTERNAL_ID;"
${connectionString} "${comapreONMRADAILYCOUNTSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.ONM_RACDR_DAILYCDR_MISMATCH.TXT

if [ -s /home/cmsuser/Scripts/ONM/.ONM_RACDR_DAILYCDR_MISMATCH.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/ONM_RACDR_DAILYCDR_MISMATCH.REPORT"
        echo "$(/bin/hostname) :: ONM RA-PUSH CDR Count vs DAILY CDR Count $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.ONM_RACDR_DAILYCDR_MISMATCH.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.ONM_RACDR_DAILYCDR_MISMATCH.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.ONM_RACDR_DAILYCDR_MISMATCH.TXT
fi

selectUSERDETAILSSQLString="SELECT USER_ID,USER_NAME,FULLNAME,EXTERNAL_ID,CREATE_DATE,CHANGE_DATE FROM USER_DETAILS WHERE EXTERNAL_ID='000000' OR EXTERNAL_ID IS NULL OR FULLNAME IS NULL OR USER_NAME IS NULL OR LENGTH(FULLNAME)=0 OR LENGTH(USER_NAME)=0;"
${connectionString} "${selectUSERDETAILSSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.USER_INFO_DETAILS.TXT
if [ -s /home/cmsuser/Scripts/ONM/.USER_INFO_DETAILS.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/INCOMPLETE_USER_DETAILS_INFO.REPORT"
        echo "$(/bin/hostname) :: Incomplete User Details $(date --date='2 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.USER_INFO_DETAILS.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.USER_INFO_DETAILS.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.USER_INFO_DETAILS.TXT
fi

dupicateUSERONRAReportSQLString="SELECT * FROM RA_REPORT_STATUS WHERE STATUS NOT IN (12878) GROUP BY STATUS HAVING COUNT(*) > 1;"
${connectionString} "${dupicateUSERONRAReportSQLString}" | grep -v +- > /home/cmsuser/Scripts/ONM/.DUPLICATE_RAUSER_INFO_DETAILS.TXT
if [ -s /home/cmsuser/Scripts/ONM/.DUPLICATE_RAUSER_INFO_DETAILS.TXT ]
then
        alertFileName="/home/cmsuser/.ONM_STATUS/INCOMPLETE_USER_DETAILS_INFO.REPORT"
        echo "$(/bin/hostname) :: Duplicate User Exitistance on RA Table RA_REPORT_STATUS - $(date --date='0 day ago' '+%d-%m-%Y')." > ${alertFileName}
        cat /home/cmsuser/Scripts/ONM/.DUPLICATE_RAUSER_INFO_DETAILS.TXT >> ${alertFileName}
        echo "[TO:adarsh.rs@6dtech.co.in]" >> ${alertFileName}
        rm -f /home/cmsuser/Scripts/ONM/.DUPLICATE_RAUSER_INFO_DETAILS.TXT
else
        ls -ltrh /home/cmsuser/Scripts/ONM/.DUPLICATE_RAUSER_INFO_DETAILS.TXT
fi