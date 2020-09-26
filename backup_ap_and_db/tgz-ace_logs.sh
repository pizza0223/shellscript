#!/bin/sh

LogDate=$(date +%Y-%m-%d --date "yesterday")
LogFileDate=$(date +%Y%m%d --date "yesterday")
LogDelete=15
TgzDelete=45

for DirList in $(find /home/williamchen/ -type d -name "ace_logs")

do
  cd $DirList
  find ./ -type f -name "*$LogDate*.log" | xargs tar zcf $LogFileDate.tgz

find $DirList -name "*.log*" -mtime +$LogDelete | xargs rm
find $DirList -name "*.tgz" -mtime +$TgzDelete | xargs rm

done

