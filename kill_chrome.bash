#!/bin/bash

ps -e | grep chrome | cut -d ' ' -f 1 | xargs kill -9
ps -e | grep runArchiver | cut -d ' ' -f 1 | xargs kill -9
ps -e | grep runOverUnder | cut -d ' ' -f 1 | xargs kill -9
