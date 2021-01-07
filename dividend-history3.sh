# historical dividends from Yahoo! finance
# https://query1.finance.yahoo.com/v7/finance/download/T?period1=438220800&period2=1608768000&interval=1d&events=div&includeAdjustedClose=true

SYM=$1
CACHE=$HOME/.yahoo-cache
LOG=$CACHE/LOG
OFILE=$CACHE/$SYM

# returns 0 if file does not exist or is too old (needs to be cached), otherwise 1 (fail)
function fileTooOld() {
  if [ ! -f $CACHE/$1 ]; then
    [ $DEBUG ] && echo "fileTooOld($1) not in cache, returning 0 (too old, refresh cache)"
    return 0
  fi

  # MAXAGE=$(bc <<< '90*24*60*60') # seconds in 90 days  # really stupid to calculate a constant
  MAXAGE=7776000	# 90 days

  # file age in seconds = current_time - file_modification_time.
  FILEAGE=$(($(date +%s) - $(stat -f '%m' "$CACHE/$1")))
  test $FILEAGE -lt $MAXAGE && {
    [ $DEBUG ] && echo FILEAGE=$FILEAGE
    [ $DEBUG ] && echo MAXAGE=$MAXAGE
    [ $DEBUG ] && echo "DEBUG: we believe $SYM is LESS THAN max age (remember: fileTooOld, therefore we return 1 --> false/fail)"
    return 1
  }

  [ $DEBUG ] && "fileTooOld falling off the bottom, returning 0 (success/fill cache)"
  return 0
}

###
### main
###

if [ $# -ne 1 ] ; then 
	echo "USAGE: $0 <stockSymbol>" >&2
	exit 3
fi

[ -d $CACHE ] || mkdir -p $CACHE

fileTooOld $SYM 
RETVAL=$?

RETVAL=0   # DEBUG

if [ $RETVAL -eq 0 ] ; then 
	# cache it
	# RETVAL=$( curl -s -o $CACHE/$SYM -w "%{http_code}" https://cloud.iexapis.com/stable/stock/$SYM/dividends/5y?token=$TOKEN )
	# gotta be careful with those amperstands
	# URL="https://query1.finance.yahoo.com/v7/finance/download/$SYM?period1=438220800\\&period2=1608768000\\&interval=1d\\&events=div\\&includeAdjustedClose=true" 
	URL="https://query1.finance.yahoo.com/v7/finance/download/$SYM?period1=438220800&period2=1608768000&interval=1d&events=div&includeAdjustedClose=true" 
# echo DEBUG: URL=$URL
# exit 	# DEBUG
	RETVAL=$( curl -s -o $OFILE -w "%{http_code}" $URL )
	
	if [ "$RETVAL" = "200" ]; then 
		echo "OK $SYM `date '+%y%m%d%H%M'`" >> $LOG
		cat $CACHE/$SYM | 
			tail -n +2 |	# get rid of column headers
			sed -e's/,/ /'
	else
		echo "FAIL($RETVAL) $SYM `date '+%y%m%d%H%M'`" >> $LOG
		exit $RETVAL
	fi

else
	# just dump it
	echo "CACHE-HIT $SYM `date '+%y%m%d%H%M'`" >> $LOG
	cat $CACHE/$SYM |
		tail -n +2 |	# get rid of the column headers
		sed -e's/,/ /'
fi 


