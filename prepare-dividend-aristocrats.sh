# prepare-dividend-aristocrats.sh
set -e

# NB official site for dividend aristorcrats: 
#    https://www.spglobal.com/spdji/en/indices/strategy/sp-500-dividend-aristocrats/#overview
# NB Motley Fool list also includes kings; just not a CSV
#    https://www.fool.com/investing/stock-market/types-of-stocks/dividend-stocks/dividend-aristocrats/

# get the raw dividend aristocrat data
# pull out noise
# pull out fields we care about 
# what to do about kings vs aristocrats?
# report differences, especilly DROPPED and ADDED stocks

FN1=`mktemp`
FN2=`mktemp`
TARGET=dividend-aristocrats.csv

# -L - follow redirects
curl -sO -L http://www.simplysafedividends.com/intelligent-income/idea_lists/3-dividend-aristocrats.csv
FN=3-dividend-aristocrats.csv
cat $FN | grep -v ^Tick | cut -f1 -d, | sed -e'1,$s/$/, aristocrat/' > $FN1

# get the KINGS
curl -sO -L http://www.simplysafedividends.com/intelligent-income/idea_lists/4-dividend-kings.csv
FN=4-dividend-kings.csv

# at this point we will be using grep results, so we need to NOT bomb on an error
set +e

for i in `tail -n +2 $FN | cut -f1 -d, `; do 
	# if king is already in aristo list, upgrade it
	# else add king to the list
	grep -q "$i," $FN1 > /dev/null 2>&1	# returns 0 on match
	if [ $? -eq 0 ] ; then 
		sed -i -e "1,\$s/$i, aristocrat/$i, king/" $FN1
	else
		echo "$i, king" >> $FN1
	fi
done


sort $FN1 > $TARGET

# cleanup
rm $FN1 $FN2
