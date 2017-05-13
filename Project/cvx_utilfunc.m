function [x0,x,cvar] = cvx_utilfunc(Sample_Returns,p,alpha,omega,mu,mu0,cvar_lim,gamma)

% Sample_Returns is a matrix whose columns correspond to assets and whose
% rows correspond to samples (e.g., dates).

% p is a column vector whose jth entry is the weight given to
% the jth sample.  The coordinates of probability should be non-negative
% and sum to 1.

% alpha is a row vector, each entry of which specifies the confidence level 
% at which a CVaR constraint is to be placed.  For example, if one CVaR
% constraint is to be placed at the 97% level and a second at the 90%
% level -- as in the example on the slides -- then alpha = [.97,.9].

% beta is a row vector whose jth entry specifies the right-hand
% side value of the jth CVaR constraint, that is, the maximum allowable
% average-loss in the tail.  For the example in the slides, 
% beta = [10,5].

% ????? is other data you want as input, in order to specify the
% objective function in the following code, as well as to specify any
% constraints besides the CVaR constraints.

S_R = Sample_Returns;

[T,n] = size(S_R);
m = length(alpha);

cvx_begin quiet

variables x(n) ell(m) y(T,m) x0
% Be careful not to use the variables ell and y except where they already
% appear in the following code.  By contrast, you can use x -- the
% portfolio variables -- however you wish in the objective function and
% additional constraints.

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
        
        % At the very least, you'll want to include a constraint
        % equating the amount of investement to wealth, such as sum(x)==1
        
cvx_end        
