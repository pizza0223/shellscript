#!/bin/sh

#checkdate=$(date '+%Y-%m-%d')

findip () {
mongo <<EndMongo
use monitordb;
db.ip_dn_checklist.findOne({'DN' : '$1'},{'_id':0, 'DN':0})
EndMongo
}


for dnlist in $(cat dnlist.txt)
   do
   ipresult=$(findip $dnlist | grep "ip" | cut -d " " -f4 | sed 's/\"//g')
   nslookup=$(nslookup $dnlist | grep "Address" | grep -v "\#" | cut -d " " -f2) 
   
   if [ "$(echo $ipresult)" = "$(echo $nslookup)" ];
   then 
      echo "$ipresult is as same as the db record."
      status="OK"

   else
      echo "$ipresult has some problems, please check it immediately."
      status="Failed"
   fi

mongo <<EndMongo
   use monitordb;
   db.chk_record.insert({'RecordDate' : Date(), 'IP' : '$ipresult', 'DomainName' : '$dnlist', 'status' : '$status' })
EndMongo

done

