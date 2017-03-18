function [x0,x] = optimize_cvar(mu0,mu,scenario,sigma,xx0,xx,trans_cost)

    n = size(mu,2);
    X0 = [xx0; xx];
    A = [-mu0, -mu];
    b = -sum(mu)/n;
    Aeq = ones(1,n+1);
    beq = 1;
    X = fmincon(@(X)calc_CVaR(scenario,X),X0,A,b,Aeq,beq,zeros(1,n+1),0.2*ones(1,n+1));
    x0 = X(1);
    x = X(2:n+1);
    x0
    x
end

