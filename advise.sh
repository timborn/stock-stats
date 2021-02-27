# given a ticker symbol, apply heuristics and generate sensible advice

# ctrl-cmd-space to find emojis
ALERT="❗️"
OK="✅"

# get TICKER off cmdline
TICKER=T

# did this stock actually have any earnings?
# is the price "fair" (at or below midpoint of past year hi/lo)
# does this stock generate "good" dividends?  (good == > 2.5, assuming inflation of 2%)
# is this stock an aristocrat or king?  (make sure to dump dfn if you tag it)
# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# say something sensible about free cash flow
# quick ratio
# divcon >= 3




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
echo DIVCON: $DIVCON
echo DIVCON uses a five-tier rating, from 1 to 5, to gauge companies\'
echo dividend health. A DIVCON 5 rating indicates not just a healthy
echo dividend, but a high likelihood of dividend growth. DIVCON 1 dividend
echo stocks, on the other hand, are the likeliest to cut or suspend their
echo payouts.
