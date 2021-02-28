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
# quick ratio
# divcon >= 3

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
# TODO 

# does this stock generate "good" dividends?  (good == > 2.5, assuming inflation of 2%)
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

if [ $ISARISTO -eq 0 ] ; then
	echo -n $OK
	echo " This stock is a dividend $AORK"
else
	echo "$NEUTRAL This stock is not an aristocrat."
fi
	echo "The dividend yield is $DIVYIELD"
	echo "The 5-year growth rate for dividends is $DGR"
	echo "An aristocrat has 25+ years of continuous dividend increases (S&P500 index only)"
	echo "A dividend KING has 50+ years of continuous dividend increases."

# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# TODO

# say something sensible about free cash flow
# TODO


# quick ratio
# The quick ratio is X.  The represents the ratio of highly liquid 
# assets to current liabilities (due in the next year).  
# Expect a quick ratio of 1.0.  Numbers below this suggest the 
# company may have trouble paying liabilities without taking on
# more debt or selling assets.

# divcon >= 3
LASTUPDATE=`head -1 divcontable.csv  | cut -f 7 -d,`
DIVCON=`grep ,$TICKER, divcontable.csv  | cut -f7 -d,`
if [ $DIVCON -ge 3 ] ; then
	echo -n $OK 
else
	echo -n $ALERT
fi
echo " DIVCON: $DIVCON"
echo DIVCON uses a five-tier rating, from 1 to 5, to gauge companies\'
echo dividend health. A DIVCON 5 rating indicates not just a healthy
echo dividend, but a high likelihood of dividend growth. DIVCON 1 dividend
echo stocks, on the other hand, are the likeliest to cut or suspend their
echo payouts.
