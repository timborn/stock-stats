Wed Dec  9 11:39:33 MST 2020
----------------------------

I don't know why, but this stock doesn't render.  It appears to be in NASDAQ.
It shows up in finviz site, so I really don't see what the problem is here.
Removed from dividend-aristocrats.csv

R2D2:stock-stats timborn$ ./stock-stats CBSH
ERROR: unknown stock symbol:  CBSH

Ditto FMCB on OTC
-----

DONE: BUG: sometimes the cached file is EMPTY. How does this happen and how to recover?

-----

I translate single quotes to double quotes to make results JSON compliant, but in the process I 
ended up with things like this:

"People"s United Financial, Inc."
"Lowe"s Companies, Inc."

Oops!  How to fix this?

DONE: fix blind quoting to be "smarter"
