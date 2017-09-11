#!/bin/bash

process_table() {
  table=$1

  echo "${table} - Removing old data"
  bq rm -f phrg.${table} 2> /dev/null

  if [[ $(wc -l < tables/${table}.tsv) -gt 500 ]]; then
    cat tables/${table}.tsv | head -n 500 > heads/${table}.tsv

    # Load head, seems to fix autodetect issue for larger files
    echo "${table} - Loading head version"
    bq load -F "\t" --null_marker NULL --autodetect phrg.${table} heads/${table}.tsv

    echo "${table} - Saving schema"
    bq show --schema phrg.${table} > schemas/${table}.json

    echo "${table} - Removing head data"
    bq rm -f phrg.${table}

    # Change this after I'm done.  Uploaded in a separate step, so can skip that and go directly from local in future
    # I'm referring to the gs:// designation, you can point to local fs instead
    echo "${table} - Loading full table"
    bq load -F "\t" --null_marker NULL phrg.${table} tables/${table}.tsv schemas/${table}.json
  else
    if [[ $(wc -l < tables/${table}.tsv) -ge 2 ]]; then
      echo "${table} - Loading full table"
      bq load -F "\t" --null_marker NULL --autodetect phrg.${table} tables/${table}.tsv
    else 
      echo "${table} - Skipping, empty"
    fi
  fi
}

for t in  `ls tables | grep tsv`
do
  process_table ${t%.tsv} &

  # Slow it down a bit, to many open wouldn't be great
  # not certain how to properly implement a max number of uploads 
  # in bash without some complication
  sleep 10
done
