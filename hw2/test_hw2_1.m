function test_hw2_1

trade_date = 400;
frequency = 5;
num_samples = 60;
rate_of_decay = .0125;
sigma = .0464;
trans_cost = .005;
xx0 = .1;
xx = .1*ones(9,1);

load hw2.mat

[mu,V] = stats(Price,trade_date,frequency,num_samples,rate_of_decay);

mu0 = (1 + risk_free_rate(trade_date)/100)^(frequency/52) - 1

[x0,x] = cvx_markowitz2_1(mu0,mu,V,sigma,xx0,xx,trans_cost);

disp('Your answer is:')
bank = x0
risky_assets = x

z0 =  0.2428;
z = [0.5000; 0.3893; 0.5000; -0.3123; -0.5000; -0.5000; 0.4543; 0.0623; 0.1479];
disp('Our answer is:')
bank = z0
risky_assets = z
