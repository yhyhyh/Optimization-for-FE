% returns sample mean as a column vector, and covariance matrix
function [mu, V] = stats(Prices, trade_date, frequency, num_samples, rate_of_decay)
% simplify variable names
P = Prices; t_d = trade_date; f = frequency;
n_s = num_samples; r_o_d = rate_of_decay;
% sample dats, a row vector
s_d = fliplr(t_d - 1 - f * [0:n_s]);
% sample prices and sample returns
S_P = P(s_d,:);
S_R = (S_P(2:end,:) - S_P(1:end-1,:))./S_P(1:end-1,:);
% decay weight,a row vector
temp = fliplr(cumprod((1-r_o_d) * ones(1,n_s)));
w = temp / sum(temp); % normalize the sum of weight to one
% sample mean, a colume vector
mu = (w * S_R)';
V = S_R'*diag(w)*S_R - mu * mu';
end

