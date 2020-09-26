#!/bin/sh

LogDate=$(date +%Y-%m-%d --date "yesterday")
LogFileDate=$(date +%Y%m%d --date "yesterday")
LogDelete=15
TgzDelete=45
DBName='xxx yyy'
MongoDBName='PARTNER'

for DBList in $DBName
do
	cd ~/bin/
	mysqldump -uroot -p123qwe $DBList --single-transaction --quick --routines > ~/bin/$LogFileDate-$DBList.sql

done

for MongoDBList in $MongoDBName
do
        cd ~/bin/
	mongodump -h 127.0.0.1 -d PARTNER -o ./

done


tar zcvf ~/bin/$LogFileDate-MySQL.tgz ~/bin/$LogFileDate-*.sql
tar zcvf ~/bin/$LogFileDate-MongoDB.tgz ~/bin/$MongoDBName

cd ~/bin/;./mongo_remove.sh

#sleep 2

#rm -rf ~/bin/$LogFileDate-*.tgz
rm -rf ~/bin/$LogFileDate-*.sql 
rm -rf ~/bin/$MongoDBName

find ~/bin/ -type f -ntime +5 -name "*.tgz" | xargs rm -f
