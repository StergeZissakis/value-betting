#!/bin/bash

echo "*** Calculating Results..."
psql -U postgres postgres -c 'SELECT "CalculateOverUnderResults"();' 2>&1 | tee -a ./logs/ArchivePastMatches.log
echo "*** Finished Calculating Results."

