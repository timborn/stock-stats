# a composition for someone who really wants solid dividend stocks:
# start with dividend aristocrats (long history of dividend growth)
# toss any where analysts are predicting a future price below 
#   current price (negative growth expectations)
# toss any that are 'too expensive'
# toss any that have unsustainable payout ratios
# sort by top dividend producers

./aristo.sh | ./filter-out-losses | ./filter-out-over-midprice  | ./filter-out-payout | ./sort-by-dividendPct.sh
