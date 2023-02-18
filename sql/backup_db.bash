#!/bin/bash

pg_dump --blobs \
        --clean  \
        --create \
        --encoding=UTF-8 \
        --file=postgresql.sql \
        --format=plain \
        --no-owner \
        --superuser=postgres \
        --verbose \
        --if-exists \
        --dbname=postgres \
        --host=localhost  \
        --port=5432 \
        --username=postgres
