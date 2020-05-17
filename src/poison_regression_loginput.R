setwd("E:/Workspace/R/R-coursera/Bayessian/project_2")

dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")

#get log
colMeans(dat[, c("prp", "erp", "myct", "mmin", "mmax","cache", "chmin", "chmax")] > 0)

dat["log2myct"] = log2(dat$myct)
dat["log2cache"] = dat$cache
dat$log2cache[dat$log2cache>0] <- log2(dat$log2cache[dat$log2cache>0])

data_jags = as.list(dat[, c("log2myct", "mmin", "mmax","log2cache", "chmin", "chmax", "prp")])
params = c("int", "b_myct", "b_mmin", "b_mmax", "b_chmin", "b_chmax", "b_cache")

poirelog_string = " model {
for (i in 1:length(prp)) {
prp[i] ~ dpois(lam[i])
log(lam[i]) = int + b_myct * log2myct[i] + b_mmin*mmin[i] + b_mmax*mmax[i] + b_chmin*chmin[i] + b_chmax *chmax[i] + b_cache * log2cache[i]
}
int ~ dnorm(0.0, 1.0/1e6)
b_myct ~ dnorm(0.0, 1.0/1e4)
b_mmin ~ dnorm(0.0, 1.0/1e4)
b_mmax ~ dnorm(0.0, 1.0/1e4)
b_chmin ~ dnorm(0.0, 1.0/1e4)
b_chmax ~ dnorm(0.0, 1.0/1e4)
b_cache ~ dnorm(0.0, 1.0/1e4)
} "

library("rjags")
set.seed(100)

poirelog_mod = jags.model(textConnection(poirelog_string), data=data_jags, n.chains=3)
update(poirelog_mod, 1e3)

poirelog_sim = coda.samples(model=poirelog_mod,
                            variable.names=params,
                            n.iter=1e4)
poirelog_csim = as.mcmc(do.call(rbind, poirelog_sim))

## convergence diagnostics
# plot(poire_csim)

## model checking
gelman.diag(poirelog_sim)
autocorr.diag(poirelog_sim)
effectiveSize(poirelog_sim)
# autocorr.plot(poirelog_sim)


## residual
head(dat)
X = as.matrix(dat[c(11,4,5,12,7,8)])
# head(X)
(pmed_coef = colMeans(poirelog_csim))
logyhat = pmed_coef["int"] + X %*% pmed_coef[c("b_myct", "b_mmin", "b_mmax", "b_cache", "b_chmin", "b_chmax")]
yhat = exp(logyhat)
# head(log2yhat)
# head(dat$log2prp)

par( mfrow = c( 1, 1 ) ) 
plot(yhat, dat$prp - yhat)
plot(logyhat, log(dat$prp) - logyhat)

par( mfrow = c( 3, 1 ) ) 
plot(dat$log2prp, dat$log2erp-dat$log2prp)
plot(dat$log2prp, dat$log2prp-log2yhat)
plot(dat$log2prp, dat$log2erp-log2yhat)

mean(log(dat$prp) - logyhat)
#-0.1015074
sqrt(mean((dat$prp - yhat)**2))
# 45.97349

library("coda")
autocorr.plot(as.mcmc(poirelog_csim[, "int"]))
# plot(lmlog_csim)
# 
library(BayesianTools)
correlationPlot(poire_csim)

## compute DIC
(dic = dic.samples(poirelog_mod, n.iter=1e3))
# Mean deviance:  4027 
# penalty 7.139 
# Penalized deviance: 4034 