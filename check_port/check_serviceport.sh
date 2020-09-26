#!/bin/bash

### 寄發檢查結果 ###
MAILFILE="checklist_`date +%m%d%H%M`.log"
EMAIL="pizza0223@gmail.com"
SUBJECT="[123456]ServicePortCheckingHasSomeAlert"
MAILSRVIP="127.0.0.1"

function mail2op() {
cat ./checkresults/$MAILFILE > /tmp/$MAILFILE
mail $EMAIL -s \"$SUBJECT\" < /tmp/$MAILFILE
#MailHeader='Content-Type: text/html; charset=big5'
#ssh $MAILSRVIP "mail $EMAIL -s \"$SUBJECT\" < /tmp/$MAILFILE"
rm -f /tmp/$MAILFILE
}

FILENAME="aplist.txt"

function Try_Connect() {
   ap_name=$1
   ap_ip=$2
   ap_port=$3
   commacount=$(echo $3 | sed 's/[^,]//g' | awk '{print length}')
   portcount=$(echo $commacount + 1 | bc)
   for (( i=1; i<=$portcount; i++ ))
   do
       ap_port_now=$(echo $3 | cut -d ',' -f$i)
       result=$(nc -v -w 1 $ap_ip -z $ap_port_now 2>&1)
       if [ $(echo $result|grep "succeeded"|wc -l) == 1 ]; then
          echo -e "$ap_name\t$ap_ip\t$ap_port_now\tconnection succeeded." >> ./checkresults/ok_service_list_`date +%m%d%H%M`.log
#       elif [ $(echo $result|egrep "refused|timed out"|wc -l) == 1 ]; then
       elif [ $(echo $result|egrep "refused"|wc -l) == 1 ]; then
          echo -e "$ap_name\t$ap_ip\t$ap_port_now\tconnection failed..." >> ./checkresults/dead_service_list_`date +%m%d%H%M`.log
       else
          echo -e "$ap_name\t$ap_ip\t$ap_port_now\tconnection data error!" >> ./checkresults/dataerror_service_list_`date +%m%d%H%M`.log
       fi
   done
}

while read line
do
   if [ "$(echo $line | egrep -v '^#|^$')" ]; then
        ap_name=$(echo $line | cut -d' ' -f1)
        ap_ip=$(echo $line | cut -d' ' -f2)
        ap_port=$(echo $line | cut -d' ' -f3)
        if [ "$ap_name" == "" -o "$ap_ip" == "" -o "$ap_port" == "" ];then
           echo "name or ip or port is null -> $line"
        else
           Try_Connect $ap_name $ap_ip $ap_port
        fi
   else
        echo "pass this line -> $line" 
   fi
done < $FILENAME

if [ -e ./checkresults/dead_service_list_`date +%m%d%H%M`.log ]; then
   #echo "file exist"
   echo "目前有問題的服務：" >> ./checkresults/checklist_`date +%m%d%H%M`.log
   cat ./checkresults/dead_service_list_`date +%m%d%H%M`.log >> ./checkresults/checklist_`date +%m%d%H%M`.log
   cat ./checkresults/dataerror_service_list_`date +%m%d%H%M`.log >> ./checkresults/checklist_`date +%m%d%H%M`.log
   #SUBJECT="[檢查信][Live]目前 Billing Port 的開啟狀態[有問題]"
   SUBJECT="[CQ9]ServicePortCheckingHasSomeAlert"
   mail2op
else
   #echo "without a file!!!"
   echo "無狀況發生。" >> ./checkresults/checklist_`date +%m%d%H%M`.log
   SUBJECT="[CQ9]ServicePortCheckingHasNoAlert"
   #mail2op
fi

ls -l ./checkresults/checklist_`date +%m%d%H%M`.log

find ./checkresults/ -mtime +7 -type f -iname "*.log" | xargs rm -f 

