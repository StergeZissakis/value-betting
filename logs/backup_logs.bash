#!/bin/bash

mkdir -p Archive
tar -cf Archive/`date +%Y-%m-%d@%H.%M`.tar ./*.log
rm *.log
