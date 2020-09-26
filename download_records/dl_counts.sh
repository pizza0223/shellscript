#!/bin/sh

logdate=$(date '+%Y%m%d' -d '-1 day')
checkdate=$(date '+%Y-%m-%d' -d '-1 day')
dl_server="1.2.3.4"
dl_path=/home/williamchen/
dl_name="Union"


### 1. �N Download Server �W Apache access_log �P�B�^�� ###
scp -rp $dl_server:/usr/local/apache2/logs/access_log_$logdate $dl_path/logfiles/

### 2. �M���ɮפ��O�U�� Union �}�Y�B���A�� 200 �����e ###

cd $dl_path/logfiles/

dl_times=$(awk '($7 ~ /'$dl_name'/) && ($9 == 200) {gsub("/","",$7); gsub("^\[","",$4); print $1, $4, $7}' access_log_$logdate | wc -l)

dl_ip_times=$(awk '($7 ~ /'$dl_name'/) && ($9 == 200) {gsub("/","",$7); gsub("^\[","",$4); print $1, $4, $7}' access_log_$logdate | cut -d " " -f1 | sort | uniq -c | sort -n | wc -l)


### 3. ��ƭȶ�J��Ʈw ###

/usr/bin/mysql -u'root' -p'aa1234aa1234..' <<EndMySQL
use adminDB;

insert into download_records(recorddate, download_times, download_ip_times) values('$checkdate', $dl_times, $dl_ip_times);

EndMySQL

