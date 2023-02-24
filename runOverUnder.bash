#!/bin/bash

source python_env/bin/activate

psql -h localhost -U postgres -c 'SELECT "ArchivePastMatches"();'

exec 3< <(cd config; sudo ./connect_italy.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

export DISPLAY=:0

time python ./oddsportal_results.py | tee oddsportal_results.log  2>&1
while [ $? != 0 ]; do
    time python ./oddsportal_results.py | tee oddsportal_results.log  2>&1
done

time python ./oddsportal.py | tee oddsportal.log  2>&1
while [ $? != 0 ]; do
    time python ./oddsportal.py | tee oddsportal.log  2>&1
done

kill -9 %1

exec 3< <(cd config; sudo ./connect_greece.sudo)
sed '/Initialization Sequence Completed$/q' <&3 ; cat <&3 &

time python ./oddssafari.py | tee oddssafari.log 2>&1
while [ $? != 0 ]; do
    python ./oddssafari.py | tee oddssafari.log 2>&1
done

kill -9 %1

psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();'
