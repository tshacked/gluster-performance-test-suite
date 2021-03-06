#!/bin/bash

if [ $# -ne 2  ]
then
  echo; echo "Usage: $0 <result to be analyzed> <number of threads>"
  echo; echo "eg:"
  echo; echo "    # $0 fuse-mount-large-file-result.txt 16"
  exit
fi

NoOfThreads=$2

declare -A Operations

Operations=( ["seq-write"]="initial writers" ["seq-read"]="$NoOfThreads readers" ["random-read"]="random readers"  ["random-write"]="random writers" )

for key in ${!Operations[@]}
do
    if [ "$key"  = "seq-read" ]
    then
        grep -i "${Operations[$key]}" $1 | awk  -v ops="$key"  -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$8)} END{print ops " : " sum/NR}' >> /tmp/$$-lr
    else
        grep -i "${Operations[$key]}" $1 | awk  -v ops="$key"  -v PREC=100 -v CONVFMT=%.17g  'BEGIN{ sum = 0} {sum+=sprintf("%f",$9)} END{print ops " : " sum/NR}'  >> /tmp/$$-lr
    fi
done


sort -r /tmp/$$-lr
