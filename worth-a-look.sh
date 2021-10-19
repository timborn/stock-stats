# capture recommendations.  runs out of crontab once a month

# pick up jq, node, stock-stats
PATH=$PATH:/usr/local/bin:~timborn/bin

cd `dirname $0`	# be there, aloha!

OFILE=`date "+worth-a-look.%y%m%d"`

# this sucks    TODO: fix this
HN=`hostname -s`
if [ $HN = "Timex-3" ] ; then
	/Users/timborn/python/stock-stats/recommend.sh > $OFILE
else
	/Volumes/BlueMountain/Users/timborn/bash/stock-stats/recommend.sh > $OFILE
fi
