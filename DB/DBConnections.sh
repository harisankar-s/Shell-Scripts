#!/bin/bash

echo " "
echo " "

now=$(date +"%d-%m-%Y-%H:%M:%S") 
date=`date +%d_%m_%Y`


totConnections1=$(netstat -antp | grep 3306 | grep -v grep | grep 10.3.60.19|wc -l)
totTimeWait1=$(netstat -antp|grep 3306|grep TIME_WAIT|grep -v grep | grep 10.3.60.19|wc -l)
totEstab1=$(netstat -antp|grep 3306|grep ESTABLISHED |grep -v grep | grep 10.3.60.19|wc -l)
totConnections2=$(netstat -antp | grep 3306 | grep -v grep | grep 10.3.60.20|wc -l)
totTimeWait2=$(netstat -antp|grep 3306|grep TIME_WAIT|grep -v grep | grep 10.3.60.20|wc -l)
totEstab2=$(netstat -antp|grep 3306|grep ESTABLISHED |grep -v grep | grep 10.3.60.20|wc -l)
TotalConnections=$(netstat -antp|grep 3306|grep -v grep |wc -l)

if [ ! -f /data/MysqlConnections/DBConnections_$date.txt ]
then
	printf '%-10s,%-3s,%-3s,%-3s,%-3s,%-3s,%-3s,%-3s' TimeStamp Total_DB_Connections Total_Connections_from_CAMP1 TIME_WAIT_from_CAMP1 ESTABLISHED_from_CAMP1 Total_Connections_from_CAMP2 TIME_WAIT_from_CAMP2 ESTABLISHED_from_CAMP2 > /data/MysqlConnections/DBConnections_$date.txt
fi
#echo -e  "TimeStamp\tTotal_DB_Connections\tTotal_Connections_from_CAMP1\tTIME_WAIT_from_CAMP1\tESTABLISHED_from_CAMP1\tTotal_Connections_from_CAMP2\tTIME_WAIT_from_CAMP2\tESTABLISHED_from_CAMP2" >> /data/MysqlConnections/Connections_$date.txt

#echo -e ${now}"\t"${TotalConnections}"\t"${totConnections1}"\t"${totTimeWait1}"\t"${totEstab1}"\t"${totConnections2}"\t"${totTimeWait2}"\t"${totEstab2} >> /data/MysqlConnections/Connections_$date.txt

printf '%-10s,%-3s,%-3s,%-3s,%-3s,%-3s,%-3s,%-3s\n' ${now} ${TotalConnections} ${totConnections1} ${totTimeWait1} ${totEstab1} ${totConnections2} ${totTimeWait2} ${totEstab2} >> /data/MysqlConnections/DBConnections_$date.txt

##echo -e ${now}","${TotalConnections}","${totConnections1}","${totTimeWait1}","${totEstab1}","${totConnections2}","${totTimeWait2}","${totEstab2} >>Connections.csv

