%--------------------------------------------------------------------------
% Name: cvx_utilfunc
% Function: Maximize utility function with given parameters and CVaR
%   constraint.

% Input:
% - Sample_Returns: matrix whose columns correspond to assets and whose
% rows correspond to samples.
% - p: a column vector whose jth entry is the weight given to
% the jth sample.
% - alpha: the confidence level at which a CVaR constraint is to be placed.
% - mu0: the expected return of risk-free asset.
% - mu: the expected returns of risky assets.
% - cvar_lim: the proportion the CVaR limit compared with minimized CVaR.
% - gamma: the CRRA in the utility function.
%
% Output:
% - x0: the weight of risk-free asset minimizing the CVaR.
% - x: the weight of risky assets minimizing the CVaR.
% - cvar: the CVaR caused by the result.
%--------------------------------------------------------------------------

function [x0,x,cvar] = cvx_utilfunc(Sample_Returns,p,alpha,omega,mu,mu0,...
    cvar_lim,gamma)

S_R = Sample_Returns;
[T,n] = size(S_R);
m = length(alpha);

cvx_begin quiet

variables x(n) ell(m) y(T,m) x0

    maximize(util_f(omega+mu*x+x0*(1+mu0),gamma))
    
    subject to
    
        -ell'-(1./(1-alpha)).*sum(diag(p)*y) >= cvar_lim
        
        y >= -repmat(S_R*x,[1 m]) - repmat(ell',[T 1])
        
        y >= 0
        
        sum(x) + x0 == 1
        
        x <= 0.2
        
        x0 <= 0.2
        
        x >= 0
        
        x0 >= 0
        
cvx_end        
