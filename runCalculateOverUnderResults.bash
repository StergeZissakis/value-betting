#!/bin/bash

echo "*** Calculating Results..."
psql -h localhost -U postgres -c 'SELECT "CalculateOverUnderResults"();' 2>&1 | tee -a ./logs/ArchivePastMatches.log
echo "*** Finished Calculating Results."

