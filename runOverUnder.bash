#!/bin/bash

source python_env/bin/activate

export DISPLAY=:0


./kill_chrome.bash

./runOverUnderPortal.bash

./runOverUnderSafari.bash

./runArchiverOverUnder.bash

./kill_chrome.bash
