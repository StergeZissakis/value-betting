#!/bin/bash

sudo config/disable_ipv6.sudo

source python_env/bin/activate

export DISPLAY=:0

echo "*** Connecting to Italy..."
exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | /usr/bin/tee ../logs/italy_vpn.log ) 
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Italy."

echo "*** Running Odds Portal..."
time ./python_env/bin/python ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  
if [ $? != 0 ]
then
    echo "*** Repeat Running Odds Portal..."
    time ./python_env/bin/python ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  
fi
echo "*** Odds Portal Finished."

kill -9 %1

sleep 10

echo "*** Connecting to Greece..."
exec 3< <(cd config; sudo ./connect_greece.sudo 2>&1 | tee ../logs/greece_vpn.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Greece."

echo "Running Odds Safari..."
time ./python_env/bin/python ./oddssafariOverUnder.py 2>&1 | tee logs/oddssafari.log 
if [ $? != 0 ]
then
echo "Repeat Running Odds Safari..."
    time ./python_env/bin/python ./oddssafariOverUnder.py 2>&1 | tee logs/oddssafari.log 
fi
echo "*** Odds Safari Finished."

kill -9 %1

./kill_chrome.bash
