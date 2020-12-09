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
