function [x0,x] = optimize_cvar(mu0,mu,scenario,xx0,xx,trans_cost,type)
    
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
    else
        X0 = [xx0; xx];
        XX = X0;
        X = fmincon(@(X)calc_CVaR(scenario,X),X0,[],[],[],[],lb,ub,...
            @(X)con_with_trans_cost(X,mu0,mu,trans_cost,XX));
        sum(X)
    end
    
    total_trans_cost = sum(abs(X-X0))*trans_cost;
    X = X.*(1-total_trans_cost);
    x0 = X(1);
    x = X(2:n+1);
    
end

function [c,ceq] = con_with_trans_cost(X,mu0,mu,trans_cost,XX)    
    A = [-1-mu0, -1-mu];
    n = length(mu);
    cost = sum(abs(X-XX))*trans_cost;
    c = A*X+cost+1+sum(mu)/n*0.8;
    ceq = X+cost-1;
end
