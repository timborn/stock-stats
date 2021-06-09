# capture recommendations.  runs out of crontab once a month

# pick up jq, node, stock-stats
PATH=$PATH:/usr/local/bin:~timborn/bin

cd `dirname $0`	# be there, aloha!

OFILE=`date "+worth-a-look.%y%m%d"`
/Volumes/BlueMountain/Users/timborn/bash/stock-stats/recommend.sh > $OFILE
