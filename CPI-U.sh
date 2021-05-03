# CPI-U rate is more tricky than it seems
# start with a table of data
CPI="CPI-U.csv"
curl -s -o $CPI 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCSL' 
LASTCPI=`tail -1 $CPI | cut -d, -f2`

# what was the date a year prior to the most recent entry?
LASTDATE=`tail -1 $CPI | cut -d, -f1`
YEAR=${LASTDATE%%-*}
REMAINDER=${LASTDATE#*-}
PRIORYEAR=$( echo "$YEAR - 1" | bc -l )
PRIORDATE="$PRIORYEAR-$REMAINDER"

# find what happened a year ago and calculate the RATE of inflation
PRIORCPI=`grep $PRIORDATE $CPI | cut -d, -f2`
echo "ret=($LASTCPI - $PRIORCPI)/$PRIORCPI * 100; scale=2; ret/1" | bc -l

