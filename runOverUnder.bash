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

time python ./oddsportal.py 2>&1 | tee logs/oddsportal.log  
while [ $? != 0 ]; do
    time python ./oddsportal.py 2>&1 | tee logs/oddsportal.log  
done

kill -9 %1

exec 3< <(cd config; sudo ./connect_greece.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

time python ./oddssafari.py 2>&1 | tee logs/oddssafari.log 
while [ $? != 0 ]; do
    python ./oddssafari.py 2>&1 | tee logs/oddssafari.log 
done

kill -9 %1

psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();'
