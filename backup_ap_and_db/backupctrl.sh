#!/bin/sh

LogDate=$(date +%Y-%m-%d --date "yesterday")
CNLogFileDate=$(date +%Y%m%d --date "yesterday")
LogFileDate=$(date +%Y%m%d --date "2 days ago")
LogDelete=15
TgzDelete=100


#tgzlogfunc(){

#	for DirList in $(find $1 -type d -name "logs" -o -name "ace_logs")
#	do
#  		cd $DirList
#  		find ./ -type f -name "*$LogDate*.log" | xargs tar zcf $LogFileDate.tgz

		#find $DirList -name "*.log" -mtime +$LogDelete | xargs rm
		#find $DirList -name "*.tgz" -mtime +$TgzDelete | xargs rm

#	done

#}


ssh 10.170.0.3 '~/bin/tgz-logs.sh'
ssh 47.75.90.179 '~/bin/tgz-logs.sh'
ssh 10.170.0.4 '~/bin/tgz-ace_logs.sh'
ssh 10.170.0.2 '~/bin/DBbackup.sh'
#ssh 10.170.0.2 '~/bin/mongo_remove.sh'

sleep 10

scp -rp 10.170.0.3:~/apii/logs/$LogFileDate.tgz /home/williamchen/backup/LOG/API/apii/apii-$LogFileDate.tgz
scp -rp 10.170.0.3:~/apie/logs/$LogFileDate.tgz /home/williamchen/backup/LOG/API/apie/apie-$LogFileDate.tgz
scp -rp 10.170.0.4:/home/williamchen/master/servers/game/ace_logs/$LogFileDate.tgz /home/williamchen/backup/LOG/game/ace_logs/ace_logs-$LogFileDate.tgz
scp -rp 10.170.0.2:/root/bin/$LogFileDate\-MySQL.tgz /home/williamchen/backup/database/MySQL/
scp -rp 10.170.0.2:/root/bin/$LogFileDate\-MongoDB.tgz /home/williamchen/backup/database/MongoDB/
scp -rp 47.75.90.179:~/apiecn/logs/$CNLogFileDate.tgz /home/williamchen/backup/LOG/API/apiecn/apiecn-$CNLogFileDate.tgz

find /home/williamchen/backup -mtime +$TgzDelete -type f -name "*.tgz" | xargs rm -f 
chown -R williamchen:williamchen /home/williamchen/backup
