# compute CAGR on 5 years of dividends
#
# Given:
#
# $ ./5-yr-div-history.sh  BAC
# 2016 0.25
# 2017 0.39
# 2018 0.54
# 2019 0.66
# 2020 0.72
#
# CAGR = ((end / start) ^ 1/N) -1
#
# Expecting to see: 23%

SYM=$1
if [ $# -ne 1 ] ; then 
	echo "USAGE: $0 <stockSymbol>" >&2
	exit 3
fi

START=$( ./5-yr-div-history.sh $SYM | cut -f 2 -d' ' | head -1 )
END=$( ./5-yr-div-history.sh $SYM | cut -f 2 -d' ' | tail -1 )

# gotta use natural logs to find the 1/5th power
# echo "(e(0.2*l($END/$START))-1)*100" | bc -l  
# CAGR=$( echo "ret=(e(0.2*l($END/$START))-1)*100; scale=2; ret/1" | bc -l )
CAGR=$( echo "ret=(e(0.2*l($END/$START))-1)*100; scale=0; ret/1" | bc -l )
echo $CAGR%
