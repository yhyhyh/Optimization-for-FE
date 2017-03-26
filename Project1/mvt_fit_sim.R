#############################################################################
# Name: fit and simulate multivariate t distribution
# Function: fit historical return data as multivariate t distribution
#     generate return scenarios by aggregating simulated weekly return
#
#Input:
# SPDR.csv: price dataframe
#
#Output:
# $number of date$.csv: scenario matrix
# produce a sequence of csv file named after the days from starting date
#
#############################################################################
# set external paramters

filename = "SPDR.csv"

num.sim = 1000
window.len = 100
rebalance.len = 20
set.seed(5370)
#################################

library(MASS)
library(mnormt)
setwd(path)
data = read.csv(filename)
col.names = c('XLY', 'XLV', 'XLU', 'XLB', 'XLE', 'XLF', 'XLI', 'XLK', 'XLP')
# col.names = colnames(data)

ret.all = diff(data.matrix(log(data[col.names])))
num.var = ncol(ret.all)
num.obs = nrow(ret.all)
rebalance.times = floor((num.obs - window.len)/rebalance.len)

df = seq(0.95, 5.75, 0.01)
loglik = rep(0, length(df))
sim.out = matrix(0, num.sim, num.var)

for (i in 0:rebalance.times){
  
  end = window.len + i * rebalance.len
  start = end + 1 - window.len
  ret = ret.all[start:end,]
  
  # profile likelihood to determine tail index
  for(j in 1:length(df)){
    fit = cov.trob(ret,nu=df)
    loglik[j] = sum(log(dmt(ret, mean=fit$center,S = fit$cov, df = df[j])))
  }
  
  # set up optimal tail index
  nu = round(df[which.max(loglik)]) 
  fitted.pars = cov.trob(ret, nu=nu)
  mu =  fitted.pars$center # set up mean vector
  Sigma = fitted.pars$cov # set up covariance matrix
  
  # simulate multivariate t
  x= mvrnorm(num.sim*rebalance.len, mu = mu, Sigma = Sigma)
  w = sqrt(nu / rchisq(num.sim*rebalance.len, df = nu))
  y = x * w
  # y = diag(w) %*% x
  
  # aggregate daily data into scenario data
  for (k in 1:num.sim){
    start1 = rebalance.len * (k-1) + 1
    end1 = rebalance.len * k
    sim.out[k,] = colSums(y[start1:end1,]) 
  }
  
  write.csv(sim.out, paste(as.character(end),'.csv', sep=''))
  
}
