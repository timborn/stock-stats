#!/usr/bin/env bash

# NB this is often the first in the pipe as it selects which stocks
# to consider and filters the fields we care about.  Basically all the
# other scripts depend on that field selection.
# HA!  payout is the inverse of divCover.  Didn't think this through and added divCover, but really not needed
# Sometimes we do not want to filter things out, in which case -n flag is useful.
#
# DONE: allow #comments in my input files
# TODO: allow a ticker on command line
# DEBUG=1
[ $DEBUG ] && echo DEBUG PWD=$PWD SHLVL=$SHLVL running $0 >&2

USAGE="USAGE: $0 [-n] [-t <ticker>] [file]"
NOFILT=0; TICKER=0
while getopts ":nt:" opt; do
  case ${opt} in 
    n ) # no filters
      NOFILT=1
      ;;
    t ) # give me a ticker symbol; mutex w.r.t. input file
      TICKER=1
      TMPFILE=$(mktemp /tmp/aristo.XXXXXX)
      echo $OPTARG > $TMPFILE
      ;;
    \? )
      echo $USAGE
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# OPTIONAL: name of a file to use instead of aristocrats
# the file is just a list of stock symbols, one per line
# If both a ticker and file are provided, file wins
if [ $TICKER -eq 1 ] ; then
	FN=$TMPFILE
else
	FN="aristocrats"
fi
[ $DEBUG ] && echo DEBUG dollar-hash $# >&2
if [ $# -eq 1 ]; then
	if [ -r $1 ] ; then 
		FN=$1
		[ $DEBUG ] && echo DEBUG set FN=$FN >&2
	fi
fi

# read line by line
# https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/
# Example: "range":"30.11 - 71.37"
while IFS= read -r i
do
	if [[ "$i" =~ ^\#.*$ ]] ; then continue; fi	# skip comments
### finviz
### 	stock-stats $i | jq '{ symbol: "'$i'", 
### 		price: (.Price) | tonumber, 
### 		target: ."Target Price",
### 		range: ."52W Range",
### 		payout: ."Payout",
### 		EPSttm: ."EPS (ttm)",
### 		dividend: .Dividend, 
### 		dividendPct: ."Dividend %" }' 2>/dev/null |

### now we use yfinance
	stock-stats $i | jq '{ symbol: "'$i'", 
		price: (.currentPrice) | tonumber, 
		target: ."targetMedianPrice", 
		W52Low: ."fiftyTwoWeekLow", 
		W52High: ."fiftyTwoWeekHigh", 
		payout: ."payoutRatio", 
		EPSttm: ."trailingEps", 
		dividend: ."lastDividendValue", 
		dividendPct: ."dividendYield"  }' 2>/dev/null | 
	./calculate-target-gains.js |
	./calculate-div-cover.js |
	./midprice.js |
	if [ $NOFILT -eq 0 ] ; then ./filter-out-payout.js; else cat ; fi	# toss anything where payout ratio >= 100% 
done < $FN
