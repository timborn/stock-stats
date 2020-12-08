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
