#!/bin/bash

config/disable_ipv6.sudo

source python_env/bin/activate

export DISPLAY=:0

exec 3< <(cd config; sudo ./connect_italy.sudo 2>&1 | /usr/bin/tee ../logs/italy_vpn.log ) 
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

time ./python_env/bin/python ./oddsportalOverUnder.py 2>&1 | tee logs/oddsportal.log  

kill -9 %1

exec 3< <(cd config; sudo ./connect_greece.sudo 2>&1 | tee ../logs/greece_vpn.log)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

time ./python_env/bin/python ./oddssafariOverUnder.py 2>&1 | tee logs/oddssafari.log 

kill -9 %1

psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();'

./kill_chrome.bash
