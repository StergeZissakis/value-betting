#!/bin/bash

source python_env/bin/activate

export DISPLAY=:0

echo "*** Connecting to Italy..."
exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | /usr/bin/tee ../logs/italy_vpn.log ) 
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &
echo "*** Connected to Italy."

sleep 5

echo "*** Running Odds Portal..."
time ./python_env/bin/python ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  
if [ $? != 0 ]
then
    echo "*** Repeat Running Odds Portal..."
    time ./python_env/bin/python ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  
fi
echo "*** Odds Portal Finished."

./kill_chrome.bash