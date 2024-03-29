# stock-stats
command line manipulation of stock data; JSON; caching

I wanted a way to generate stock data in JSON via the command line without annoying the data provider, 
so I added caching.  The resulting stream can then be massaged using e.g. jq.

Leveraging finviz website, finviz python module and a bit of python.

## To Install (mac):
- brew install python3
- pip3 install finviz

## Examples
$ stock-stats T | jq .

# extra a subset and augment, using a variable for the stock symbol
$ SYM=T
$ stock-stats $SYM | jq '{ symbol: "'$SYM'", price: .Price, dividend: .Dividend, dividendPct: ."Dividend %" }' 2>/dev/null
{
  "symbol": "T",
  "price": "30.81",
  "dividend": "2.08",
  "dividendPct": "6.75%"
}

$ ./aristo.sh | ./filter-out-losses | ./sort-by-targetGain  

# which aristocrats are selling at or below past years price range midpoint?
$ ./aristo.sh | ./filter-out-over-midprice  | jq -c

# which sectors are in the aristocrat list?
$ ./sectors.sh

# aristcrats selling at or below midPrice, sorted by dividendPct, highest first
$ ./sort-by-dividendPct.sh 

# want to slice & dice in LibreCalc?
# (that middle step turns it into one large well-formed json for in2csv to parse)
$ aristo.sh | jq -sc | in2csv -f json > arisocrats.csv

# let's look at 5 yrs of dividend history for a stock in LibreCalc
$ ./dividend-history.sh  BAC | jq '.[] | { paymentDate: .paymentDate, amount: .amount } ' | jq -sc | in2csv -f json > BAC.csv

# look more widely across S&P 1500 high yield dividends w/ at least 20 yrs of div growth
./SDY.sh
