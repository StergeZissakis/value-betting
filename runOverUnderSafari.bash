#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

echo "*** Connecting to Greece..."
exec 3< <(cd config; sudo ./connect_greece.sudo 2>&1 | tee ../logs/greece_vpn.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Greece."

sleep 5

echo "*** Running Odds Safari..."
time python ./oddssafariOverUnder.py 2>&1 | tee ./logs/oddssafari.log 
if [ $? != 0 ]
then
echo "*** Repeat Running Odds Safari..."
    time python ./oddssafariOverUnder.py 2>&1 | tee ./logs/oddssafari.log 
fi
echo "*** Odds Safari Finished."

sudo ./kill_chrome_and_vpn.bash
