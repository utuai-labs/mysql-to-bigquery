#!/bin/bash
set -euo pipefail

mkdir -p tables

for tn in `mysql --batch --skip-page --skip-column-name --raw -h$DB_IP -uroot -p$DB_PASSWORD -e"show tables from $DB_NAME"`
do
  file=tables/$tn.tsv
  if [ -f $file ]; then
    echo "Skipping $tn"
  else
    # Replace quotes with "" in accordance with RFC-4180
    # idk what most of others are, find more at bottom
    echo "Exporting $tn"
    mysql -uroot -p$DB_PASSWORD -h$DB_IP $DB_NAME -B -e "select * from \`$tn\`;" | pv -lq | sed 's/"/""/g;s/\t\t/\tNULL\t/g;s/\t/"\t"/g;s/^/"/;s/$/"/;s/^M//' > tables/$tn.tsv
  fi
done

# Some resources
# https://stackoverflow.com/questions/17808511/properly-escape-a-double-quote-in-csv
# https://stackoverflow.com/questions/356578/how-to-output-mysql-query-results-in-csv-format
