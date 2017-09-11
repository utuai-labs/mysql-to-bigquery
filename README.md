# mysql-to-bigquery
Scripts for uploading a full mysql database to big query.


## How it works

We start by dumping from mysql into tsv, then load into big query.

### Dump

We dump into tsv. 

1. Query mysql for all tables
2. Loop through tables, fetching all documents.
3. Save to tables/tableName.csv with fields quoted, quotes escaped, and empty fields changed to null.


#### Use
Dump requires the following environmental variables set to use

DB_PASSWORD
DB_IP
DB_NAME

### Load

Per table

1. Remove all old data from table
2. If larger than 500 lines
  1. Take "head" of 500 lines
  2. Load with autodetection of schema
  3. Save schema that big query detected
  4. Load full table without autodetection enabled, with schema specified
3. If not larger than 500 lines
  1. Load full table, with schema autodetection enabled

#### Use

You'll need gcloud tools installed

1. Install gcloud https://cloud.google.com/sdk/downloads
2. Install bq `gcloud components install bq`
3. Make sure you have credentials `gcloud auth login`
4. Select project?


#### Notes: 

Loading full table with autodetection enabled seems to always err on large tables. The head, load, save schema, load full crap is a workaround for this.  We can make things significantly faster in the future by improving this workaround, or not recalculating schema each time.


## Todo

- Create docker container to run script and pull in deps.
- Create sql part to go from sql dump to uploaded on big query.
