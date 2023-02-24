#!/bin/bash

source python_env/bin/activate

psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();'

exec 3< <(cd config; sudo ./connect_italy.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

export DISPLAY=:0

time python ./oddsportal_results.py 2>&1 | tee logs/oddsportal_results.log  
while [ $? != 0 ]; do
    time python ./oddsportal_results.py 2>&1 | tee logs/oddsportal_results.log  
done
