#!/bin/bash

source env/bin/activate

export DISPLAY=:0


./kill_chrome_and_vpn.bash

./runOverUnderPortal.bash

./runOverUnderSafari.bash

./runArchiverOverUnder.bash

./kill_chrome_and_vpn.bash
