#!/bin/bash

find /home/cmsuser/Scripts/ -maxdepth 1 -name '.DIGIMATE_ONMDATAPOPULATION_SUBMITDELIVERYSTATITICS_ONLINE' -mmin +60 -exec rm -f {} \;
if [ -f /home/cmsuser/Scripts/.DIGIMATE_ONMDATAPOPULATION_SUBMITDELIVERYSTATITICS_ONLINE ]
then
	ls -ltrh /home/cmsuser/Scripts/.DIGIMATE_ONMDATAPOPULATION_SUBMITDELIVERYSTATITICS_ONLINE
	exit 0
fi

touch /home/cmsuser/Scripts/.DIGIMATE_ONMDATAPOPULATION_SUBMITDELIVERYSTATITICS_ONLINE

echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______/home/cmsuser/Scripts/ONM/manualONMTableDataPopulation.sh______________________"
sh /home/cmsuser/Scripts/ONM/manualONMTableDataPopulation.sh
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______/home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryCountMonitorONLINE.sh_________"
sh /home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryCountMonitorONLINE.sh
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______/home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryStatiticsONLINE.sh_________"
sh /home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryStatiticsONLINE.sh
#echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______/home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryStatitics_Graph.sh_________"
#sh /home/cmsuser/Scripts/ONM/digimateUserSubmitDeliveryStatitics_Graph.sh
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] ___________________COMPLETED__________________________________________________________"
#sh /home/cmsuser/Scripts/Traffic_Alert_SMS.sh

rm -f /home/cmsuser/Scripts/.DIGIMATE_ONMDATAPOPULATION_SUBMITDELIVERYSTATITICS_ONLINE
