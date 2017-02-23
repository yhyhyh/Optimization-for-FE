function  multi_period_hw2

load hw2.mat; 
n = size(Price,2);
% n = number of risky assets
e = ones(n,1);	

%%%%%%%%%%%%%%%
%%%% PARAMETERS
%%%% (the following choices of parameters can easily be changed)

horizon = 4; % rebalance monthly (every 4 weeks)
start = 400; % the week in which you are first given a portfolio to rebalance
number_rebalances = 100; % the number of times the portfolio will be rebalanced 

number_of_samples = 100; % how many samples are to be used 
						% in computing return avereages and covariances
sample_frequency = 2; % 1 = weekly, 2 = biweekly, etc.
						
r_w_f_o_y_e = .4; % "relative weight for one year earlier" 
				   % -- a value .4 means that for the (exponential) weights 
				    % used in computing return averages and covariances, 
				     % the weight assigned to the time period one year ago
				      % should be .4 times the weight assigned 
				       % to the most recent period.    	 

allowable_risk = 1;
	% This is the level of risk relative to the benchmark portfolio,
	%   where risk is measured as standard deviation of portfolio returns.
	% Choosing this value to equal 1 means exactly the same amount of risk is allowed,
	% whereas choosing 2 means twice as much risk is allowed as the benchmark, and so on.
							
trans_cost = .005;  % transaction cost
	
wealth = 10000; % initial wealth measured in dollars, including money invested in assets
			   % (one dollar invested in an asset is considered as one dollar of wealth,
			   %  even though in liquidating the asset, transaction costs would be paid)	
			   
x0 = .3; % proportion of wealth in bank initially
x = (.7/n)*e; % proportions in risky assets initially

benchmark_x0 = x0;  
benchmark_x = x; % initial proportions for benchmark portfolio	
				 % Note that the initial benchmark portfolio is not equally balanced,
				 %   and thus needs to be rebalanced.
									
%%%% END OF PARAMETERS	
%%%%%%%%%%%%%%%%%%%%%%

rate_of_decay = 1 - r_w_f_o_y_e^(sample_frequency/52);

initial_wealth = wealth
benchmark_wealth = wealth;	

rebalance_dates = start + horizon*(0:number_rebalances-1);

for i = 1:length(rebalance_dates)

	trade_date = rebalance_dates(i);
		
    %%%%% REBALANCE PORTFOLIO AND PAY TRANSACTION COSTS %%%%%%
		
    [mu,V] = adapted_stats(Price,trade_date, ...
    		horizon,sample_frequency,number_of_samples,rate_of_decay);
    mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;
    
    benchmark_risk = sqrt(e'*V*e)/(n+1); % there are n+1 financial instruments
    								     % including the bank		
    sigma = allowable_risk*benchmark_risk; 
    
    xx0 = x0;
    xx = x;
    [x0,x] =  cvx_markowitz2_2(mu0,mu,V,sigma,xx0,xx,trans_cost);
    
    wealth = wealth*(x0 + sum(x));
    	% This is the same thing as updating your wealth by subtracting
    	% all transaction costs from the rebalancing.  Indeed, in rebalancing,
    	% the proportion of your wealth going to trans costs is 1 - x0 - sum(x).  
    	
    total = x0 + sum(x);	
    x0 = x0/total;
    x = x/total;
    	% Rescaling x0 and x so that the sum is 1 (i.e., proportions of current wealth)
    	
    benchmark_wealth = benchmark_wealth*(1- trans_cost * sum(abs(benchmark_x-ones(n,1)/(n+1))));
    	% Update benchmark_wealth by subtracting transaction costs required
    	% for rebalancing to an equal weight portfolio (10% in bank and 10%
    	% in each ETF). Think of the benchmark portfolio having now been
    	% rebalanced to be equally weighted.
    	
    %%%%%% PROCEED TO END OF TIME PERIOD AND ACCOUNT FOR GAINS, LOSSES %%%%%	
    	  
    returns = (Price(trade_date+horizon-1,:)-Price(trade_date-1,:))./Price(trade_date-1,:);
    	% vector of actual returns for risky assets (this is a row vector)	
    
    multiplier = 1 + mu0*x0 + returns*x;	
    wealth = multiplier*wealth
        	% by leaving off the semicolon, you can watch how wealth changes as the program runs

    if wealth<=0
     break; % stops the program if bankruptcy occurs
     		% Not needed for benchmark portfolio (because it is long only)
    end
    
    x0 = (1+mu0)*x0/multiplier;
    x = x.*(1+returns)'/multiplier;
    % these are the proportions of current wealth invested in assets
    
    benchmark_multiplier = 1 + (mu0 + sum(returns))/(n+1);
    benchmark_wealth = benchmark_multiplier*benchmark_wealth;
    
    benchmark_x0 = ((1 + mu0)/(n+1)) / benchmark_multiplier;
    benchmark_x = ((1 + returns')/(n+1))/ benchmark_multiplier;
    	% At the beginning of the time period, the benchmark portfolio was
    	% rebalanced to have 10% of wealth in the bank and each ETF. 
    	% At the end of the period, the portfolio is no longer equally balanced.
    	% What proportion of wealth now is in the bank, and in each ETF?
   
end

fprintf('your final bank account %f\n');
x0
fprintf('your final risky portfolio %f\n');
x

fprintf('your final wealth %f\n',wealth);
fprintf('benchmark final wealth %f\n', benchmark_wealth);

fprintf('your annualized rate of return %f\n', (wealth/initial_wealth)^(52/(horizon*number_rebalances))-1);
fprintf('benchmark annualized rate of return %f\n', (benchmark_wealth/initial_wealth)^(52/(horizon*number_rebalances))-1);

