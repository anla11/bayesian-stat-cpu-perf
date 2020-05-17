setwd("E:/Workspace/R/R-coursera/Bayessian/project_2")

dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")

#get log
colMeans(dat[, c("prp", "erp", "myct", "mmin", "mmax","cache", "chmin", "chmax")] > 0)

data_jags = as.list(dat[, c("myct", "mmin", "mmax","cache", "chmin", "chmax", "prp")])
params = c("int", "b_myct", "b_mmin", "b_mmax", "b_chmin", "b_chmax", "b_cache")

poire_string = " model {
for (i in 1:length(prp)) {
prp[i] ~ dpois(lam[i])
log(lam[i]) = int + b_myct * myct[i] + b_mmin*mmin[i] + b_mmax*mmax[i] + b_chmin*chmin[i] + b_chmax *chmax[i] + b_cache * cache[i]
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

poire_mod = jags.model(textConnection(poire_string), data=data_jags, n.chains=3)
update(poire_mod, 1e3)

poire_sim = coda.samples(model=poire_mod,
                         variable.names=params,
                         n.iter=5e3)
poire_csim = as.mcmc(do.call(rbind, poire_sim))

## convergence diagnostics
# plot(poire_csim)

## model checking
gelman.diag(poire_sim)
autocorr.diag(poire_sim)
effectiveSize(poire_sim)
# autocorr.plot(poire_sim)


## residual
# head(dat[3:8])
X = as.matrix(dat[3:8])
# head(X)
(pmed_coef = colMeans(poire_csim))
yhat = exp(pmed_coef["int"] + X %*% pmed_coef[c("b_myct", "b_mmin", "b_mmax", "b_cache", "b_chmin", "b_chmax")])
# head(log2yhat)
# head(dat$log2prp)

par( mfrow = c( 1, 1 ) ) 
plot(yhat, dat$prp - yhat)
plot(log2(yhat), log2(dat$prp - yhat))

par( mfrow = c( 3, 1 ) ) 
plot(dat$log2prp, dat$log2erp-dat$log2prp)
plot(dat$log2prp, dat$log2prp-log2yhat)
plot(dat$log2prp, dat$log2erp-log2yhat)

mean(log2(dat$prp) - log2(yhat))
#-12.50447
sqrt(mean((dat$prp - yhat)**2))
# 58.17656

library("coda")
autocorr.plot(as.mcmc(poire_csim[, "int"]))
# plot(lmlog_csim)
# 
library(BayesianTools)
correlationPlot(poire_csim)

## compute DIC
(dic = dic.samples(poire_mod, n.iter=1e3))
# Mean deviance:  4781 
# penalty 7.157 
# Penalized deviance: 4788 