#!/usr/bin/env bash
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




# TODO: test error case - how to test when stock-stats-nocache not on path?

### expect usage when no arg presented
echo -n "usage msg when no args: "
stock-stats > /dev/null
[ $? -eq 2 ] && echo PASS || echo FAIL

# TODO: test that cache is refilled when data is old
# touch -t 12042046 /Users/timborn/.stock-stats-cache/T

# what a hack!
# eval set `stat -s $CACHE/T`
# $st_mtimespec
