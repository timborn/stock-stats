#!/usr/bin/env bash

# OPTIONAL: name of a file to use instead of aristocrats
# the file is just a list of stock symbols, one per line
FN="aristocrats"
if [ $# -eq 1 ]; then
	if [ -r $1 ] ; then 
		FN=$1
	fi
fi

for i in `cat $FN`; do
	stock-stats $i | jq '{ symbol: "'$i'", 
		price: (.Price) | tonumber, 
		target: ."Target Price",
		range: ."52W Range",
		payout: ."Payout",
		dividend: .Dividend, 
		dividendPct: ."Dividend %" }' 2>/dev/null |
	./calculate-target-gains.js |
	./midprice.js
done
