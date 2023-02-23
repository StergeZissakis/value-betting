#!/bin/bash

source python_env/bin/activate

psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();'

exec 3< <(cd config; sudo ./connect_italy.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

export DISPLAY=:0

python ./oddsportal_results.py | tee oddsportal_results.log  2>&1

python ./oddsportal.py | tee oddsportal.log  2>&1

kill -9 %1

exec 3< <(cd config; sudo ./connect_greece.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

python ./oddssafari.py | tee oddssafari.log 2>&1

kill -9 %1

psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();'
