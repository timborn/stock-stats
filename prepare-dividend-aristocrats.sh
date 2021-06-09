# prepare-dividend-aristocrats.sh
set -e

# TODO: where did I get the dividend king list from?  This is not updated by this script.  Fix that.
# TODO: almost certainly some of the aristocrats also show up as kings.  Double entries in list.  Fix
# TODO: is a king not an aristocrat?  If they select from different domains it may be possible,
#       in which case the logic is flawed.  As written it assumes all kings are also aristocrats.
# NB official site for dividend aristorcrats: 
#    https://www.spglobal.com/spdji/en/indices/strategy/sp-500-dividend-aristocrats/#overview
# NB Motley Fool list also includes kings; just not a CSV
#    https://www.fool.com/investing/stock-market/types-of-stocks/dividend-stocks/dividend-aristocrats/

# get the raw dividend aristocrat data
# pull out noise
# pull out fields we care about 
# what to do about kings vs aristocrats?
# report differences, especilly DROPPED and ADDED stocks

FN=3-dividend-aristocrats.csv
FN1=`mktemp`
FN2=`mktemp`
# DO NOT OVERWRITE dividend-aristocrats.csv WHILE TESTING
# TARGET=dividend-aristocrats.csv
TARGET=TEST-dividend-aristocrats.csv

# -L - follow redirects
curl -sO -L http://www.simplysafedividends.com/intelligent-income/idea_lists/3-dividend-aristocrats.csv
cat $FN | grep -v ^Tick | cut -f1 -d, | sed -e'1,$s/$/, aristocrat/' > $FN1
grep -i king $TARGET | cut -f1 -d, > $FN2
for i in `cat $FN2`; do 
	echo "DEBUG: considering king $i"
	sed -i -e "1,\$s/$i, aristocrat/$i, king/" $FN1
done


sort $FN1 > $TARGET

# cleanup
echo rm $FN1 $FN2
