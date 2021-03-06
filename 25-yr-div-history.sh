# shows 25+ year dividend history for a stock

# DONE: BUG! In December 2020, WMT was already showing a dividend 
# scheduled for 2021, which means we got MORE than 5 yrs and the end 
# value was only a partial year, screwing up the CAGR calculations.  
# --> This is a stinky hack, ignoring 2021.  
# At some point I will need/want 2021 (4Q21?)
#
# DONE: BUG! The order things are printed matters, and awk 
# associative arrays don't care about order

SYM=$1
if [ $# -ne 1 ] ; then 
	echo "USAGE: $0 <stockSymbol>" >&2
	exit 3
fi

./dividend-history2.sh  $SYM |  
jq '.results[] | { paymentDate: .paymentDate, amount: .amount } ' |  
jq -sc |  
in2csv -f json  | 
tail -n +2 |
sed -e's/-[0-9][0-9]-[0-9][0-9]//' |  
awk -F ',' '{a[$1] += $2} END{ delete a[2021]; for (i in a) print i, a[i] }' |
sort
# awk -F ',' '{a[$1] += $2} END{print 2016, a[2016]; print 2017, a[2017]; print 2018, a[2018]; print 2019, a[2019]; print 2020, a[2020] }'

