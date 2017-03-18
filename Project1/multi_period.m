function  multi_period_hw2

load hw2.mat; 
n = size(Price,2);
e = ones(n,1);	

horizon = 4;
start = 400;
number_rebalances = 100;

number_of_samples = 100;
sample_frequency = 2;
r_w_f_o_y_e = .4;
allowable_risk = 1;
			
trans_cost = .005;
wealth = 10000;
x0 = .3;
x = (.7/n)*e;

benchmark_x0 = x0;  
benchmark_x = x; 

rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);

initial_wealth = wealth
benchmark_wealth = wealth;	

rebalance_dates = start + horizon*(0:number_rebalances-1);

for i = 1:1

	trade_date = rebalance_dates(i);
		
    [mu,V] = adapted_stats(Price,trade_date, ...
    		horizon,sample_frequency,number_of_samples,rate_of_decay);
    mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;
    
% :::::::::: ::::    ::: ::::::::::: :::::::::: :::::::::   ::::::::::: :::::::::: :::    ::: :::::::::::  :::    ::: :::::::::: :::::::::  :::::::::: ::: 
% :+:        :+:+:   :+:     :+:     :+:        :+:    :+:      :+:     :+:        :+:    :+:     :+:      :+:    :+: :+:        :+:    :+: :+:        :+: 
% +:+        :+:+:+  +:+     +:+     +:+        +:+    +:+      +:+     +:+         +:+  +:+      +:+      +:+    +:+ +:+        +:+    +:+ +:+        +:+ 
% +#++:++#   +#+ +:+ +#+     +#+     +#++:++#   +#++:++#:       +#+     +#++:++#     +#++:+       +#+      +#++:++#++ +#++:++#   +#++:++#:  +#++:++#   +#+ 
% +#+        +#+  +#+#+#     +#+     +#+        +#+    +#+      +#+     +#+         +#+  +#+      +#+      +#+    +#+ +#+        +#+    +#+ +#+        +#+ 
% #+#        #+#   #+#+#     #+#     #+#        #+#    #+#      #+#     #+#        #+#    #+#     #+#      #+#    #+# #+#        #+#    #+# #+#            
% ########## ###    ####     ###     ########## ###    ###      ###     ########## ###    ###     ###      ###    ### ########## ###    ### ########## ### 
    
    scenario = xlsread('scenario.xlsx');
    mu = sum(scenario)/size(scenario,1);
    
    benchmark_risk = sqrt(e'*V*e)/(n+1);	
    sigma = allowable_risk*benchmark_risk; 
    
    xx0 = x0;
    xx = x;
    [x0,x] = optimize_cvar(mu0,mu,V,sigma,xx0,xx,trans_cost);
    wealth = wealth*(x0 + sum(x));
    	
    total = x0 + sum(x);	
    x0 = x0/total;
    x = x/total;
    	
    benchmark_wealth = benchmark_wealth*(1- trans_cost * sum(abs(benchmark_x-ones(n,1)/(n+1))));
    	  
    returns = (Price(trade_date+horizon-1,:)-Price(trade_date-1,:))./Price(trade_date-1,:);
    
    multiplier = 1 + mu0*x0 + returns*x;	
    wealth = multiplier*wealth;

    if wealth<=0
        break;
    end
    
    x0 = (1+mu0)*x0/multiplier;
    x = x.*(1+returns)'/multiplier;
    
    benchmark_multiplier = 1 + (mu0 + sum(returns))/(n+1);
    benchmark_wealth = benchmark_multiplier*benchmark_wealth;
    
    benchmark_x0 = ((1 + mu0)/(n+1)) / benchmark_multiplier;
    benchmark_x = ((1 + returns')/(n+1))/ benchmark_multiplier;
   
end

fprintf('your final bank account %f\n');
x0
fprintf('your final risky portfolio %f\n');
x

fprintf('your final wealth %f\n',wealth);
fprintf('benchmark final wealth %f\n', benchmark_wealth);

fprintf('your annualized rate of return %f\n', (wealth/initial_wealth)^(52/(horizon*number_rebalances))-1);
fprintf('benchmark annualized rate of return %f\n', (benchmark_wealth/initial_wealth)^(52/(horizon*number_rebalances))-1);

