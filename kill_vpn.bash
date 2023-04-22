#!/bin/bash

echo "Cleaning up vPN..."

if [ -f "config/italy_vpn.pid" ]
then
    kill `cat config/italy_vpn.pid`
    rm -f config/italy_vpn.pid
fi

if [ -f "config/italy_vpn.pid" ]
then
    kill `cat config/greece_vpn.pid`
    rm -f config/greece_vpn.pid
fi

killall -r "connect_.*"
killall -r ".*openvpn"


#ps -e | grep chrome | cut -d " " -f 4 | xargs kill -9
#ps -e | grep openvpn | cut -d " " -f 4 | xargs sudo kill -9
#ps -e | grep runArchiver | cut -d " " -f 3 | xargs kill -9
#ps -e | grep runOverUnder | cut -d " " -f 3 | xargs kill -9
