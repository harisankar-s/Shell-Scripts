#!/bin/bash

if [ -f /home/cmsuser/Scripts/.REPLICATIONDELAY_CHECK ]
then
	exit 0
fi

touch /home/cmsuser/Scripts/.REPLICATIONDELAY_CHECK
dbChekStatus=$(mysql -uroot -proot -h127.0.0.1 -P3306 CMS -Ae "SHOW SLAVE STATUS\G;" | egrep "Seconds_Behind_Master:|Slave_IO_Running:|Slave_SQL_Running:")
Seconds_Behind_Master=$(echo "${dbChekStatus}" | grep Seconds_Behind_Master | awk -F':' '{print $2}' | sed 's/ //g')
Slave_IO_Running=$(echo "${dbChekStatus}" | grep Slave_IO_Running | awk -F':' '{print $2}' | sed 's/ //g')
Slave_SQL_Running=$(echo "${dbChekStatus}" | grep Slave_SQL_Running | awk -F':' '{print $2}' | sed 's/ //g')
regex='^[0-9]+$'
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] Slave_IO_Running :: ${Slave_IO_Running} Slave_SQL_Running :: ${Slave_SQL_Running} Seconds_Behind_Master :: ${Seconds_Behind_Master}"
if [[ ${Slave_IO_Running} ==  Yes ]] && [[ ${Slave_SQL_Running} == Yes ]] && [[ ${Seconds_Behind_Master} =~ ${regex} ]]
then
	if ((${Seconds_Behind_Master} > 120))
	then
		find /home/cmsuser/Scripts/ -maxdepth 1 -mindepth 1 -type f -name '.REPLICATIONDELAY_ALERT' -mmin +15 rm -f {} \;
		if [ ! -f /home/cmsuser/Scripts/.REPLICATIONDELAY_ALERT ]
		then
			touch /home/cmsuser/Scripts/.REPLICATIONDELAY_ALERT
			echo "Replication Delay on $(/bin/hostname) with Seconds_Behind_Master :: ${Seconds_Behind_Master}." > /home/cmsuser/Scripts/.REPLICATIONDELAY
			echo "AIRTEL DIGIMATE :: Replication Delay on $(/bin/hostname)" > /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.GENERIC
			echo "Seconds_Behind_Master :: ${Seconds_Behind_Master} Seconds." >> /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.GENERIC
			echo >> /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.GENERIC
			mysql -uroot -proot -h127.0.0.1 -P3306 CMS -Ae "SHOW SLAVE STATUS\G;" >> /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.GENERIC
	        	echo "[TO:adarsh.rs@6dtech.co.in]" >> /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.GENERIC
		else
			echo ":::: CACHING THE ALERTS :::: Seconds_Behind_Master :: ${Seconds_Behind_Master} Seconds."
		fi
	else
		if [ -f /home/cmsuser/Scripts/.REPLICATIONDELAY ]
		then
			rm -f /home/cmsuser/Scripts/.REPLICATIONDELAY
			echo "AIRTEL DIGIMATE :: Replication Delay Recovered on $(/bin/hostname)" > /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.MESSAGE
			echo "REcovered Replication delay observed on $(/bin/hostname), now Seconds_Behind_Master :: ${Seconds_Behind_Master} Seconds." >> /home/cmsuser/.ONM_STATUS/REPLICATION_SLAVE_BEHIND_3306.MESSAGE
		fi
	fi
fi
rm -f /home/cmsuser/Scripts/.REPLICATIONDELAY_CHECK
