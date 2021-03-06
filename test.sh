#!/usr/bin/env bash
# self test stock-stats

source $HOME/bin/assert.sh

CACHE=$HOME/.stock-stats-cache

### will we populate the cache when it's not there?
# clear the cache
rm -rf $CACHE
stock-stats T > /dev/null
echo -n "populate cache correctly: "
[ -s $CACHE/T ] && echo PASS || echo FAIL 

### do we use the cache when available?
eval set `stat -s $CACHE/T`
BEFORE=$st_mtimespec
stock-stats T > /dev/null
eval set `stat -s $CACHE/T`
AFTER=$st_mtimespec
assert_eq $BEFORE $AFTER "FAIL: should uses cache when available"

### TODO: test error case - how to test when stock-stats-nocache not on path?

### expect usage when no arg presented
echo -n "usage msg when no args: "
stock-stats > /dev/null
[ $? -eq 2 ] && echo PASS || echo FAIL

### refill cache when data is old`
# warning: this depends on $CACHE/T exists and is current

eval set `stat -s $CACHE/T`
BEFORE=$st_mtimespec
touch -t 12042046 $CACHE/T
stock-stats > /dev/null
eval set `stat -s $CACHE/T`
AFTER=$st_mtimespec
assert_not_eq $BEFORE $AFTER "FAIL: should refill cache when too old"

# what a hack!
# eval set `stat -s $CACHE/T`
# $st_mtimespec

### expect specific output - probably won't change for a year
echo -n "5-yr-div-history.sh BAC: "
VAL=`./5-yr-div-history.sh BAC`
EXPECTED="2016 0.25
2017 0.39
2018 0.54
2019 0.66
2020 0.72"

# echo
# echo "DEBUG:      VAL="\'$VAL\'
# echo "DEBUG: EXPECTED="\'$EXPECTED\'
if [ "$VAL" = "$EXPECTED" ] ; then
	echo PASS
else
	echo FAIL
fi

# why doesn't this work?
# assert_eq "$VAL" "$EXPECTED" 


### expect specific output - probably won't change for a year
echo -n "25-yr-div-history.sh BAC: "
VAL=`./25-yr-div-history.sh BAC`
EXPECTED="2013 0.02
2014 0.12
2015 0.2
2016 0.25
2017 0.39
2018 0.54
2019 0.66
2020 0.54"

if [ "$VAL" = "$EXPECTED" ] ; then
	echo PASS
else
	echo FAIL
fi



### expect specific output - probably won't change for a year
echo -n "dividend-history3.sh BAC: "
VAL=`./dividend-history3.sh BAC`
EXPECTED="1986-06-02 0.0475
1986-08-29 0.0475
1986-12-01 0.0525
1987-03-02 0.0525
1987-06-01 0.0525
1987-08-31 0.0525
1987-11-30 0.0575
1988-02-29 0.0575
1988-05-27 0.0575
1988-08-29 0.0575
1988-11-28 0.0625
1989-02-27 0.0625
1989-05-26 0.0625
1989-08-28 0.075
1989-11-27 0.075
1990-02-26 0.0875
1990-05-25 0.0875
1990-08-31 0.0875
1990-12-03 0.0925
1991-03-04 0.0925
1991-06-03 0.0925
1991-08-30 0.0925
1991-12-02 0.0925
1992-03-02 0.0925
1992-06-01 0.0925
1992-08-31 0.0925
1992-11-30 0.1
1993-03-01 0.1
1993-05-28 0.1
1993-08-30 0.105
1993-11-29 0.105
1994-02-28 0.115
1994-05-27 0.115
1994-08-29 0.115
1994-11-28 0.125
1995-02-27 0.125
1995-05-26 0.125
1995-08-30 0.125
1995-11-29 0.145
1996-02-28 0.145
1996-06-05 0.145
1996-09-04 0.145
1996-12-04 0.165
1997-03-05 0.165
1997-06-04 0.165
1997-09-03 0.165
1997-12-03 0.19
1998-03-04 0.19
1998-06-03 0.19
1998-09-02 0.19
1998-12-02 0.225
1999-03-03 0.225
1999-06-02 0.225
1999-09-01 0.225
1999-12-01 0.25
2000-03-01 0.25
2000-05-31 0.25
2000-08-30 0.25
2000-11-29 0.28
2001-02-28 0.28
2001-05-30 0.28
2001-09-05 0.28
2001-12-05 0.3
2002-02-27 0.3
2002-06-05 0.3
2002-09-04 0.3
2002-12-04 0.32
2003-03-05 0.32
2003-06-04 0.32
2003-09-03 0.4
2003-12-03 0.4
2004-03-03 0.4
2004-06-02 0.4
2004-09-01 0.45
2004-12-01 0.45
2005-03-02 0.45
2005-06-01 0.45
2005-08-31 0.5
2005-11-30 0.5
2006-03-01 0.5
2006-05-31 0.5
2006-08-30 0.56
2006-11-29 0.56
2007-02-28 0.56
2007-05-30 0.56
2007-09-05 0.64
2007-12-05 0.64
2008-03-05 0.64
2008-06-04 0.64
2008-09-03 0.64
2008-12-03 0.32
2009-03-04 0.01
2009-06-03 0.01
2009-09-02 0.01
2009-12-02 0.01
2010-03-03 0.01
2010-06-02 0.01
2010-09-01 0.01
2010-12-01 0.01
2011-03-02 0.01
2011-06-01 0.01
2011-08-31 0.01
2011-11-30 0.01
2012-02-29 0.01
2012-05-30 0.01
2012-09-05 0.01
2012-12-05 0.01
2013-02-27 0.01
2013-06-05 0.01
2013-09-04 0.01
2013-12-04 0.01
2014-03-05 0.01
2014-06-20 0.01
2014-09-03 0.05
2014-12-03 0.05
2015-03-04 0.05
2015-06-03 0.05
2015-09-02 0.05
2015-12-02 0.05
2016-03-02 0.05
2016-06-01 0.05
2016-08-31 0.075
2016-11-30 0.075
2017-03-01 0.075
2017-05-31 0.075
2017-08-30 0.12
2017-11-30 0.12
2018-03-01 0.12
2018-05-31 0.12
2018-09-06 0.15
2018-12-06 0.15
2019-02-28 0.15
2019-06-06 0.15
2019-09-05 0.18
2019-12-05 0.18
2020-03-05 0.18
2020-06-04 0.18
2020-09-03 0.18
2020-12-03 0.18"

if [ "$VAL" = "$EXPECTED" ] ; then
	echo PASS
else
	echo FAIL
fi



