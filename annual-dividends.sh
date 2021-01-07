# shows 25+ year dividend history for a stock
# defaults to using dividend-history2.sh (Polygon)
# but if I get the opts working, we should be able 
# to choose to use yahoo data

# DONE: BUG! In December 2020, WMT was already showing a dividend 
# scheduled for 2021, which means we got MORE than 5 yrs and the end 
# value was only a partial year, screwing up the CAGR calculations.  
# --> This is a stinky hack, ignoring 2021.  
# At some point I will need/want 2021 (4Q21?)
#
# DONE: BUG! The order things are printed matters, and awk 
# associative arrays don't care about order

function print_usage {
	echo "USAGE: $0 [--iex|--polygon|--yahoo] <stockSymbol>" >&2
}

# very nifty bit of code!
# https://stackoverflow.com/questions/12022592/how-can-i-use-long-options-with-the-bash-getopts-builtin

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--yahoo")   set -- "$@" "-y" ;;
    "--polygon") set -- "$@" "-p" ;;
    "--iex")     set -- "$@" "-i" ;;
    *)           set -- "$@" "$arg"
  esac
done

# default behavior
SRC="25-yr-div-history.sh"   # polygon

# Parse short options
OPTIND=1
while getopts "ipy" opt
do
  case "$opt" in
    "i") SRC="5-yr-div-history.sh" ;;
    "p") SRC="25-yr-div-history.sh" ;;
    "y") SRC="dividend-history3.sh" ;;
    "?") print_usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

### end-nifty


SYM=$1
if [ $# -ne 1 ] ; then 
	print_usage
	exit 3
fi


# ./dividend-history2.sh  $SYM |  
./$SRC $SYM |
sed -e's/-[0-9][0-9]-[0-9][0-9]//' |  
awk '{a[$1] += $2} END{ delete a[2021]; for (i in a) print i, a[i] }' |
sort
# jq '.results[] | { paymentDate: .paymentDate, amount: .amount } ' |  
# jq -sc |  
# in2csv -f json  | 
# tail -n +2 |
# awk -F ',' '{a[$1] += $2} END{print 2016, a[2016]; print 2017, a[2017]; print 2018, a[2018]; print 2019, a[2019]; print 2020, a[2020] }'

