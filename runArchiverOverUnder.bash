#!/bin/bash


sudo ./kill_vpn.bash
./kill_chrome.bash

export DISPLAY=:0
source env/bin/activate

./runArchivePastMatches.bash

echo "*** Connecting to Italy..."
nohup sudo config/connect_italy.sudo > ./logs/italy_vpn_archiver.log 2>&1 &
echo $! > config/italy_vpn.pid
grep -q "Initialization Sequence Completed" logs/italy_vpn_archiver.log
while [ $? != 0 ];
do
    sleep 1
    grep -q "Initialization Sequence Completed" logs/italy_vpn_archiver.log
done;
echo "*** Connected to Italy."

echo "Running Odds Portal Results..."
time nice -10 python -u ./oddsportalOverUnder_results.py 2>&1 | tee ./logs/oddsportal_results.log  
echo "*** Odds Portal Results Finished."

./runCalculateOverUnderResults.bash

kill `cat config/italy_vpn.pid`
rm -f config/italy_vpn.pid
sudo ./kill_vpn.bash
./kill_chrome.bash
