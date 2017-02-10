% read data
Prices = xlsread('weekly_spdr.xlsx','price','','');
Prices = Prices(:,2:end);
% parameter initialization
trade_date = 850; frequency = 4; num_samples = 175; rate_of_decay = 0.001;
[mu,V] = stats(Prices, trade_date, frequency, num_samples, rate_of_decay);
M = [-2*V,mu,ones(9,1); mu',0,0; ones(1,9),0,0];
M_1 = inv(M);
u = M_1(1:end-2, end-1);
v = M_1(1:end-2, end);
alpha = u'*V*u;
beta = 2*u'*V*v;
gamma = v'*V*v;
min_x = -beta/(2*alpha)
min_y = gamma-(beta^2)/(4*alpha)
x_dim = 0:0.0001:0.03;
y_dim = alpha.*(x_dim.^2)+beta.*x_dim+gamma;
y_dim(find(x_dim<min_x)) = min_y;
plot(x_dim,y_dim);