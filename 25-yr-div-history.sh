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
TMP=`mktemp` || exit 1
TMP2=`mktemp` || exit 1

if [ $# -eq 0 ] ; then 
	echo DEBUG: ARGCOUNT=$#
	echo "USAGE: $0 [-d] <stockSymbol>" >&2
	exit 3
fi

if [ $# -eq 2 ] && [ "$1" != "\-d" ] ; then
	SYM=$2
	DEBUG=1
fi


./dividend-history2.sh  $SYM |  
jq '.results[] | { paymentDate: .paymentDate, amount: .amount } ' |  
jq -sc |  
in2csv -f json  | 
tail -n +2 |
sed -e's/-[0-9][0-9]-[0-9][0-9]//' |  
sort > $TMP

# TODO: if the last year is only a partial, do something sensible (predict?)
# if first and last years are partial, toss them
FIRSTYR=$( head -1 $TMP |cut -f1 -d, )
LASTYR=$( tail -1 $TMP |cut -f1 -d, )
cnt=$( grep ^$FIRSTYR $TMP | wc -l )
if [ $cnt -ne 4 ] ; then  # rip 'em out
	grep -v  $FIRSTYR $TMP > $TMP2 && mv $TMP2 $TMP
fi
cnt=$( grep ^$LASTYR $TMP | wc -l )
if [ $cnt -ne 4 ] ; then  # rip 'em out
	grep -v  $LASTYR $TMP > $TMP2 && mv $TMP2 $TMP
fi

echo
echo DEBUG: here is the intermediate file with partial first/last years trimmed
cat $TMP
echo

awk -F ',' '{a[$1] += $2} END{ for (i in a) print i, a[i] }' $TMP | sort
# awk -F ',' '{a[$1] += $2} END{ delete a[2021]; for (i in a) print i, a[i] }' |
# awk -F ',' '{a[$1] += $2} END{print 2016, a[2016]; print 2017, a[2017]; print 2018, a[2018]; print 2019, a[2019]; print 2020, a[2020] }'

rm $TMP $TMP2 2>/dev/null || :
