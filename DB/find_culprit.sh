#!/bin/bash
echo Finding at `date`
mysql -uroot -proot -h127.0.0.1 -P3306 CMS -Ae " select * from TASK_TABLE_MAPPING where STATUS='0' and date(UPDATED_TIME)=curdate() ;"
echo Completing at `date`
