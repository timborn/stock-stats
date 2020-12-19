# NB set TOKEN before running
# SYM=MMM
CACHE=$HOME/.iex-cache
LOG=$CACHE/LOG

if [ $TOKEN"X" = "X" ] ; then
	echo "ERROR: set TOKEN before running $0" >&2
	exit 2
fi

# function arguments -> filename to compare against curr time
# return 0 if file too old (or doesn't exit)
# https://gist.github.com/ashrithr/5614283
function fileTooOld() {
  if [ ! -f $CACHE/$1 ]; then
    return 0
  fi

  # MAXAGE=$(bc <<< '90*24*60*60') # seconds in 90 days  # really stupid to calculate a constant
  MAXAGE=7776000	# 90 days

  # file age in seconds = current_time - file_modification_time.
  FILEAGE=$(($(date +%s) - $(stat -f '%m' "$1")))
  test $FILEAGE -lt $MAXAGE && {
    return 1
  }
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

