#!/bin/bash

echo "Cleaning up chrome leftovers..."
killall -r ".*chrome.*"
killall -r ".*chromium.*"

#ps -e | grep chrome | cut -d " " -f 4 | xargs kill -9
#ps -e | grep openvpn | cut -d " " -f 4 | xargs sudo kill -9
#ps -e | grep runArchiver | cut -d " " -f 3 | xargs kill -9
#ps -e | grep runOverUnder | cut -d " " -f 3 | xargs kill -9