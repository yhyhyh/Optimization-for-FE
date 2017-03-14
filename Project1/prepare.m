n = 9;
scenario = xlsread('scenario.xlsx');
latest_price = xlsread('option_price.xlsx');
option_strike = latest_price(n+1);
volatility = latest_price(n+2);
latest_price = latest_price(1:n);

