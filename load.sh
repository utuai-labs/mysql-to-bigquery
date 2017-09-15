#!/bin/bash

process_table() {
  table=$1

  echo "${table} - Removing old data"
  bq rm -f phrg.${table} 2> /dev/null

  # Change this after I'm done.  Uploaded in a separate step, so can skip that and go directly from local in future
  # I'm referring to the gs:// designation, you can point to local fs instead
  echo "${table} - Loading full table"
  bq load --max_bad_records 10 --skip_leading_rows 1 --allow_quoted_newlines --quote "" -F "\t" --null_marker NULL phrg.${table} tables/${table}.tsv schemas/${table}.json
}

for t in  `ls tables | grep tsv | grep homes`
do
  process_table ${t%.tsv} &

  # Slow it down a bit, to many open wouldn't be great
  # not certain how to properly implement a max number of uploads 
  # in bash without some complication
  sleep 5
done
