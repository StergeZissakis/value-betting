#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

sudo ./kill_chrome_and_vpn.bash
./kill_chrome_and_vpn.bash

echo "*** Connecting to Greece..."
nohup sudo config/connect_greece.sudo 2>&1 | tee ./logs/greece_vpn.log & > /dev/null 2>&1
echo $! > config/greece_vpn.pid
grep -q "Initialization Sequence Completed" logs/greece_vpn.log
while [ $? != 0 ];
do
    sleep 1
    grep -q "Initialization Sequence Completed" ./logs/greece_vpn.log
done;
echo "*** Connected to Greece."

echo "*** Running Odds Safari..."
time python ./oddssafariOverUnder.py 2>&1 | tee ./logs/oddssafari.log 
echo "*** Odds Safari Finished."

kill `cat config/greece_vpn.pid`
rm -f config/greece_vpn.pid
sudo ./kill_chrome_and_vpn.bash
./kill_chrome_and_vpn.bash
