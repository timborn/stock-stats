#
# TODO: cache these!

if [ "$POLYGONTOKEN"X = "X" ] ; then
	echo "ERROR: you must set POLYGONTOKEN before using $0"
	exit 2
fi

SYM=$1
CACHE=$HOME/.polygon-cache
LOG=$CACHE/LOG
OFILE=$CACHE/$SYM

# returns 0 if file does not exist or is too old (needs to be cached), otherwise 1 (fail)
function fileTooOld() {
  if [ ! -f $CACHE/$1 ]; then
    [ $DEBUG ] && echo "fileTooOld($1) not in cache, returning 0 (too old, refresh cache)"
    return 0
  fi

  # for our purposes I don't care about the age of these files
  # so if it's in the cache, let's use it
  return 1

#   # MAXAGE=$(bc <<< '90*24*60*60') # seconds in 90 days  # really stupid to calculate a constant
#   MAXAGE=7776000	# 90 days
# 
#   # file age in seconds = current_time - file_modification_time.
#   FILEAGE=$(($(date +%s) - $(stat -f '%m' "$CACHE/$1")))
#   test $FILEAGE -lt $MAXAGE && {
#     [ $DEBUG ] && echo FILEAGE=$FILEAGE
#     [ $DEBUG ] && echo MAXAGE=$MAXAGE
#     [ $DEBUG ] && echo "DEBUG: we believe $SYM is LESS THAN max age (remember: fileTooOld, therefore we return 1 --> false/fail)"
#     return 1
#   }
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

if [ $RETVAL -eq 0 ] ; then 
	# cache it
	# RETVAL=$( curl -s -o $CACHE/$SYM -w "%{http_code}" https://cloud.iexapis.com/stable/stock/$SYM/dividends/5y?token=$TOKEN )
	RETVAL=$( curl -s -o $OFILE -w "%{http_code}" https://api.polygon.io/v2/reference/dividends/$SYM?apiKey=$POLYGONTOKEN )
	
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


