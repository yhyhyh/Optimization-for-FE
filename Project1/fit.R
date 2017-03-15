library(mnormt)
library(MASS)

setwd("D:/CodeHub/R/CVAR")
data = read.csv("SPDR.csv")
col.names = c('XLY', 'XLV', 'XLU', 'XLB', 'XLE', 'XLF', 'XLI', 'XLK', 'XLP')
ret = diff(data.matrix(log(data[col.names])))
dat = ret
idx = data["INDEX"]

df = seq(2.25, 4.75, 0.01)
n = length(df)
loglik = rep(0,n)
for(i in 1:n){
  fit = cov.trob(dat,nu=df)
  loglik[i] = sum(log(dmt(dat, mean=fit$center,
                          S = fit$cov, df = df[i])))
}
aic_t = -max(2 * loglik) + 2 * (4 + 10 + 1) + 64000
z1 = (2 * loglik > 2 * max(loglik) - qchisq(0.95, 1))
plot(df, 2 * loglik - 64000, type = "l", cex.axis = 1.5,
     cex.lab = 1.5, ylab = "2 * loglikelihood - 64,000", lwd = 2)
abline(h = 2 * max(loglik) - qchisq(0.95, 1 ) - 64000)
abline(h = 2 * max(loglik) - 64000)
abline(v = (df[16] + df[17]) / 2)
abline(v = (df[130] + df[131]) / 2)

fit2 = cov.trob(dat, nu=3)
fit2$center
fit2$cov

N = 10
nu = 3

set.seed(5640)
x= mvrnorm(N, mu = fit$center, Sigma = fit2$cov)
w = sqrt(nu / rchisq(N, df = nu))
y = diag(w) %*% x
write.csv(y, "scenario.csv")

idx_ret = diff(log(data.matrix(idx)))
sd(idx_ret)
