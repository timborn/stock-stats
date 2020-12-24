# compute CAGR on 25+ years of dividends
#
# Given:
#
# $ ./25-yr-div-history.sh  BAC
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

START=$( ./25-yr-div-history.sh $SYM | cut -f 2 -d' ' | head -1 )
END=$( ./25-yr-div-history.sh $SYM | cut -f 2 -d' ' | tail -1 )
N=$( ./25-yr-div-history.sh $SYM | wc -l )

# gotta use natural logs to find the 1/Nth power
# echo "(e(0.2*l($END/$START))-1)*100" | bc -l  
# CAGR=$( echo "ret=(e(0.2*l($END/$START))-1)*100; scale=2; ret/1" | bc -l )
CAGR=$( echo "ret=(e((1/$N)*l($END/$START))-1)*100; scale=0; ret/1" | bc -l )
echo $CAGR% over $N years
