# given a ticker symbol, apply heuristics and generate sensible advice
#
# I would like some of these commands to be on my PATH.  Do I link them to ~/bin?  Add . to PATH?

USAGE="$0 <ticker>"
ERR=errout; [ -f $ERR ] && rm $ERR
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
## is the price 'volatile'?
# does this stock generate "good" dividends?  (good == > 2.5, assuming inflation of 2%)
# is this stock an aristocrat or king?  (make sure to dump dfn if you tag it)
# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# say something sensible about free cash flow
#   say something about payout ratio - how well is the dividend covered
# quick ratio
# divcon >= 3
# Return On Equity (ROE) - a measure of profitability

### header
COMPANY=`stock-stats $TICKER | jq .Company`
echo "Advice report for $COMPANY ($TICKER)"

# did this stock actually have any earnings?
# TODO: when EARNINGS is negative, P/E often shows up as '-' which throws errors on my output.  Fix
# jq: error (at <stdin>:1): Invalid numeric literal at EOF at line 1, column 1 (while parsing '-')
# PE=`./stock-stats $TICKER | jq '."P/E"|tonumber'`
PE=`./stock-stats $TICKER | jq '."P/E"| try tonumber catch 9999'` 2>>$ERR
FPE=`./stock-stats $TICKER | jq '."Forward P/E"|tonumber'`
YIELD=`echo "scale=2; 100 / $PE" | bc -l`
EARNINGS=`./stock-stats $TICKER | jq '."EPS (ttm)"|tonumber'`
if [[ $EARNINGS > 0 ]] ; then
	echo -n $OK
else
	echo -n $ALERT
fi
echo " Earnings over past year: $EARNINGS"
echo "P/E ratio: $PE, Forward P/E ratio: $FPE"
echo Implies an earnings yield of $YIELD%

### is the price "fair" (at or below midpoint of past year hi/lo)
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

### volatility
VWEEK=$( stock-stats $TICKER | ./volatility.js | jq '.VolatilityWk' )
VMONTH=$( stock-stats $TICKER | ./volatility.js | jq '.VolatilityMo' )
# NB the number may or may not have trailing % sign
# NB the number may or may not be in quotes
VWEEK=`echo $VWEEK   | tr -d '%' | tr -d '"'`
VMONTH=`echo $VMONTH | tr -d '%' | tr -d '"'`
if (( $(echo "$VWEEK > 10" | bc -l) )); then
	echo "$ALERT This stock price looks volatile ($VWEEK% change this week)"
fi
if (( $(echo "$VMONTH > 10" | bc -l) )); then
	echo "$ALERT This stock price looks volatile ($VMONTH% change this week)"
fi


# does this stock generate "good" dividends?  (good == > 2.5%, assuming inflation of 2%)
# TODO 

# is this stock part of S&P500 Quality Dividend Index (QDIV)?
grep ^$TICKER$ QDIV.txt > /dev/null 2>&1
QDIV=$?
if [ $QDIV -eq 0 ] ; then 
	echo -n $OK
	echo " This stock is part of the S&P500 Quality Dividend Index (QDIV)"
else
	echo -n $NEUTRAL
	echo " This stock is not part of the S&P500 Quality Dividend Index (QDIV)"
fi

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
	echo "$ALERT This stock is not an aristocrat."
fi

echo "The dividend yield is $DIVYIELD "
echo "The dividend \$$DIV/yr"
echo "The 5-year growth rate for dividends is $DGR"
echo "An aristocrat has 25+ years of continuous dividend increases (S&P500 index only)"
echo "A dividend KING has 50+ years of continuous dividend increases."

# is the P/E > 16?  (historical avg for all stocks, but not necessarily correct for sectors)  TODO
# TODO

# say something sensible about free cash flow(?) TODO
#   say something about payout ratio - how well is the dividend covered
PAYOUT=`stock-stats $TICKER | jq '."Payout"' | sed -e's/%//; s/\"//g' `
[ "$PAYOUT" = '-' ] && PAYOUT="999"
if (( $(echo "$PAYOUT > 90" | bc -l) )); then
	TAG=$ALERT
elif (( $(echo "$PAYOUT >= 50" | bc -l) )); then
	TAG=$NEUTRAL
else
	TAG=$OK
fi
# Oh dear!  Reaching way up (dependency) to get DIVYIELD.
echo $TAG Dividend yield of $DIVYIELD% with a payout ratio of $PAYOUT%
[ $TAG = $ALERT ] && echo "That payout ratio looks unsustainable."
[ $TAG = $OK ]    && echo "That payout looks sustainable."

# quick ratio
# The quick ratio is X.  The represents the ratio of highly liquid 
# assets to current liabilities (due in the next year).  
# Expect a quick ratio of 1.0.  Numbers below this suggest the 
# company may have trouble paying liabilities without taking on
# more debt or selling assets.
QUICK=$( ./stock-stats $TICKER | jq '."Quick Ratio"' | sed -e's/\"//g' )

if (( $(echo "$QUICK >= 1" | bc -l) )); then
	TAG=$OK
elif (( $(echo "$QUICK >= 0.9" | bc -l) )); then
	TAG=$NEUTRAL
else 
	TAG=$ALERT
fi

echo "$TAG The Quick ratio is $QUICK"
echo "This represents the ratio of highly liquid assets to current"
echo "liabilities (due in the next year).  Expect a quick ratio of 1.0."
echo "Numbers below this suggest a company under stress may have trouble"
echo "paying liabilities without taking on more debt or selling assets."

### DIVCON discontinued around September 2020
### https://www.realitysharesadvisors.com/divcon/

# # divcon >= 3
# LASTUPDATE=`head -1 divcontable.csv  | cut -f 7 -d,`
# DIVCON=`grep ,$TICKER, divcontable.csv  | cut -f7 -d,`
# if [ -z "$DIVCON" ] ; then 
# 	echo "$ALERT - I have no DIVCON information for $TICKER"
# 	DIVCON="unknown"
# else
# 	if [ $DIVCON -gt 3 ] ; then
# 		echo -n "$OK "
# 	elif [ $DIVCON -eq 3 ] ; then 
# 		echo -n "$NEUTRAL "
# 	else
# 		echo -n "$ALERT "
# 	fi
# fi
# echo "DIVCON: $DIVCON"
# echo DIVCON uses a five-tier rating, from 1 to 5, to gauge companies\'
# echo dividend health. A DIVCON 5 rating indicates not just a healthy
# echo dividend, but a high likelihood of dividend growth. DIVCON 1 dividend
# echo stocks, on the other hand, are the likeliest to cut or suspend their
# echo payouts.

### ROE
ROE=$( ./stock-stats $TICKER | jq '.ROE' | sed -e's/%//; s/\"//g' )
if (( $(echo "$ROE > 14" | bc -l) )); then
	TAG=$OK
elif (( $(echo "$ROE > 10" | bc -l) )); then
	TAG=$NEUTRAL
else 
	TAG=$ALERT
fi
echo "$TAG The Return On Equity is $ROE%"
echo "ROE is considered a measure of the profitability of a corporation"
echo "in relation to stockholders’ equity."
echo "The long term average ROE for S&P500 is 14%."


###
###	What is the real rate of return for risk free?
###
# No Inflation Panic Yet, but There Is Concern
# 
# The facts that Prof. Blinder doesn’t cite are what worry me. When
# I studied economics at Princeton in 1981 (using Prof. Blinder’s
# textbook), the yield on the 10-year Treasury stood at 14% as of the
# end of December, while the CPI-U inflation rate stood at 8.9%. The
# real risk-free rate of return was therefore a positive 5.1% or so.
# In contrast, today the CPI-U stands at 1.7% (March 10), while the
# yield on the 10-year Treasury stands at 1.71% (March 18), for a
# real risk-free rate of return of what is effectively zero.

CPI=$( ./CPI-U.sh )
TREAS=$( ./10YRYield.sh )
RRR=$( echo "ret=$TREAS - $CPI;scale=4; ret/1" | bc -l )


# "Benjamin Graham, Building A Profession", p. 275
# "The margin of safety is the difference between the perc entage rate of earnings on the
# stock at the price you pay for it and the rate of interest on bonds"
#

YIELD=`echo "scale=2; 100 / $PE" | bc -l`
echo Earnings yield of $YIELD%
MOS=$( echo "ret=$YIELD - $TREAS;scale=4; ret/1" | bc -l )

if (( $(echo "$MOS < 0" | bc -l) )); then
	TAG=$ALERT
else
	TAG=$OK
fi

echo "10 year Treasury yield: " $TREAS"%"
echo "$TAG Margin of Safety: " $MOS"%"


if (( $(echo "$RRR < 0" | bc -l) )); then
	TAG=$ALERT
elif (( $(echo "$RRR <= 2" | bc -l) )); then
	TAG=$NEUTRAL
else
	TAG=$OK
fi

echo "$TAG Risk Free Rate Of Return"
echo "CPI-U: " $CPI"%"
echo "10 year Treasury yield: " $TREAS"%"
echo "Therefore, real risk-free rate of return: " $RRR"%"
