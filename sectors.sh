#!/usr/bin/env bash
# generate the unique list of all sectors across aristocrats

# OPTIONAL: name of a file to use instead of aristocrats
# the file is just a list of stock symbols, one per line
FN="aristocrats"
if [ $# -eq 1 ]; then
	if [ -r $1 ] ; then 
		FN=$1
	fi
fi

for i in `cat $FN`; do
	stock-stats $i | jq '.Sector'
done | sort -u
