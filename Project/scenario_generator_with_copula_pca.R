#################################
# set external paramters

path = "D:/CodeHub/R/CVAR"
filename = "opt_proj_data.csv"

num.sim = 1000
window.len = 500
rebalance.len = 50
set.seed(5370)
num.pc = 10 # first 10 principal components usually explain most of variation
#################################

library(MASS)   # for fitting distribution
library(copula) # for copula functions
library(fGarch) # for standardized t density

setwd(path)
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
	# Principal Component Analysis
	pca = princomp(ret)
	ret.pc = pca$scores[,1:num.pc]
	# estimated parameters
	est.mat = matrix(0, num.pc, 3)
	# fit parametric marginal distributions (t distribution)
	for (i in 1:num.pc){
		x = ret.pc[,i]
		# fit univariate t distribution
		est = as.numeric(fitdistr(x, "t", start = list(m=mean(x),s=sd(x), df=3))$estimate)
		est[2] = est[2] * sqrt( est[3] / (est[3]-2) ) # convert to standardized t notation
		est.mat[i,] = est
	}
	# probability integral transform
	probs = matrix(0, window.len, num.pc)
	for (i in 1:num.pc){
		x = ret.pc[,i]
		probs[,i] = pstd(x, est.mat[i, 1], est.mat[i, 2], est.mat[i, 3])
	}
	# initial parameter for optimization routine
	cor.tau = cor(probs, method = "kendall")
	omega = sin(pi/2 * cor.tau)
	omega.list= omega[upper.tri(omega, diag = FALSE)]
	# specify parametric copula (t copula)
	cop.t = tCopula(omega.list, dim = num.pc, dispstr = "un", df = 4)
	# fit copula
	cop.fit = fitCopula(cop.t, probs, method="itau.mpl", start=c(omega.list))
	# set the copula for simulation
	len = length(cop.fit@estimate)
	cop.sim = tCopula(cop.fit@estimate[-len], dim = num.pc, dispstr = "un", df = cop.fit@estimate[len])
  
  	# simulate log returns for assets via fitted copula and fitted marginals
	rProbs = rCopula(n = num.sim*rebalance.len, copula = cop.sim)
	sample.pc = matrix(0, num.sim*rebalance.len, num.pc)
	# reverse probability integral transform
	for (i in 1:num.pc){
	  sample.pc[,i] = qstd(rProbs[,i], mean = est.mat[i,1], sd = est.mat[i,2], nu = est.mat[i,3])
	}
	# convert principal components back to asset returns
	sample =  sample.pc %*% t(pca$loadings[,1:num.pc])
	# aggregate weekly data into scenario data
	for (k in 1:num.sim){
		start1 = rebalance.len * (k-1) + 1
		end1 = rebalance.len * k
		sim.out[k,] = colSums(sample[start1:end1,]) 
	}
	sim.out = exp(sim.out) - 1 # convert log returns to simple returns
	write.csv(sim.out, paste(as.character(end),'.csv', sep=''))
}

print("scenario generator: work done!")
