#!/bin/bash


getResourceUsgaeDetails() {
	appPID="${1}"
	moduleName="${2}"
	mkdir -p /home/cmsuser/Scripts/.RESOURCE_USAGE_INFO/
	resourceUsageInfoFile=/home/cmsuser/Scripts/.RESOURCE_USAGE_INFO/Resource_Usage_Info_$(date '+%y%m%d_%H').TXT
	if [ ! -f ${resourceUsageInfoFile} ]
	then
		processRunningDetals=$(ps aux | grep "PID" | grep "%MEM" | grep -v grep | awk '{for(i=1;i<=10;i++) printf $i"|"}')
		echo "TIME_STAMP|MODULE|${processRunningDetals}" > ${resourceUsageInfoFile}
	fi
	echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] appPID = ${appPID} moduleName = ${moduleName}"
	processRunningDetals=$(ps aux | grep "${appPID}" | grep -v grep | awk '{for(i=1;i<=10;i++) printf $i"|"}')
	echo "$(date '+%d-%m-%Y %H:%M:%S')|${moduleName}|${processRunningDetals}" >> ${resourceUsageInfoFile}
}

mysqlPID=$(ps -Aef | grep mysqld | grep 5029 | grep -v grep | awk '{print $2}')
getResourceUsgaeDetails ${mysqlPID} mysql_5029
javaPID=$(ps -Aef | grep java | grep CMS_REPORTING/Pentaho6/biserver-ce | grep -v grep | awk '{print $2}')
getResourceUsgaeDetails ${javaPID} Pentaho6/biserver-ce
