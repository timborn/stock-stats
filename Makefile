default:
	@echo pick your target
	@echo install
	@echo test

install:
	@pip3 install yfinance
	@cp stock-stats stock-stats-nocache ${HOME}/bin/.
	@[ ! -e ${HOME}/bin/assert.sh ] && ( mkdir -p ${HOME}/bash; cd ${HOME/bash}; git clone git@github.com:torokmark/assert.sh.git; cp assert.sh/assert.sh ${HOME}/bin ) || :
	@type brew >/dev/null 2>&1 || { echo you want to install brew; exit 1; }
	@type jq   >/dev/null 2>&1 || brew install jq
	@type in2csv >/dev/null 2>&1 || brew install csvkit
	@npm install mississippi xml2json
test:
	./test.sh

refresh:
	# refresh all the data we depend on 
	curl -sO https://www.realitysharesadvisors.com/charts/data/DIVCON/divcontable.csv
	./prepare-dividend-artistocrats.sh

# QDIV - S&P500 Quality Div Index (ETF)
# update QDIV.txt periodically with the list of shares held by this fund
# https://screener.fidelity.com/ftgw/etf/goto/snapshot/portfolioComposition.jhtml?symbols=QDIV
QDIV:
	@echo "QDIV is the S&P500 Quality Dividend Index"
	./aristo.sh QDIV.txt | ./filter-out-losses | ./filter-out-over-midprice  | ./filter-out-payout | jq -s 'sort_by(.dividendPct) | reverse' |  jq -c '.[]' 
