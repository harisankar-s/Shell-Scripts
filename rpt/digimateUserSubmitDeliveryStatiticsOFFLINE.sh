#!/bin/bash

#OFFLINE DASHBOARD & CAMPAIGN STATUS XLS REPORTS

if [ -f /home/cmsuser/Scripts/.DIGIMATE_USER_SUBMIT_DELIVERY_STATITICS_OFFLINE.PROCESS ]
then
	ls /home/cmsuser/Scripts/.DIGIMATE_USER_SUBMIT_DELIVERY_STATITICS_OFFLINE.PROCESS
	exit 0
fi

touch /home/cmsuser/Scripts/.DIGIMATE_USER_SUBMIT_DELIVERY_STATITICS_OFFLINE.PROCESS

if (($# > 0))
then
	cdrToken=$1
else
	cdrTtoken=1
fi

rptPath=/home/cmsuser/Scripts/.REPORTS/
rptDate=$(date --date=${cdrToken}' days ago' '+%Y-%m-%d')
repoDate=$(date --date=${cdrToken}' days ago' '+%y%b%d')
mkdir -p ${rptPath}
rm -f ${rptPath}/*

connectionString="mysql-ib -ucmsuser -pcmsuser -h10.3.60.17 -P5029 --table CMS_CDR -Ae "
echo
#_____________________________________________________________________#USER_SUBMIT_STATUS_REPORT#_________________________________________________________________#
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] ==============================STARING USER SUBMIT STATUS CODE BASED REPORT GENERATION========================="
fetchSTATUSCODESQLString="SELECT DISTINCT(FACT.STATUS_CODE), COALESCE(UCASE(SSCI.DESCRIPTION),'UNKNOWN ERROR') FROM (SELECT DISTINCT(STATUS_CODE) FROM CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB WHERE CDR_DATE = '${rptDate}' AND SCHDULE_USER_NAME IS NOT NULL) FACT LEFT OUTER JOIN CMS_CDR.SUBMIT_STATUS_CODE_INFO SSCI ON SSCI.STATUS_CODE = FACT.STATUS_CODE ORDER BY FACT.STATUS_CODE;"
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] Connection String : ${connectionString}. Query String : '${fetchSTATUSCODESQLString}'"
queryAppender1="SUM(CASE WHEN STATUS_CODE ="
queryAppender2="THEN SUBMIT_COUNT ELSE 0 END)"
fetchSTATUSCODEResultSet=$(${connectionString} "${fetchSTATUSCODESQLString}")
length=$(echo ${fetchSTATUSCODEResultSet} | awk -F'|' '{print NF}')
echo "[$(date '+%d-%m-%Y %H:%M:%S')] STAUTS_CODE & DISCRIPTION : "${fetchSTATUSCODEResultSet}
for (( token=5; token<${length}; token++ ))
do
        statusCode=$(echo ${fetchSTATUSCODEResultSet} | awk -F'|' '{print $'${token}'}' | sed 's/ //g')
#	echo $((a+b))
        token=$((${token} + 1))
        statusDispn=$(echo ${fetchSTATUSCODEResultSet} | awk -F'|' '{print $'${token}'}')
        token=$((${token} + 1))
        sqlCASEStatement="${sqlCASEStatement}${queryAppender1} ${statusCode} ${queryAppender2} \"${statusDispn} (${statusCode})\" ,"
done

sqlCASEStatement=${sqlCASEStatement:0:${#sqlCASEStatement}- 1}

echo "[$(date '+%d-%m-%Y %H:%M:%S')] SQL CASE STRING : "${sqlCASEStatement}. LENGTH OF SQL CASE STRING : ${#sqlCASEStatement}.
if ((${#sqlCASEStatement} > 0))
then
        fetchUserBasedSubmitSQLString="SELECT UCASE(SCHDULE_USER_NAME) 'USER NAME', CTD.DESCRIPTION CHANNEL, ${sqlCASEStatement}, SUM(SUBMIT_COUNT) TOTAL FROM CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB, CHANNEL_TYPE_DETAILS CTD WHERE CDR_DATE = '${rptDate}' AND CTD.CHANNEL_TYPE_ID = CHANNEL_ID AND SCHDULE_USER_NAME IS NOT NULL GROUP BY SCHDULE_USER_NAME, CHANNEL_ID ORDER BY SCHDULE_USER_NAME;"
	echo "[$(date '+%d-%m-%Y %H:%M:%S')] SUBMIT_STATUS_USER_WISE_QUERY :: ${fetchUserBasedSubmitSQLString}"
        fetchTotalSubmitSQLString="SELECT 'TOTAL_COUNT', CTD.DESCRIPTION CHANNEL, ${sqlCASEStatement}, SUM(SUBMIT_COUNT) TOTAL FROM CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB, CHANNEL_TYPE_DETAILS CTD WHERE CDR_DATE = '${rptDate}' AND CTD.CHANNEL_TYPE_ID = CHANNEL_ID  AND SCHDULE_USER_NAME IS NOT NULL GROUP BY CHANNEL_ID;"
	echo "[$(date '+%d-%m-%Y %H:%M:%S')] SUBMIT_STATUS_TOTAL_QUERY :: ${fetchUserBasedSubmitSQLString}"
        ${connectionString} "${fetchUserBasedSubmitSQLString}" | grep -v +- > ${rptPath}/TEMP_REPORT 
        if [ -f ${rptPath}/TEMP_REPORT ] && [ -s ${rptPath}/TEMP_REPORT ]
        then
                ${connectionString} "${fetchTotalSubmitSQLString}" | grep -v +- | grep -vw "TOTAL" >> ${rptPath}/TEMP_REPORT
        else
                ${connectionString} "${fetchTotalSubmitSQLString}" | grep -v +- >> ${rptPath}/TEMP_REPORT
        fi
        if [ -f ${rptPath}/TEMP_REPORT ] && [ -s ${rptPath}/TEMP_REPORT ]
        then
                echo "AIRTEL DIGIMATE :: USER-WISE SUBMIT STATUS REPORT - $(date --date=${cdrToken}' days ago' '+%d-%m-%Y')" > ${rptPath}/USERWISE_SUBMIT_STATUS_REPORT_${rptDate}.REPORT
                cat ${rptPath}/TEMP_REPORT >> ${rptPath}/USERWISE_SUBMIT_STATUS_REPORT_${rptDate}.REPORT
		cp ${rptPath}/USERWISE_SUBMIT_STATUS_REPORT_${rptDate}.REPORT ${rptPath}/USER_SUBMIT_STATUS_${repoDate}.txt
                echo "[TO:adarsh.rs@6dtech.co.in]" >> ${rptPath}/USERWISE_SUBMIT_STATUS_REPORT_${rptDate}.REPORT
                mv ${rptPath}/USERWISE_SUBMIT_STATUS_REPORT_${rptDate}.REPORT /home/cmsuser/.ONM_STATUS/
		rm -f ${rptPath}/TEMP_REPORT
        fi
fi

#_____________________________________________________________________#USER_DELIVERY_STATUS_REPORT#_______________________________________________________________#
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] ==============================STARING USER DELIVERY STATUS CODE BASED REPORT GENERATION========================="
fetchDELSTATUSCODESQLString="SELECT DISTINCT(FACT.DEL_STATUS), COALESCE(UCASE(DSC.STATUS_DESC),'UNKNOWN ERROR') FROM (SELECT DISTINCT(DEL_STATUS) FROM CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB WHERE CDR_DATE = '${rptDate}' AND STATUS_CODE = 0 AND SCHDULE_USER_NAME IS NOT NULL AND DEL_STATUS IS NOT NULL) FACT LEFT OUTER JOIN CMS_CDR.DEL_STATUS_INFO DSC ON DSC.STATUS_ID = FACT.DEL_STATUS ORDER BY FACT.DEL_STATUS;"
sqlCASEStatement=""
fetchDELSTATUSCODEResultSet=""
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] Connection String : ${connectionString}. Query String : '${fetchDELSTATUSCODESQLString}'"
queryAppender1="SUM(CASE WHEN DEL_STATUS ="
queryAppender2="THEN DELIVERY_COUNT ELSE 0 END)"
fetchDELSTATUSCODEResultSet=$(${connectionString} "${fetchDELSTATUSCODESQLString}")
length=$(echo $fetchDELSTATUSCODEResultSet | awk -F'|' '{print NF}')
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] STAUTS CODE & DISCRIPTION DETAILS : "$fetchDELSTATUSCODEResultSet
for (( token=5; token<$length; token++ ))
do
        statusCode=$(echo $fetchDELSTATUSCODEResultSet | awk -F'|' '{print $'$token'}' | sed 's/ //g')
        token=$(($token + 1))
        statusDispn=$(echo $fetchDELSTATUSCODEResultSet | awk -F'|' '{print $'$token'}')
        token=$(($token + 1))
        sqlCASEStatement="${sqlCASEStatement}${queryAppender1} '${statusCode}' ${queryAppender2} \"${statusDispn} (${statusCode})\" ,"
done
sqlCASEStatement=${sqlCASEStatement:0:${#sqlCASEStatement}- 1}
echo "[$(date '+%d-%m-%Y %H:%M:%S')] SQL CASE STRING : "$sqlCASEStatement. LENGTH OF SQL CASE STRING : ${#sqlCASEStatement}.

if ((${#sqlCASEStatement} > 0))
then
	fetchUserBasedDeiverySQLString="SELECT UCASE(SCHDULE_USER_NAME) 'USER NAME', CTD.DESCRIPTION CHANNEL, ${sqlCASEStatement}, SUM(DELIVERY_COUNT) TOTAL FROM CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB, CHANNEL_TYPE_DETAILS CTD WHERE CDR_DATE = '${rptDate}' AND STATUS_CODE = 0 AND DEL_STATUS IS NOT NULL AND CTD.CHANNEL_TYPE_ID = CHANNEL_ID AND SCHDULE_USER_NAME IS NOT NULL GROUP BY SCHDULE_USER_NAME ORDER BY SCHDULE_USER_NAME, CHANNEL_ID;"
	echo "[$(date '+%d-%m-%Y %H:%M:%S')] DELIVERY_STATUS_USER_WISE_QUERY :: ${fetchUserBasedDeiverySQLString}"
        fetchTotalDeliverySQLString="SELECT 'TOTAL_COUNT', CTD.DESCRIPTION CHANNEL, ${sqlCASEStatement}, SUM(DELIVERY_COUNT) TOTAL from CMS_CDR.RPT_SUBMIT_DELIVERY_FACT_IB, CHANNEL_TYPE_DETAILS CTD WHERE CDR_DATE = '${rptDate}' AND STATUS_CODE = 0 AND DEL_STATUS IS NOT NULL AND CTD.CHANNEL_TYPE_ID = CHANNEL_ID AND SCHDULE_USER_NAME IS NOT NULL GROUP BY CHANNEL_ID;"
	echo "[$(date '+%d-%m-%Y %H:%M:%S')] DELIVERY_STATUS_TOTAL_QUERY :: ${fetchTotalDeliverySQLString}"
	${connectionString} "${fetchUserBasedDeiverySQLString}" | grep -v +- > ${rptPath}/TEMP_REPORT 
        if [ -f ${rptPath}/TEMP_REPORT ] && [ -s ${rptPath}/TEMP_REPORT ]
        then
                ${connectionString} "${fetchTotalDeliverySQLString}" | grep -v +- | grep -vw "TOTAL" >> ${rptPath}/TEMP_REPORT
        else
                ${connectionString} "${fetchTotalDeliverySQLString}" | grep -v +- >> ${rptPath}/TEMP_REPORT
        fi
        if [ -f ${rptPath}/TEMP_REPORT ] && [ -s ${rptPath}/TEMP_REPORT ]
        then
                echo "AIRTEL DIGIMATE :: USER-WISE DELIVERY STATUS REPORT - $(date --date=${cdrToken}' days ago' '+%d-%m-%Y')" > ${rptPath}/USERWISE_DELIVERY_STATUS_REPORT_${rptDate}.REPORT
                cat ${rptPath}/TEMP_REPORT >> ${rptPath}/USERWISE_DELIVERY_STATUS_REPORT_${rptDate}.REPORT
		cp ${rptPath}/USERWISE_DELIVERY_STATUS_REPORT_${rptDate}.REPORT ${rptPath}/USER_DELIVERY_STATUS_${repoDate}.txt
                echo "[TO:adarsh.rs@6dtech.co.in]" >> ${rptPath}/USERWISE_DELIVERY_STATUS_REPORT_${rptDate}.REPORT
                mv ${rptPath}/USERWISE_DELIVERY_STATUS_REPORT_${rptDate}.REPORT /home/cmsuser/.ONM_STATUS/
                rm -f ${rptPath}/TEMP_REPORT
        fi
fi

rm -f /home/cmsuser/Scripts/.DIGIMATE_USER_SUBMIT_DELIVERY_STATITICS_OFFLINE.PROCESS
