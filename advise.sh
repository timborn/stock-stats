# given a ticker symbol, apply heuristics and generate sensible advice

USAGE="$0 <ticker>"
# ctrl-cmd-space to find emojis
ALERT="❗️"
OK="✅"
NEUTRAL="📒"

# get TICKER off cmdline
if [ $# -eq 1 ]; then
	TICKER=$1
else
	echo $USAGE
	exit 1
fi

# did this stock actually have any earnings?
# is the price "fair" (at or below midpoint of past year hi/lo)
# does this stock generate "good" dividends?  (good == > 2.5, assuming inflation of 2%)
# is this stock an aristocrat or king?  (make sure to dump dfn if you tag it)
# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# say something sensible about free cash flow
#   say something about payout ratio - how well is the dividend covered
# quick ratio
# divcon >= 3

### header
COMPANY=`stock-stats $TICKER | jq .Company`
echo "Advice report for $COMPANY ($TICKER)"

# did this stock actually have any earnings?
# TODO: when EARNINGS is negative, P/E often shows up as '-' which throws errors on my output.  Fix
PE=`./stock-stats $TICKER | jq '."P/E"|tonumber'`
YIELD=`echo "scale=2; 100 / $PE" | bc -l`
EARNINGS=`./stock-stats $TICKER | jq '."EPS (ttm)"|tonumber'`
if [[ $EARNINGS > 0 ]] ; then
	echo -n $OK
else
	echo -n $ALERT
fi
echo " Earnings over past year: $EARNINGS"
echo "P/E ratio: $PE"
echo Implies an earnings yield of $YIELD%

# is the price "fair" (at or below midpoint of past year hi/lo)
PRICE=$( ./aristo.sh -t $TICKER | jq .price )
MIDPRICE=$( ./aristo.sh -t $TICKER | jq .midPrice )
if (( $(echo "$PRICE > $MIDPRICE" | bc -l) )); then
	echo "$ALERT The price is 'too high' (heuristic)"
else
	echo "$OK The price looks 'reasonable' (heuristic)"
fi
echo The price is $PRICE and the mid-point it traded at during 
echo the past year is $MIDPRICE.  The price you pay is the single biggest 
echo determinant of your long term value prospects.

# does this stock generate "good" dividends?  (good == > 2.5%, assuming inflation of 2%)
# TODO 

# is this stock an aristocrat or king?  (make sure to dump dfn if you tag it)
# grep ^$TICKER, DividendAristocrats.csv > /dev/null 2>&1
grep ^$TICKER, dividend-aristocrats.csv > /dev/null 2>&1
ISARISTO=$?
AORK=`grep ^$TICKER, dividend-aristocrats.csv  | cut -d, -f2` # aristo or king?
DGR=`grep ^$TICKER, DividendAristocrats.csv  | cut -d, -f12`  # 5-year Dividend Growth Rate
if [ ! -n "$DGR" ] ; then
	DGR=`./5-yr-div-cagr.sh  $TICKER`
fi
DIVYIELD=`stock-stats $TICKER | jq '."Dividend %"'`
DIV=`stock-stats $TICKER | jq '."Dividend"' | sed -e's/\"//g' `

if [ $ISARISTO -eq 0 ] ; then
	echo -n $OK
	echo " This stock is a dividend $AORK"
else
	echo "$NEUTRAL This stock is not an aristocrat."
fi
echo "The dividend yield is $DIVYIELD "
echo "The dividend \$$DIV/yr"
echo "The 5-year growth rate for dividends is $DGR"
echo "An aristocrat has 25+ years of continuous dividend increases (S&P500 index only)"
echo "A dividend KING has 50+ years of continuous dividend increases."

# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# TODO

# say something sensible about free cash flow
#   say something about payout ratio - how well is the dividend covered
PAYOUT=`stock-stats $TICKER | jq '."Payout"' | sed -e's/%//; s/\"//g' `
# looks wierd because PAYOUT really does include those double quotes
[ "$PAYOUT" = '"-"' ] && PAYOUT="999"
DIVYIELD=`stock-stats $TICKER | jq '."Dividend %"' | sed -e's/%//; s/\"//g' `
if (( $(echo "$PAYOUT > 90" | bc -l) )); then
	TAG=$ALERT
else
	if (( $(echo "$DIVYIELD >= 4" | bc -l) )); then
		TAG=$OK
	else
		TAG=$NEUTRAL
	fi
fi
echo $TAG Dividend yield of $DIVYIELD% with a payout ratio of $PAYOUT%
[ $TAG = $ALERT ] && echo "That payout ratio looks unsustainable."


# quick ratio
# The quick ratio is X.  The represents the ratio of highly liquid 
# assets to current liabilities (due in the next year).  
# Expect a quick ratio of 1.0.  Numbers below this suggest the 
# company may have trouble paying liabilities without taking on
# more debt or selling assets.
QUICK=$( ./stock-stats $TICKER | jq '."Quick Ratio"' | sed -e's/\"//g' )
echo "$NEUTRAL The Quick ratio is $QUICK"
echo "This represents the ratio of highly liquid assets to current"
echo "liabilities (due in the next year).  Expect a quick ratio of 1.0."
echo "Numbers below this suggest a company under stress may have trouble"
echo "paying liabilities without taking on more debt or selling assets."

# divcon >= 3
LASTUPDATE=`head -1 divcontable.csv  | cut -f 7 -d,`
DIVCON=`grep ,$TICKER, divcontable.csv  | cut -f7 -d,`
if [ -z "$DIVCON" ] ; then 
	echo "$ALERT - I have no DIVCON information for $TICKER"
	DIVCON="unknown"
else
	if [ $DIVCON -gt 3 ] ; then
		echo -n "$OK "
	elif [ $DIVCON -eq 3 ] ; then 
		echo -n "$NEUTRAL "
	else
		echo -n "$ALERT "
	fi
fi
echo "DIVCON: $DIVCON"
echo DIVCON uses a five-tier rating, from 1 to 5, to gauge companies\'
echo dividend health. A DIVCON 5 rating indicates not just a healthy
echo dividend, but a high likelihood of dividend growth. DIVCON 1 dividend
echo stocks, on the other hand, are the likeliest to cut or suspend their
echo payouts.
