# shows 5 year dividend history for a stock

SYM=$1
if [ $# -ne 1 ] ; then 
	echo "USAGE: $0 <stockSymbol>" >&2
	exit 3
fi

./dividend-history.sh  $SYM |  
jq '.[] | { paymentDate: .paymentDate, amount: .amount } ' |  
jq -sc |  
in2csv -f json  | 
tail -n +2 |
sed -e's/-[0-9][0-9]-[0-9][0-9]//' |  
awk -F ',' '{a[$1] += $2} END{for (i in a) print i, a[i]}'
