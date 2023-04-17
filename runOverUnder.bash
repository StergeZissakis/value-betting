#!/bin/bash

source ./source_env

./kill_chrome_and_vpn.bash

./runOverUnderPortal.bash

./runOverUnderSafari.bash

./runArchiverOverUnder.bash

./kill_chrome_and_vpn.bash
