%--------------------------------------------------------------------------
% Name: util_f
% Function: Implement the utility function as the objective function in the
% second step.
%
% Input:
% - gamma: the CRRA in the utility function.
%
% Output:
% - u: the value of utility function.
%--------------------------------------------------------------------------

function u = util_f(w,gamma)
    u = (w^(1-gamma)-gamma)/(1-gamma);
end