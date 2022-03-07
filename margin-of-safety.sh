# given a ticker symbol, calculate Graham's Margin Of Safety
#
# "Benjamin Graham, Building A Profession", p. 275
# "The margin of safety is the difference between the perc entage rate of earnings on the
# stock at the price you pay for it and the rate of interest on bonds"
#
# I would like some of these commands to be on my PATH.  Do I link them to ~/bin?  Add . to PATH?

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


### header
COMPANY=`stock-stats $TICKER | jq .Company`
echo "margin of safety report for $COMPANY ($TICKER)"

# # TODO: when EARNINGS is negative, P/E often shows up as '-' which throws errors on my output.  Fix
PE=`./stock-stats $TICKER | jq '."P/E"|tonumber'`
YIELD=`echo "scale=2; 100 / $PE" | bc -l`
echo Earnings yield of $YIELD%


TREAS=$( ./10YRYield.sh )
MOS=$( echo "ret=$YIELD - $TREAS;scale=4; ret/1" | bc -l )

if (( $(echo "$MOS < 0" | bc -l) )); then
	TAG=$ALERT
else
	TAG=$OK
fi

echo "10 year Treasury yield: " $TREAS"%"
echo "$TAG Margin of Safety: " $MOS"%"
