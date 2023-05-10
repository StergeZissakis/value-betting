#!/bin/bash

pg_dump --blobs --clean  --create --encoding=UTF-8 --file=postgresql.sql --format=plain --no-owner --superuser=postgres --verbose --if-exists --dbname=postgres --port=5432 --username=postgres 
pg_dump --schema-only --blobs --clean  --create --encoding=UTF-8 --file=definitions.sql --format=plain --no-owner --superuser=postgres --verbose --if-exists --dbname=postgres --port=5432 --username=postgres 
pg_dump --data-only --column-inserts --blobs --encoding=UTF-8 --file=data.sql --format=plain --no-owner --superuser=postgres --verbose --dbname=postgres --port=5432 --username=postgres 

#\copy soccer_statistics TO './soccer_stats.csv' WITH DELIMITER ',' CSV HEADER
