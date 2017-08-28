#!/bin/bash

process_table() {
  table=$1

  echo "${table} - Removing old data"
  bq rm -f phrg.${table} 2> /dev/null

  if [[ $(wc -l < tables/${table}.csv) -ge 500 ]]; then
    cat tables/${table}.csv | head -n 500 > heads/${table}.csv

    # Load head, seems to fix autodetect issue for larger files
    echo "${table} - Loading head version"
    bq load --skip_leading_rows 1 --null_marker NULL --allow_quoted_newlines --autodetect --schema_update_option ALLOW_FIELD_ADDITION --allow_quoted_newlines phrg.${table} heads/${table}.csv

    echo "${table} - Saving schema"
    bq show --schema phrg.${table} > schemas/${table}.json

    echo "${table} - Removing head data"
    bq rm -f phrg.${table}

    # Change this after I'm done.  Uploaded in a separate step, so can skip that and go directly from local in future
    # I'm referring to the gs:// designation, you can point to local fs instead
    echo "${table} - Loading full table"
    bq load --skip_leading_rows 1 --null_marker NULL --allow_quoted_newlines phrg.${table} gs://phrg-datatables/${table}.csv schemas/${table}.json
  else
    if [[ $(wc -l < tables/${table}.csv) -ge 2 ]]; then
      echo "${table} - Loading full table"
      bq load --skip_leading_rows 1 --null_marker NULL --autodetect --schema_update_option ALLOW_FIELD_ADDITION --allow_quoted_newlines phrg.${table} gs://phrg-datatables/${table}.csv
    else 
      echo "${table} - Skipping, empty"
    fi
  fi
}

for t in  `ls tables | grep csv`
do
  process_table ${t%.csv}&

  # Slow it down a bit, to many open wouldn't be great
  # not certain how to properly implement a max number of uploads 
  # in bash without some complication
  sleep 2
done
