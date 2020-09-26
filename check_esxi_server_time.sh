#!/bin/bash

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
work_dir="/usr/lib64/nagios/plugins"
tmp_dir=${work_dir}/tmp

esxi_server_arr=(esx02 esx03 esx06 esx07 esx08 esx09)
ntp_server='gm12.gomaji.com'
time_diff_thold=1

rm -f ${tmp_dir}/*

for esxi_server in ${esxi_server_arr[@]}
do
    API_URL="https://${esxi_server}/rest/appliance/system/time/"
    esxi_host_tmpf=$(echo $(curl -ik ${API_URL}) > ${tmp_dir}/${esxi_server}_timenow.tmp)
    esxi_host_tmpf2=$(sed -i 's/\r/\n/g' ${tmp_dir}/${esxi_server}_timenow.tmp)
    esxi_host_timestamp=$(grep -i 'date' ${tmp_dir}/${esxi_server}_timenow.tmp | sed -e 's/^ Date://g')
    esxi_server_time=$(date -d "${esxi_host_timestamp}" +%s)
    ntp_server_time=$(su - jong -c "ssh ${ntp_server} 'date +%s'")

    # 計算秒差
    time_diff=$((${esxi_server_time}-${ntp_server_time}))
    # 由於取出的秒差可能為正或負值，為了判斷方便所以直接取絕對值
    if [ ${time_diff#-} -gt ${time_diff_thold} ]; then
        echo "${esxi_server} 時間與 ntp server (${ntp_server}) 時間差大於 ${time_diff_thold} 秒，請檢查 (目前差距 ${time_diff#-} 秒)。" >> ${tmp_dir}/result
    else
        echo "${esxi_server} 時間與 ntp server (${ntp_server}) 時間差小於等於 ${time_diff_thold} 秒。" >> ${tmp_dir}/result
    fi
done

result_nu=$(grep '大於' ${tmp_dir}/result | wc -l)
result_text=$(grep '大於' ${tmp_dir}/result)
if [ ${result_nu} -gt 0 ]; then
    echo -e "CRITICAL - ESXi Server 校時警告："${result_text}
    exit 2
elif [ ${result_nu} -eq 0 ]; then
    echo "OK - ESXi Server 校時正常。"
    exit 0
else
    echo "UNKNOWN - 未知的警告"
    exit 3
fi
