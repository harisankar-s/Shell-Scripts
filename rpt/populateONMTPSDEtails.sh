#!/bin/bash

if [ ! -f /home/cmsuser/Scripts/ONM/.PopulateONMTPSDetails.LOCK ]
then
        touch /home/cmsuser/Scripts/ONM/.PopulateONMTPSDetails.LOCK
	echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______________________STARTING call Populate_ONMTPSDetails()_______________________"
	mysql-ib -ucmsuser -pcmsuser -P5029 -h127.0.0.1 CMS_CDR -Ae "call Populate_ONMTPSDetails();"
	#mysql-ib -ucmsuser -pcmsuser -P5029 -h127.0.0.1 CMS_CDR -Ae "truncate table CMS_CDR.ONM_DIGIMATE_TPS_DETAILS; call Populate_TPSDetails();"
	echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] _______________________ENDING call Populate_ONMTPSDetails()_________________________"
	rm -f /home/cmsuser/Scripts/ONM/.PopulateONMTPSDetails.LOCK
else
	ls -ltrh /home/cmsuser/Scripts/ONM/.PopulateONMTPSDetails.LOCK
fi
