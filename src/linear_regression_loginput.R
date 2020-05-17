setwd("E:/Workspace/R/R-coursera/Bayessian/project_2")

dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")

#get log
colMeans(dat[, c("prp", "erp", "myct", "mmin", "mmax","cache", "chmin", "chmax")] > 0)
dat["log2prp"] = log2(dat$prp)
dat["log2erp"] = log2(dat$erp)
dat["log2myct"] = log2(dat$myct)
dat["log2mmin"] = log2(dat$mmin)
dat["log2mmax"] = log2(dat$mmax)
dat["log2cache"] = dat$cache
dat$log2cache[dat$log2cache>0] <- log2(dat$log2cache[dat$log2cache>0])
# dat["log2chmin"] = dat$chmin
# dat$log2chmin[dat$log2chmin>0] <- log2(dat$log2chmin[dat$log2chmin>0])
# dat["log2chmax"] = dat$chmax
# dat$log2chmax[dat$log2chmax>0] <- log2(dat$log2chmax[dat$log2chmax>0])

data_jags = as.list(dat[, c("log2myct", "mmin", "mmax","log2cache", "chmin", "chmax", "log2prp")])
params = c("int", "b_myct", "b_mmin", "b_mmax", "b_chmin", "b_chmax", "b_cache", "sig2")

lmlog_string = " model {
  for (i in 1:length(log2prp)) {
    log2prp[i] ~ dnorm(mu[i], prec)
    mu[i] = int + b_myct * log2myct[i] + b_mmin*mmin[i] + b_mmax*mmax[i] + b_chmin*chmin[i] + b_chmax *chmax[i] + b_cache * log2cache[i]
  }

  prec ~ dgamma(0.001, 1.0/1e6)
  sig2 = 1.0 / prec
  int ~ dnorm(0.0, 1.0/1e6)
  b_myct ~ dnorm(0.0, 1.0/1e6)
  b_mmin ~ dnorm(0.0, 1.0/1e6)
  b_mmax ~ dnorm(0.0, 1.0/1e6)
  b_chmin ~ dnorm(0.0, 1.0/1e6)
  b_chmax ~ dnorm(0.0, 1.0/1e6)
  b_cache ~ dnorm(0.0, 1.0/1e6)
} "


library("rjags")
set.seed(100)

lmlog_mod = jags.model(textConnection(lmlog_string), data=data_jags, n.chains=3)
update(lmlog_mod, 1e3)

lmlog_sim = coda.samples(model=lmlog_mod,
                         variable.names=params,
                         n.iter=5e3)
lmlog_csim = as.mcmc(do.call(rbind, lmlog_sim))

## convergence diagnostics
# plot(poirelog_csim)

## model checking
gelman.diag(lmlog_sim)
autocorr.diag(lmlog_sim)
effectiveSize(lmlog_sim)
# autocorr.plot(poirelog_sim)

## residual
# head(dat[c(c(4,5,7,8), c(13:16))])
# X = as.matrix(dat[13:18])
X = as.matrix(dat[c(13,4,5,16, 7,8)])
# head(X)
(pmed_coef = colMeans(lmlog_csim))
log2yhat = pmed_coef["int"] + X %*% pmed_coef[c("b_myct", "b_mmin", "b_mmax", "b_cache", "b_chmin", "b_chmax")]
yhat = 2**log2yhat
# head(log2yhat)
# head(dat$log2prp)

par( mfrow = c( 1, 1 ) ) 
plot(log2yhat, dat$log2prp - log2yhat)
plot(yhat, dat$prp - yhat)

par( mfrow = c( 3, 1 ) ) 
plot(dat$log2prp, dat$log2erp-dat$log2prp)
plot(dat$log2prp, dat$log2prp-log2yhat)
plot(dat$log2prp, dat$log2erp-log2yhat)

mean(dat$prp - yhat)
#-4.583289
sqrt(mean((dat$prp - yhat)**2))
# 136.3568

library("coda")
autocorr.plot(as.mcmc(lmlog_csim[, "int"]))
# plot(lmlog_csim)
# 
library(BayesianTools)
correlationPlot(lmlog_csim)

## compute DIC
(dic = dic.samples(lmlog_mod, n.iter=1e3))
# Mean deviance:  405.3 
# penalty 8.234 
# Penalized deviance: 413.5 