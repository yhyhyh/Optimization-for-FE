function [fitted_pars] = fit_mvt(data)
% empirical mean, standard deviation, cholesky factor as start value
n_asset = size(data, 2);
center = mean(data);
sd = std(data);
chol_factor = chol(corr(data));
% lower bound and upper bound for parameters
chol_lower = diag(2 * ones(1, n_asset)) - triu(ones(n_asset, n_asset));
chol_upper = triu(ones(n_asset, n_asset));
lower_bound = [center-sd,(chol_lower(:))',1];
upper_bound = [center+sd,(chol_upper(:))',15];
start = [center,(chol_factor(:)),3];
fitted_pars = fmincon(loglik, start,[],[],[],[],lower_bound, upper_bound);
% check if fitted cholesky factor results in a positive semidefinite matrix
% chol_fit = [];
end

