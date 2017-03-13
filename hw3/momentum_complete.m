function momentum_complete(trade_date)
%  Applies Black-Litterman similarly to slides 19 and 20,
%    but in the context of a very naive momentum strategy.
%  At the end of the run, you will see a matrix with two columns,
%    the first of which is the sample returns (named hat_mu), and
%    the second of which is the output of Black-Litterman (named BL_mu,
%    which in the slides is mu'').

%%%% PARAMETERS
%%%% (the following choices of parameters can easily be changed)
horizon = 4; % rebalance monthly
sample_frequency = 1; % weekly
number_of_samples = 36;
rate_of_decay = 0;
momentum_samples = 4; 
% how many samples to use in gauging momentum
%%%% END OF PARAMETERS	

% to simplify, let's abbreviate
t_d = trade_date;
h = horizon;
s_f = sample_frequency;
n_o_s = number_of_samples;
r_o_d = rate_of_decay;	
m_s = momentum_samples;				

load spdr.mat

[T,n] = size(Price);
% T is the number of time periods, and n is the number of assets

mu0 = (1 + .01*risk_free_rate(t_d - 1))^(h/52) - 1;

[hat_mu,V] = adapted_stats(Price, t_d, h, s_f, n_o_s, r_o_d);


% To gauge momentum, we'll use a naive approach based on recent expected returns.
% Note in the following input, m_s is used rather than n_o_s
r_e_r = adapted_stats(Price, t_d, h, s_f, m_s, r_o_d);
%%% "recent expected returns"

[sorted_r_e_r, short_term_ranking] =  sort(r_e_r,'descend');
% the first entry in short_term_ranking is the number of the asset with
%  the best recent expected return, the second entry is the one with second-best
%    recent expected return, and so on.

very_bullish_port = zeros(1,n);
very_bullish_port(short_term_ranking(1)) = 1;
very_bullish_port(short_term_ranking(end)) = -1;
% the very bullish portfolio is long the asset with best recent return
%     and short the asset with worst recent return

bullish_port = zeros(1,n);
bullish_port(short_term_ranking(2)) = 1;
bullish_port(short_term_ranking(end-1)) = -1;

A = [very_bullish_port; bullish_port];

bar_b = A*hat_mu + [2*sqrt(A(1,:)*V*A(1,:)'); sqrt(A(2,:)*V*A(2,:)')];
%  for very bullish portfolio, best guess of expected return is two standard
%  deviations above historical returns, whereas for bullish it is one deviation above.

U = .2*A*V*A';  
% our choice for U as on slide 20 with weight lambda = .1 to reflect
%   considerable certainty in our views.

Sigma = (1/36)*V;36.
%  Keep in mind that Sigma is meant to reflect the covariance of 
%  mean sample return resulting from T independent draws of single-period returns  

W = inv(A'*inv(U)*A+inv(Sigma));
% compute W as on slide 17

BL_mu = W'*(A'*inv(U)*bar_b+inv(Sigma)*hat_mu);
% compute BL_mu as on slide 17, where it is denoted mu'' 

hat_mu__vs__BL_mu = [hat_mu,BL_mu]
   