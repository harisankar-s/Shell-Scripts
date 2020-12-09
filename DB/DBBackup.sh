#!/bin/bash

. $(find ~/ -maxdepth 1 -mindepth 1 -type f -name '.bash_profile')
date=$(date --date='now' '+%d%m%y')

cd /backup/DBBACKUP
echo _________________________BKP_CMS_DB_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz__________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 --lock-tables=false --no-data CMS | gzip -9 > BKP_DB_CMS_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMS_DB_ROUTINES_$(date '+%d%m%Y_%H').sql.gz___________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 --lock-tables=false --routines --no-create-info --no-data --no-create-db --skip-opt CMS | gzip -9 > BKP_DB_CMS_ROUTINES_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMS_DB_APP_$(date '+%d%m%Y_%H').sql.gz________________________________________________
mysql -uroot -proot CMS -h127.0.0.1 -P3306 -Ae 'SHOW TABLES;' | grep -v Tables_in_ | grep -v DEL_CDR_ | grep -v DBAUDIT_INFO | grep -v BKP_SUB_CDR_ | grep -v SUB_CDR_ | grep -v EVENT_PROCESSOR_CDR | grep -v _TMD_ | grep -v BANDWIDTH_LOGS | grep -v AUDIT_LOGS | grep -v ALARM_DETAILS | grep -v AUDIT_QUOTA | grep -v Apps_History_Status |grep -v CAMPAIGN_PROCESSOR_AUDIT | grep -v AUDIT_INFO | grep -v QUOTA_MANAGER_AUDIT | grep -v VMN_ | grep -v BKPOLDKP_ | xargs mysqldump --force -uroot -proot -v --lock-tables=FALSE --routines CMS -h127.0.0.1 -P3306 | gzip -9 > BKP_DB_CMS_APP_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMS_DB_VMN_$(date '+%d%m%Y_%H').sql.gz________________________________________________
mysql -uroot -proot CMS -h127.0.0.1 -P3306 -Ae 'SHOW TABLES;' | grep -v Tables_in_ | grep VMN_ | xargs mysqldump --force -uroot -proot -v --lock-tables=FALSE CMS -h127.0.0.1 -P3306 | gzip -9 > BKP_DB_CMS_VMN_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMSCDR_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz_______________________________________
mysqldump --force -uroot -proot -h127.0.0.1 --lock-tables=false --no-data CMS_CDR | gzip -9 > BKP_DB_CMSCDR_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMSCDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 --lock-tables=false --routines --no-create-info --no-data --no-create-db --skip-opt CMS_CDR | gzip -9 > BKP_DB_CMSCDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMS_SF_VM_$(date '+%d%m%Y_%H').sql.gz__________________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3306 CMS_SF_VM --routines --lock-tables=false | gzip -9 > BKP_DB_CMS_SF_VM_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_CMS_SF_$(date '+%d%m%Y_%H').sql.gz__________________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3306 CMS_SF --routines --lock-tables=false | gzip -9 > BKP_DB_CMS_SF_$(date '+%d%m%Y_%H').sql.gz

#mysql -uroot -proot CMS_CDR -h127.0.0.1 -P3306 -Ae 'SHOW TABLES;' | grep -v Tables_in_ | grep -v SUB_CDR_ | grep -v DEL_CDR_ | grep -v SHADOW_ | grep -v ONM_ | xargs mysqldump --force -uroot -proot -v --lock-tables=FALSE --routines CMS_CDR -h127.0.0.1 -P3306 | gzip -9 > BKP_CMS_CDR_REPORTING_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_MORTR_$(date '+%d%m%Y_%H').sql.gz__________________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3307 MO_ROUTER --routines --lock-tables=false | gzip -9 > BKP_DB_MORTR_$(date '+%d%m%Y_%H').sql.gz
echo _________________________BKP_USSDV3_$(date '+%d%m%Y_%H').sql.gz_________________________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3308 USSDV3 --routines --lock-tables=false | gzip -9 > BKP_DB_USSDV3_$(date '+%d%m%Y_%H').sql.gz
echo _________________________BKP_USSDV3CDR_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz____________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3308 USSDV3_CDR --no-data --lock-tables=false | gzip -9 > BKP_DB_USSDV3CDR_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz
echo _________________________BKP_USSDV3CDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz______________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3308 USSDV3_CDR --routines --lock-tables=false  --no-create-info --no-data --no-create-db --skip-opt | gzip -9 > BKP_DB_USSDV3CDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz
echo _________________________BKP_DLVR_CDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz______________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3309 DLVR_CDR --no-data --lock-tables=false | gzip -9 > BKP_DB_DLVR_CDR_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz
echo _________________________BKP_DLVR_CDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz______________________________________
mysqldump --force -uroot -proot -h127.0.0.1 -P3309 CMS_SF_TMD1 CMS_SF_TMD2 CMS_SF_TMD3 CMS_SF_TMD4 CMS_SF_TMD1 CMS_SF_TMD2 CMS_SF_TMD3 CMS_SF_TMD4 --no-data --lock-tables=false | gzip -9 > BKP_DB_CMS_SF_TMD_STRUCTURE_$(date '+%d%m%Y_%H').sql.gz

echo _________________________BKP_RPT_CMS_CDR_ROUTINES_$(date '+%d%m%Y_%H').sql.gz______________________________________
mysqldump -ucmsuser -pcmsuser -P5029 -h10.3.60.16 CMS_CDR --routines --no-create-info --no-data --lock-tables=FALSE | gzip -9 > BKP_DB_RPTDB_SRVR_01_ROUTINES_$(date '+%d%m%y').sql.gz

echo _________________________BKP_AIRTEL_CMS_$(date '+%d%m%Y').tgz_____________________________________________________
ls -ltrh BKP_DB_*.sql.gz
tar -cvzf BKP_AIRTEL_$(/bin/hostname)_$(date '+%d%m%Y').tgz BKP_DB_*.sql.gz
rm -f BKP_DB_*.sql.gz
find /backup/DBBACKUP -maxdepth 1 -type f -name 'BKP_*.tgz' -mtime +7 -exec rm -f {} \;
find  /backup/DBBACKUP -maxdepth 1 -mindepth 1 -type f -name '*.sql.gz' -mtime +7 -exec rm -f {} \;
echo "[ $(date '+%d-%m-%Y %H:%M:%S') ] STARTING RA-REPORT FTP TRANSFER [ SFTP :: 10.3.60.14 :: cmsuser :: /data01/DBBACKUP ::  BKP_AIRTEL_$(/bin/hostname)_$(date '+%d%m%Y').tgz ]"
#/usr/local/6d/fileTransfer <Upload(1)/Download(2)> <ipAddress> <port> <userName> <passwd> <destPath> <transferFileName>
/usr/local/6d/fileTransfer 1 10.3.60.14 22 cmsuser RCFnITY0Q1VzNXI= /data01/DBBACKUP /backup/DBBACKUP/BKP_AIRTEL_$(/bin/hostname)_$(date '+%d%m%Y').tgz
