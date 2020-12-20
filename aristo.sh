#!/usr/bin/env bash

# NB this is often the first in the pipe as it selects which stocks
# to consider and filters the fields we care about.  Basically all the
# other scripts depend on that field selection.
# HA!  payout is the inverse of divCover.  Didn't think this through and added divCover, but really not needed
# Sometimes we do not want to filter things out, in which case -n flag is useful.

USAGE="USAGE: $0 [-n] [file]"
NOFILT=0
while getopts ":n" opt; do
  case ${opt} in 
    n ) # no filters
      NOFILT=1
      shift
      ;;
    \? )
      echo $USAGE
      exit 1
      ;;
  esac
done

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
		EPSttm: ."EPS (ttm)",
		dividend: .Dividend, 
		dividendPct: ."Dividend %" }' 2>/dev/null |
	./calculate-target-gains.js |
	./calculate-div-cover.js |
	./midprice.js |
	if [ $NOFILT -eq 0 ] ; then ./filter-out-payout.js; else cat ; fi	# toss anything where payout ratio >= 100% 
done
