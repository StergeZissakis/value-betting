#!/bin/bash

mkdir -p Archive
tar -zcf Archive/`date +%Y-%m-%d@%H.%M`.tar.gz ./*.log
rm *.log
