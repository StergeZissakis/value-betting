#!/bin/bash

echo "*** Archiving rows..."
psql -U postgres postgres -c 'SELECT "ArchivePastMatches"();' 2>&1 | tee -a ./logs/ArchivePastMatches.log
echo "*** Archived rows."


