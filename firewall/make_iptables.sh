#!/bin/sh

API_IP="10.170.0.3 47.75.90.179"
backuptime=$(date +%Y%m%d%H%M%S)
workdir=/root/bin/firewall
rulebackupdir=$workdir/rule_backup/$backuptime

cd /usr/local/libexec/xtables-addons;
./xt_geoip_dl*
cd ./GeoLite2-Country-CSV_*/
grep '1668284,1668284' GeoLite2-Country-Blocks-IPv4.csv | cut -d ',' -f1 > $workdir/TWiplist.txt

mkdir -p $rulebackupdir
cd ~/bin/firewall/; mv *.rules $rulebackupdir

for white_iplist in $(cat ~/bin/firewall/whiteiplist.txt)
do
        # admin test
        echo "iptables -I INPUT -i ens4 -s $white_iplist -p tcp --dport 22 -j ACCEPT" >> $workdir/iptables.rules
        echo "iptables -D INPUT -i ens4 -s $white_iplist -p tcp --dport 22 -j ACCEPT" >> $workdir/iptables_delete.rules
        # CQ9-API
        echo "iptables -I INPUT -i eth0 -s $white_iplist -p tcp --dport 15488 -j ACCEPT" >> $workdir/iptables-cq9api.rules
        echo "iptables -D INPUT -i eth0 -s $white_iplist -p tcp --dport 15488 -j ACCEPT" >> $workdir/iptables-cq9api_delete.rules
        # APIECN
        echo "iptables -I INPUT -i eth0 -s $white_iplist -p tcp --dport 25488 -j ACCEPT" >> $workdir/iptables-apiecn.rules
        echo "iptables -D INPUT -i eth0 -s $white_iplist -p tcp --dport 25488 -j ACCEPT" >> $workdir/iptables-apiecn_delete.rules

done


for TWIPLIST in $(cat ~/bin/firewall/TWiplist.txt)
do
	#admin test
        echo "iptables -A INPUT -i ens4 -s $TWIPLIST -p tcp --dport 22 -j DROP" >> $workdir/iptables.rules
        echo "iptables -D INPUT -i ens4 -s $TWIPLIST -p tcp --dport 22 -j DROP" >> $workdir/iptables_delete.rules
	# CQ9-API
        echo "iptables -A INPUT -i eth0 -s $TWIPLIST -p tcp --dport 15488 -j DROP" >> $workdir/iptables-cq9api.rules
        echo "iptables -D INPUT -i eth0 -s $TWIPLIST -p tcp --dport 15488 -j DROP" >> $workdir/iptables-cq9api_delete.rules
        # APIECN
        echo "iptables -A INPUT -i eth0 -s $TWIPLIST -p tcp --dport 25488 -j DROP" >> $workdir/iptables-apiecn.rules
        echo "iptables -D INPUT -i eth0 -s $TWIPLIST -p tcp --dport 25488 -j DROP" >> $workdir/iptables-apiecn_delete.rules

done

chmod 755 *.rules

ssh 10.170.0.3 "cd ~/bin; mv iptables-cq9api.rules iptables-cq9api.rules.old; mv iptables-cq9api_delete.rules iptables-cq9api_delete.rules.old"
ssh 47.75.90.179 "cd ~/bin; mv iptables-apiecn.rules iptables-apiecn.rules.old; mv iptables-apiecn_delete.rules iptables-apiecn_delete.rules.old"

scp -rp *-cq9api*.* 10.170.0.3:~/bin/
scp -rp *-apiecn*.* 47.75.90.179:~/bin/

#ssh 10.170.0.3 "cd ~/bin;./iptables-cq9api_delete.rules.old;./iptables-cq9api.rules"
#ssh 47.75.90.179 "~/bin;./iptables-apiecn_delete.rules.old;./iptables-apiecn.rules"
