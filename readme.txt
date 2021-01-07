Thu Jan  7 07:08:39 MST 2021
----------------------------
I had a google sheet that extracted data from e.g. https://finviz.com/quote.ashx?t=ABBV 
They changed the layout of the website (it moved from table 9 to table 8) but it was 
broken more than it worked.  GSheets seemed to be constantly refreshing (slow!) so the 
site must have been getting bombarded.

I found that LibreCalc allows you to import data from an external source, including a URL.
When presented with that site, I got a list of the tables to pick from.  Quick & easy.


Started working on external-data-experiment.ods.  This imports the data, but not I'm extending
it programatically using macros (functions and subroutines).  If I can figure out a few 
things, setting up a large spreadsheet and making massive changes will become tractable.

LibreCalc appears to be set to *offer* to refresh when I open the sheet, so the number
of refreshes will go way down.



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
