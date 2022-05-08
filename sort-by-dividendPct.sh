#!/usr/bin/env bash
# aristocrats
# - selling at or below midPrice from past year
# - sorted by dividendPct (highest first)

# ./aristo.sh | ./filter-out-over-midprice |
jq -s 'sort_by(.dividendPct) | reverse' | 
# because we used -s (slurp?) above, we have to unpack the array returned
jq -c '.[]' 
