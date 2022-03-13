#!/usr/bin/env bash
# use caching for 10 yr treasury yields 
# avoid pounding yahoo.com for (essentially) a constant
# and work correctly on weekends when "most recent day" returns 404


SYM="^TNX"
CACHE=$HOME/.yahoo
LOG=$CACHE/LOG
OFILE=$CACHE/$SYM
TMP=`mktemp` || exit 1

# returns 0 if file does not exist or is too old (needs to be cached), 
# otherwise 1 (fail)
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

[ -d $CACHE ] || mkdir -p $CACHE

fileTooOld $SYM 
RETVAL=$?

if [ $RETVAL -eq 0 ] ; then 
	# cache it
	RETVAL=$( curl -s -o $TMP -w "%{http_code}" 'https://query1.finance.yahoo.com/v7/finance/download/%5ETNX?interval=1d&events=history&includeAdjustedClose=true' )

	if [ "$RETVAL" = "200" ]; then 
		echo "OK $SYM `date '+%y%m%d%H%M'`" >> $LOG
		tail -1 $TMP | cut -d, -f5 > $CACHE/$SYM
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

rm $TMP 2>/dev/null || :
