%------------------------------------------------------------
% Name: optimize_cvar                                       |
% Function: Give out weights and corresponding              |
%     transaction cost based on all given information.      |
%                                                           |
% Input:                                                    |
% - mu0: return rate of risk-free asset                     |
% - mu: return rates of risky assets                        |
% - scenario: scenario matrix from nearest past date        |
% - xx0: weight of risk-free asset in the last period       |
% - xx: weights of assets in the last period                |
% - trans_cost: rate of transaction cost                    |
% - type: indicate if take transaction cost into the        |
%       optimization constraint.                            |
%       (0 for no, 1 for yes)                               |
%                                                           |
% Output:                                                   |
% - x0: optimized weight of risk-free asset                 |
% - x: optimized weights vector of assets                   |
% - cost: transaction cost for this step of rebalancing     |
%------------------------------------------------------------
function [x0,x,cost] = optimize_cvar(mu0,mu,scenario,xx0,xx,trans_cost,type)
    
    n = size(mu,2);
    lb = zeros(1,n+1);
    ub = 0.2*ones(1,n+1);
    if (type==0)
        X0 = [xx0; xx];
        A = [-1-mu0, -1-mu];
        b = -1-sum(mu)/n*0.8;
        Aeq = ones(1,n+1);
        beq = 1;
        X = fmincon(@(X)calc_CVaR(scenario,X),X0,A,b,Aeq,beq,lb,ub);
        sum(X)
        cost = sum(abs(X-X0))*trans_cost;
        X = X.*(1-cost);
    else
        X0 = [xx0; xx];
        XX = X0;
        X = fmincon(@(X)calc_CVaR(scenario,X),X0,[],[],[],[],lb,ub,...
            @(X)con_with_trans_cost(X,mu0,mu,trans_cost,XX));
        sum(X)
        cost = 1-sum(X);
    end
    
    x0 = X(1);
    x = X(2:n+1);
    
end


%------------------------------------------------------------
% Name: con_with_trans_cost                                 |
% Function: Provide the constraint about limiting the       |
%       trasaction cost.                                    |
%                                                           |
% Input:                                                    |
% - X: weights of assets in current period                  |
% - mu0: return rate of risk-free asset                     |
% - mu: return rates of risky assets                        |
% - scenario: scenario matrix from nearest past date        |
% - trans_cost: rate of transaction cost                    |
% - XX: weight of all assets in the last period             |
%                                                           |
% Output:                                                   |
% - c: the constraint for <=0 condition                     |
% - ceq: the constraint for =0 condition                    |
%------------------------------------------------------------
function [c,ceq] = con_with_trans_cost(X,mu0,mu,trans_cost,XX)    
    A = [-1-mu0, -1-mu];
    n = length(mu);
    cost = sum(abs(X-XX))*trans_cost;
    c = A*X+cost+1+sum(mu)/n*0.8;
    ceq = sum(X)+cost-1;
end
