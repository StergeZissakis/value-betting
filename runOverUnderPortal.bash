#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

sudo ./kill__vpn.bash
./kill_chrome.bash

echo "*** Connecting to Italy..."
nohup sudo config/connect_italy.sudo > ./logs/italy_vpn.log  2>&1 &
echo $! > config/italy_vpn.pid
grep -q "Initialization Sequence Completed" logs/italy_vpn.log
while [ $? != 0 ];
do
    sleep 1
    grep -q "Initialization Sequence Completed" logs/italy_vpn.log
done;
echo "*** Connected to Italy."

echo "*** Running Odds Portal..."
time nice -10 python -u ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  
echo "*** Odds Portal Finished."


kill `cat config/italy_vpn.pid`
rm -f config/italy_vpn.pid
sudo ./kill_vpn.bash
./kill_chrome.bash
