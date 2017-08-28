# mysql-to-bigquery
Scripts for uploading a full mysql database to big query.


## How it works

Assuming you have a mysql db 


## Cavaets

Quite a few errors still happening on upload to big query.  I believe this to
be due to failure of the dump script generating valid csvs and/or incorrect
encoding.  The big query side assumes utf-8, and don't think we're exporting as
this.


## Todo

- Create docker container to run script and pull in deps.
- Create sql part to go from sql dump to uploaded on big query.
