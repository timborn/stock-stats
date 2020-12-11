#!/usr/bin/env bash
# generate the unique list of all sectors across aristocrats

for i in `cat aristocrats`; do
	stock-stats $i | jq '.Sector'
done | sort -u
