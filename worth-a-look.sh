# capture recommendations.  runs out of crontab once a month

cd `dirname $0`	# be there, aloha!

OFILE=`date "+worth-a-look.%y%m%d"`
/Volumes/BlueMountain/Users/timborn/bash/stock-stats/recommend.sh > $OFILE
