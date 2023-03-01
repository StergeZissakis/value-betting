#!/bin/bash

sudo config/disable_ipv6.sudo

export DISPLAY=:0
source python_env/bin/activate

echo "*** Archiving rows..."
psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();' 2>&1 | tee -a logs/ArchivePastMatches.log
echo "*** Archived rows."

echo "*** Connecting to Italy..."
exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | tee logs/italy_vpn_archiver.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Italy."

echo "Running Odds Portal Results..."
time ./python_env/bin/python ./oddsportalOverUnder_results.py 2>&1 | tee logs/oddsportal_results.log  
if [ $? != 0 ]
then
    time ./python_env/bin/python ./oddsportalOverUnder_results.py 2>&1 | tee logs/oddsportal_results.log  
fi
echo "*** Odds Portal Results Finished."

echo "*** Calculating Results..."
psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();' 2>&1 | tee -a logs/ArchivePastMatches.log
echo "*** Finished Calculating Results."

./kill_chrome.bash
