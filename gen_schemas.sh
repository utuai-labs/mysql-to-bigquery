process_table() {
  table=$1

  echo "${table} - Removing old data"
  bq rm -f phrg.${table} 2> /dev/null

  cat tables/${table}.tsv | head -n 1000 > heads/${table}.tsv

  # Load head, seems to fix autodetect issue for larger files
  echo "${table} - Loading head version"
  bq load --allow_quoted_newlines --quote "" -F "\t" --null_marker NULL --autodetect phrg.${table} heads/${table}.tsv

  echo "${table} - Saving schema"
  bq show --schema phrg.${table} > schemas/${table}.json
}

for t in  `ls tables | grep tsv`
do
  process_table ${t%.tsv} &

  # Slow it down a bit, to many open wouldn't be great
  # not certain how to properly implement a max number of uploads 
  # in bash without some complication
  sleep 5
done
