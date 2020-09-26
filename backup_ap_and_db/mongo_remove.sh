#!/bin/sh

DayNumber=90


MySQLDelete(){
        mysql='mysql -uroot -p123qwe'
        TODAY=$(date +%Y-%m-%d --date "yesterday")
        DAYAGO=$(date +%Y-%m-%d --date "$DayNumber days ago")
        $mysql << End
                delete from yes.123456 where CreateDate < '$DAYAGO';
		alter table yes.123456 engine=innodb;

End
}

MySQLSelectForMongoDB(){
        mysql='mysql -uroot -p123qwe'
        TODAY=$(date +%Y-%m-%d --date "yesterday")
        DAYAGO=$(date +%Y-%m-%d --date "$DayNumber days ago")
        $mysql << End
                select UID, TableSerial from yes.123456 where CreateDate < '$DAYAGO';

End
}

cd ~/bin/;

MySQLSelectForMongoDB > MongoDBList.txt
	sed -i '1d' MongoDBList.txt
	sed -i 's/-/	/g' MongoDBList.txt
	#awk -F '-' '{print $1}' MongoDBList.txt | uniq > MongoDBList_tmp.txt

rm -rf mongodb_result mongodb_txt
mkdir -p mongodb_result mongodb_txt

while read line
do
	UID=$(echo $line | awk '{print $1}')
	TableSerial=$(echo $line | awk '{print $2}')
	Round=$(echo $line | awk '{print $3}')
		#echo "cursor = db.USER_$UID.find({\"TableSerial\" : \"$TableSerial\",\"Round\" : \"$Round\"})" >> ./mongodb_result/USER_$UID-find-$TableSerial-$Round\.js
		echo "cursor = db.USER_$UID.remove({\"TableSerial\" : \"$TableSerial\",\"Round\" : $Round })" >> ./mongodb_result/USER_$UID-remove-$TableSerial-$Round\.js
		echo "if ( cursor.hasNext() ){" >>./mongodb_result/USER_$UID-remove-$TableSerial-$Round\.js
		echo "	cursor.next();" >>./mongodb_result/USER_$UID-remove-$TableSerial-$Round\.js
		echo "}" >>./mongodb_result/USER_$UID-remove-$TableSerial-$Round\.js
	
	mongo PARTNER < ./mongodb_result/USER_$UID-remove-$TableSerial-$Round\.js > ./mongodb_txt/USER_$UID-remove_result-$TableSerial-$Round\.txt
done < MongoDBList.txt

MySQLDelete
