#!/usr/bin/env bash
# extra a subset using shell variable for stock symbol

for i in `cat aristocrats`; do
	stock-stats $i | jq '{ symbol: "'$i'", 
		price: .Price, 
		target: ."Target Price",
		dividend: .Dividend, 
		dividendPct: ."Dividend %" }' 2>/dev/null |
	./calculate-target-gains.js
done