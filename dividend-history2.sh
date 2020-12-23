# NB set TOKEN before running
# SYM=MMM
# DEBUG=1		# when DEBUG is unset, it is turned off
CACHE=$HOME/.iex-cache
LOG=$CACHE/LOG

# historical-dividends.sh produces a (potentially) deeper list of div history
# cat AAPL-dh.json |jq '.results[] | { amount: .amount, paymentDate: .paymentDate}' | jq -sc | in2csv -f json

if [ $TOKEN"X" = "X" ] ; then
	echo "ERROR: set TOKEN before running $0" >&2
	exit 2
fi

# function arguments -> filename to compare against curr time
# return 0 if file too old (or doesn't exit)
# https://gist.github.com/ashrithr/5614283
function fileTooOld() {
  [ $DEBUG ] && echo "fileTooOld entry ..."

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
  [ $DEBUG ] && "fileTooOld falling off the bottom, returning 0 (true/success)"
  return 0
}

###
### main
###

SYM=$1
if [ $# -ne 1 ] ; then 
	echo "USAGE: $0 <stockSymbol>" >&2
	exit 3
fi
[ -d $CACHE ] || mkdir -p $CACHE

fileTooOld $SYM 
RETVAL=$?

# [ $DEBUG ] && echo "fileTooOld returned $RETVAL.  Forcing to 1." ; RETVAL=1
[ $DEBUG ] && echo "fileTooOld returned $RETVAL." 

if [ $RETVAL -eq 0 ] ; then 
	# cache it
	RETVAL=$( curl -s -o $CACHE/$SYM -w "%{http_code}" https://cloud.iexapis.com/stable/stock/$SYM/dividends/5y?token=$TOKEN )
	
	if [ "$RETVAL" = "200" ]; then 
		echo "OK $SYM `date '+%y%m%d%H%M'`" >> $LOG
		cat $CACHE/$SYM
	else
		echo "FAIL($RETVAL) $SYM `date '+%y%m%d%H%M'`" >> $LOG
		exit $RETVAL
	fi

else
	# just dump it
	echo "CACHE-HIT $SYM `date '+%y%m%d%H%M'`" >> $LOG
	cat $CACHE/$SYM
fi 

