Thu Dec 24 11:39:04 MST 2020
----------------------------
My search for dividend history has taken me to IEX (5 yrs), Polygon 
(variable, but it appears to be limiting me to just over 5 yrs).
I think we might be able to tickle Yahoo! finance for div history.

# I chose 'max' for the time period
https://query1.finance.yahoo.com/v7/finance/download/T?period1=438220800&period2=1608768000&interval=1d&events=div&includeAdjustedClose=true

Thu Dec 24 11:27:03 MST 2020
----------------------------

5-yr-div-cagr.sh --> 5-yr-div-history.sh --> dividend-history.sh
25-yr-div-cagr.sh --> 25-yr-div-history.sh --> dividend-history2.sh

A bit of a misnomer.  The "25 yr" div data is highly variable, 
but generally more than 5 years.

Wed Dec  9 11:39:33 MST 2020
----------------------------

I don't know why, but this stock doesn't render.  It appears to be in NASDAQ.
It shows up in finviz site, so I really don't see what the problem is here.
Removed from dividend-aristocrats.csv

R2D2:stock-stats timborn$ ./stock-stats CBSH
ERROR: unknown stock symbol:  CBSH
201210 - as of this morning CBSH is showing up.  No clue why

Ditto FMCB on OTC
ERROR: unknown stock symbol:  FMCB

-----

DONE: BUG: sometimes the cached file is EMPTY. How does this happen and how to recover?

-----

I translate single quotes to double quotes to make results JSON compliant, but in the process I 
ended up with things like this:

"People"s United Financial, Inc."
"Lowe"s Companies, Inc."

Oops!  How to fix this?

DONE: fix blind quoting to be "smarter"
