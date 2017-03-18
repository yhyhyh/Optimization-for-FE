function [negative_loglik] = loglik(data, pars)
% data should be global variable
n_asset = size(data, 2);
% unpack parameters
center = pars(1:n_asset);
chol_v = pars(n_asset+1, n_asset + 0.5*(n_asset*(n_asset+1)));
df = pars(end);
% construct upper triangular cholesky factor from vector
chol_factor = triu(ones(n_asset, n_asset));
chol_factor(chol_factor==1) = chol_v;
corr = chol_factor' * chol_factor;
% decenter data because mvtpdf has no mean parameter
X = data - repmat(center,size(data,1), 1);
negative_loglik = -sum(log(mvtpdf(X, corr, df)));
end

