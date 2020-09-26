#!/bin/sh

checkdate=$(date +%Y%m%d%H%M)
host="1.2.3.4"
#Receiver="pizza0223@gmail.com"

### generating keyfile ###

for keyfilelist in $(find /home/williamchen/ -type f | sort)
   do 
      md5sum "$keyfilelist" | cut -c1-34,79- | sed -e 's/\/home\/williamchen\///g' >> /home/williamchen/md5check/keyfile/patchkey_$checkdate.txt

   done

### generate and copy md5sum file from other host ###

md5check () {

ssh $1 << END
for patchlist in \$(find /www/download/ -type f | sort)
   do 
      md5sum "\$patchlist" | cut -c1-34,59- | sed -e 's/\/www\/download\///g' >> /tmp/$1_patch_$checkdate.txt

   done

END

scp -rp $1:/tmp/$1_patch_$checkdate.txt /home/williamchen/md5check/keyfile/

ssh $1 << END
rm /tmp/$1_patch_$checkdate.txt
END
}

md5check $host

### start to check difference ### 

mail2op () {
mail $Receiver -s "$Subject" < /home/williamchen/md5check/keyfile/checkresults_$checkdate.log
}

cd /home/williamchen/md5check/keyfile/;

difference=$(diff patchkey_$checkdate.txt $host\_patch_$checkdate.txt)
   if [ "$difference" != "" ]; then
   echo "HOSTNAME:$host" > "checkresults_$checkdate.log"
   diff patchkey_$checkdate.txt $host\_patch_$checkdate.txt >> "checkresults_$checkdate.log"
   Subject="[PG-Admin][Live] MD5 CheckResults (Error)"
   mail2op
   else
   echo "check OK!" > "checkresults_$checkdate.log"
   Subject="[PG-Admin][Live] MD5 CheckResults"
   #mail2op
   fi

#rm ./*.txt
