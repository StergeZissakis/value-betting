#!/bin/bash

source python_env/bin/activate

psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();' 2>&1 | tee -a logs/ArchivePastMatches.log

exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | tee logs/italy_vpn_archiver.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

export DISPLAY=:0

time python ./oddsportal_results.py 2>&1 | tee logs/oddsportal_results.log  
while [ $? != 0 ]; do
    time python ./oddsportal_results.py 2>&1 | tee -a logs/oddsportal_results.log  
done


psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();' 2>&1 | tee -a logs/ArchivePastMatches.log
