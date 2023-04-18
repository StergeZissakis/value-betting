#!/bin/bash


./kill_chrome_and_vpn.bash

export DISPLAY=:0
source env/bin/activate

./runArchivePastMatches.bash

echo "*** Connecting to Italy..."
exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | tee ../logs/italy_vpn_archiver.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Italy."

echo "Running Odds Portal Results..."
time python ./oddsportalOverUnder_results.py 2>&1 | tee ./logs/oddsportal_results.log  
if [ $? != 0 ]
then
    echo "Re-running Odds Portal Results..."
    time python ./oddsportalOverUnder_results.py 2>&1 | tee ./logs/oddsportal_results.log  
fi
echo "*** Odds Portal Results Finished."

./runCalculateOverUnderResults.bash

./kill_chrome_and_vpn.bash
