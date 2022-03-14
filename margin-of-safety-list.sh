# given a file with stock ticker symbols, one per line
# calculate the Margin of Safety (per Ben Graham) and deliver the sorted list, best to worst

# I edited this input file by hand
INFILE=worth-a-look.220313
TMP=`mktemp` || exit 1

for i in  `cat $INFILE`; do  
	# MOS=$(./advise.sh $i |grep 'Margin of Safety')
	MOS=$(./margin-of-safety.sh $i |grep 'Margin of Safety')
	echo $i, $MOS
done > $TMP


while read -r line; do 
	MOS=$( echo $line | cut -d' ' -f 6 )
	SYM=$( echo $line | cut -d' ' -f 1 ) 
	echo $MOS, $SYM
done < $TMP | sort -nr
