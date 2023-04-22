#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

sudo ./kill_vpn.bash
./kill_chrome.bash

./runOverUnderPortal.bash

./runOverUnderSafari.bash

./runArchiverOverUnder.bash

sudo ./kill_vpn.bash
./kill_chrome.bash
