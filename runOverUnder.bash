#!/bin/bash

source python_env/bin/activate

psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();'

exec 3< <(cd config; sudo ./connect_italy.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

export DISPLAY=:0
python ./oddsportal.py 2>&1 | tee oddsportal.log 

kill -9 %1

exec 3< <(cd config; sudo ./connect_greece.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

python ./oddssafari.py 2&1 | tee oddssafari.log

kill -9 %1

psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();'
