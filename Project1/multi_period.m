function  multi_period

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

    initial_wealth = wealth;
    benchmark_wealth = wealth;	

    rebalance_dates = start + horizon*(0:number_rebalances-1);

    hist_cvar = zeros(1,length(rebalance_dates));
    hist_benchmark = zeros(1,length(rebalance_dates));
    hist_mvo = zeros(1,length(rebalance_dates));
    

    for i = 1:length(rebalance_dates)

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        nearest = floor(trade_date/50)*50;
        strcat(num2str(nearest),'.csv')
        scenario = csvread(strcat(num2str(nearest),'.csv'),1,1);
        mu = sum(scenario)/size(scenario,1);

        xx0 = x0;
        xx = x;
        [x0,x] = optimize_cvar(mu0,mu,V,xx0,xx,trans_cost,0);
        wealth = wealth*(x0 + sum(x));

        total = x0 + sum(x);	
        x0 = x0/total;
        x = x/total;

        benchmark_wealth = benchmark_wealth*(1- trans_cost * sum(abs(benchmark_x-ones(n,1)/(n+1))));

        hist_cvar(i) = wealth;
        hist_benchmark(i) = benchmark_wealth;

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
    
    fprintf('your cvar wealth %f\n',wealth);
    
    wealth = 10000;
    x0 = .3;
    x = (.7/n)*e;
    
    
    for i = 1:length(rebalance_dates)

        trade_date = rebalance_dates(i);

        [mu,V] = adapted_stats(Price,trade_date, ...
                horizon,sample_frequency,number_of_samples,rate_of_decay);
        mu0 = (1+.01*risk_free_rate(trade_date-1))^(horizon/52) - 1;

        benchmark_risk = sqrt(e'*V*e)/(n+1);
        sigma = allowable_risk*benchmark_risk; 

        xx0 = x0;
        xx = x;
        [x0,x] =  cvx_markowitz(mu0,mu,V,sigma,xx0,xx,trans_cost);

        wealth = wealth*(x0 + sum(x));

        total = x0 + sum(x);	
        x0 = x0/total;
        x = x/total;

        returns = (Price(trade_date+horizon-1,:)-Price(trade_date-1,:))./Price(trade_date-1,:);

        multiplier = 1 + mu0*x0 + returns*x;	
        wealth = multiplier*wealth;
        hist_mvo(i) = wealth;

        if wealth<=0
            break;
        end

        x0 = (1+mu0)*x0/multiplier;
        x = x.*(1+returns)'/multiplier;

    end

    fprintf('your mvo wealth %f\n',wealth);
    fprintf('benchmark final wealth %f\n', benchmark_wealth);

    plot(hist_cvar);
    hold on
    plot(hist_benchmark);
    hold on
    plot(hist_mvo);
    
    std(price2ret(hist_cvar))
    std(price2ret(hist_benchmark))
    std(price2ret(hist_mvo))

end
