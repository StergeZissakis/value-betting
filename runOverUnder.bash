#!/bin/bash

export DISPLAY=:0
source ./env/bin/activate

./kill_chrome_and_vpn.bash

./runOverUnderPortal.bash

./runOverUnderSafari.bash

./runArchiverOverUnder.bash

./kill_chrome_and_vpn.bash
