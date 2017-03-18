function [scenario_mat] = sim_scenario(data, n_sim)
n_asset = size(data, 2);
% fit multivariate t distribution
fitted_pars = fit_mvt(data);
% unpack parameters
mean_fit = fitted_pars(1:n_asset);
chol_v_fit = fitted_pars(n_asset+1, n_asset + 0.5*(n_asset*(n_asset+1)));
nu_fit = fitted_pars(end);

% construct upper triangular cholesky factor from vector
chol_factor = triu(ones(n_asset, n_asset));
chol_factor(chol_factor==1) = chol_v_fit;
cov_fit = chol_factor' * chol_factor;
scenario_mat = mvtrnd(cov_fit,nu_fit,n_sim) + mean_fit';

end