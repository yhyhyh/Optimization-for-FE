function ret = calc_pnl(w, price, r, vol)

n = length(r);
ret = w(1:n)*r';
S0 = price(n+1);
[Call, Put] = blsprice(S0, S0, 0.03, 1, vol);
past_S = sum(price(1:n)./(1+r));
ret = ret+max([past_S-S0,0])*w(n+1)-Put*w(n+1);

end

