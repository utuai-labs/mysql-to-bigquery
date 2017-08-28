#!/bin/bash

for tn in `mysql --batch --skip-page --skip-column-name --raw -h35.202.122.232 -uroot -pVAriv6tK -e"show tables from $DB_NAME"`
do 
  mysql -uroot -p$PASSWORD -h$DB_IP $DB_NAME -B -e "select * from \`$tn\`;" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > tables/$tn.csv
done
