%------------------------------------------------------------
% Name: calc_CVaR                                           |
% Function: Calculate CVaR according to weight vector and   |
%       scenario matrix.                                    |
%                                                           |
% Input:                                                    |
% - scenario: scenario matrix read from csv file            |
% - x: weights of assets                                    |
%                                                           |
% Output:                                                   |
% - CVaR: The Conditinoal VaR with confidence level 90%     |
%------------------------------------------------------------

function CVaR = calc_CVaR(scenario,x)
    
    n = size(scenario,1);
    ind = round(n*0.1);  
    sort_ret = sort(scenario*x(2:n+1));
    %VaR = sort_ret(ind);
    CVaR = sum(sort_ret(1:ind))/ind;

end

