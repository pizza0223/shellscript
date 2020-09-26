#!/bin/bash

# 重新抓取系統預設環境變數
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
# 設定警戒值
CRI_PERCENTAGE=90

result=`sudo lvs | grep lv_mysqldata_ | awk '{print $6}'`
output="快照備份使用率已達: ${result} %"

if [ `echo "${result} >= ${CRI_PERCENTAGE}" | bc` -ge 1 ]; then
    output="快照備份使用率已達: ${result} %，超過警戒值 ${CRI_PERCENTAGE} %"
    echo "CRITICAL - ${output}"
    exit 1
elif [ `echo "${result} >= ${CRI_PERCENTAGE}" | bc` -lt 1 ]; then
    output="快照備份使用率已達: ${result} %，低於警戒值 ${CRI_PERCENTAGE} %"
    echo "OK - ${output}"
    exit 0
else
    echo "UNKNOWN - ${output}"
    exit 3
fi
