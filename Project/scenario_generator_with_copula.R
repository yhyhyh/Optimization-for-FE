#############################################################################
# Name: scenario_generator_with_copula
# Function: fit historical return data with copula,
#     generate return scenarios by aggregating simulated weekly return.
#
#Input:
# opt_proj_data.csv: price dataframe including stocks, commodities, FX
#     and fixed-income securities.
#
#Output:
# $number of date$.csv: scenario matrix
# produce a sequence of csv file named after the days from starting date
#
#############################################################################
# set external paramters

filename = "opt_proj_data.csv"
num.sim = 1000
window.len = 300
rebalance.len = 50
set.seed(5370)
#################################

library(MASS)   # for fitting distribution
library(copula) # for copula functions
library(fGarch) # for standardized t density

data = read.csv(filename)
col.names = colnames(data)[-1]

ret.all = diff(data.matrix(log(data[col.names]))) # log returns
num.asset = ncol(ret.all)
num.obs = nrow(ret.all)
rebalance.times = floor((num.obs - window.len)/rebalance.len)

sim.out = matrix(0, num.sim, num.asset)

# generate scenarios at each rebalance date for next holding period
for (i in 0:rebalance.times){
  
	end = window.len + i * rebalance.len
	start = end + 1 - window.len
	ret = ret.all[start:end,]
	# estimated parameters
	est.mat = matrix(0, num.asset, 3) 
	# fit parametric marginal distributions
	for (i in 1:num.asset){
		x = ret[,i]
		# fit univariate t distribution
		est = as.numeric(fitdistr(x, "t", start = list(m=mean(x),s=sd(x), df=3))$estimate)
		est[2] = est[2] * sqrt( est[3] / (est[3]-2) ) # convert to standardized t notation
		est.mat[i,] = est
	}
	# probability integral transform
	probs = matrix(0, num.obs, num.asset)
	for (i in 1:num.asset){
		x = ret.all[,i]
		probs[,i] = pstd(x, est.mat[i, 1], est.mat[i, 2], est.mat[i, 3])
	}
	# initial parameter for optimization routine
	cor.tau = cor(probs, method = "kendall")
	omega = sin(pi/2 * cor.tau)
	omega.list= omega[upper.tri(omega, diag = FALSE)]
	# specify parametric copula (t copula)
	cop.t = tCopula(omega.list, dim = num.asset, dispstr = "un", df = 4)
	# fit copula
	cop.fit = fitCopula(cop.t, probs, method="itau.mpl", start=c(omega.list))
	# set the copula for simulation
	len = length(cop.fit@estimate)
	cop.sim = tCopula(cop.fit@estimate[-len], dim = num.asset, dispstr = "un", df = cop.fit@estimate[len])
  
  	# simulate log returns for assets via fitted copula and fitted marginals
	rProbs = rCopula(n = num.sim*rebalance.len, copula = cop.sim)
	sample = matrix(0, num.sim*rebalance.len, num.asset)
	# reverse probability integral transform
	for (i in 1:num.asset){
	  sample[,i] = qstd(rProbs[,i], mean = est.mat[i,1], sd = est.mat[i,2], nu = est.mat[i,3])
	}
	  
  # aggregate weekly data into scenario data
	for (k in 1:num.sim){
		start1 = rebalance.len * (k-1) + 1
		end1 = rebalance.len * k
		sim.out[k,] = colSums(sample[start1:end1,]) 
	}
	sim.out = exp(sim.out) - 1 
	write.csv(sim.out, paste(as.character(end),'.csv', sep=''))
}

print("scenario generator: work done!")
