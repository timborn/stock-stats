# 10 year treasure yield, most recent close
curl -s 'https://query1.finance.yahoo.com/v7/finance/download/%5ETNX?interval=1d&events=history&includeAdjustedClose=true' | tail -1 | cut -d, -f5 
