#!/bin/bash

mkdir -p schemas
mkdir -p heads

process_table() {
  table=$1

  echo "${table} - Removing old data"
  bq rm --project_id=powers-175110 -f phrg.${table} 2> /dev/null

  cat tables/${table}.tsv | head -n 1000 > heads/${table}.tsv

  # Load head, seems to fix autodetect issue for larger files
  echo "${table} - Loading head version"
  bq load --project_id=powers-175110 --allow_quoted_newlines --quote "" -F "\t" --null_marker NULL --autodetect phrg.${table} heads/${table}.tsv

  echo "${table} - Saving schema"
  bq show --project_id=powers-175110 --schema phrg.${table} > schemas/${table}.json
}

for t in  `ls tables | grep tsv`
do
  process_table ${t%.tsv}
done
