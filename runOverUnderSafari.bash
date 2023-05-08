#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

sudo ./kill_vpn.bash
./kill_chrome.bash

echo "*** Connecting to Greece..."
nohup sudo config/connect_greece.sudo > ./logs/greece_vpn.log 2>&1 &
echo $! > config/greece_vpn.pid
grep -q "Initialization Sequence Completed" logs/greece_vpn.log
while [ $? != 0 ];
do
    sleep 1
    grep -q "Initialization Sequence Completed" ./logs/greece_vpn.log
done;
echo "*** Connected to Greece."

echo "*** Running Odds Safari..."
time nice -10 python -u ./oddssafariOverUnder.py 2>&1 | tee ./logs/oddssafari.log 
echo "*** Odds Safari Finished."

kill `cat config/greece_vpn.pid`
rm -f config/greece_vpn.pid
sudo ./kill_vpn.bash
./kill_chrome.bash
