setwd("E:/Workspace/R/R-coursera/Bayessian/project")

dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")

dat$vendor = as.numeric(dat$vendor_name)
dat$cache[dat$cache>0] <- log2(dat$cache[dat$cache>0])
dat$myct <- log2(dat$myct)

data_jags = as.list(dat[, c("vendor", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp")])
params = c("int", "b_myct", "b_mmin", "b_mmax", "b_chmin", "b_chmax", "b_cache")

hiepoirelog_string = " model {
for (i in 1:length(prp)) {
prp[i] ~ dpois(lam[i])
log(lam[i]) = int[vendor[i]] + b_myct * myct[i] + b_mmin*mmin[i] + b_mmax*mmax[i] + b_chmin*chmin[i] + b_chmax *chmax[i] + b_cache * cache[i]
}
for (j in 1:max(vendor))
{
  int[j] ~ dnorm(0.0, 1.0/1e6)
}

b_myct ~ dnorm(0.0, 1.0/1e4)
b_mmin ~ dnorm(0.0, 1.0/1e4)
b_mmax ~ dnorm(0.0, 1.0/1e4)
b_chmin ~ dnorm(0.0, 1.0/1e4)
b_chmax ~ dnorm(0.0, 1.0/1e4)
b_cache ~ dnorm(0.0, 1.0/1e4)
} "

library("rjags")
set.seed(100)

hiepoirelog_mod = jags.model(textConnection(hiepoirelog_string), data=data_jags, n.chains=3)
update(hiepoirelog_mod, 1e3)

hiepoirelog_sim = coda.samples(model=hiepoirelog_mod,
                               variable.names=params,
                               n.iter=5e4)
hiepoirelog_csim = as.mcmc(do.call(rbind, hiepoirelog_sim))

## convergence diagnostics
plot(hiepoirelog_csim)

## model checking
gelman.diag(hiepoirelog_sim)
autocorr.diag(hiepoirelog_sim)
effectiveSize(hiepoirelog_sim)
autocorr.plot(hiepoirelog_sim)

## residual
X = as.matrix(dat[c(3:8)])
head(X)
(pmed_coef = apply(hiepoirelog_csim, 2, median))

# (pmed_coef = colMeans(poirelog_csim))
vendorstr=sprintf("int[%d]",dat[,11])
head(vendorstr)
head(pmed_coef[vendorstr])
yhat = exp(pmed_coef[vendorstr] + X %*% pmed_coef[c("b_myct", "b_mmin", "b_mmax", "b_cache", "b_chmin", "b_chmax")])
head(dat$erp)
head(dat$prp)
head(yhat)

par( mfrow = c( 1, 1 ) ) 

hist(yhat)
plot(dat$prp, dat$prp - yhat)
plot(yhat, dat$prp - yhat)

par( mfrow = c( 3, 1 ) ) 
plot(dat$erp, dat$erp-dat$prp)
plot(yhat, dat$prp-yhat)
plot(yhat, dat$erp-yhat)


mean(dat$prp-dat$erp)
#6.291866
mean(dat$prp-yhat)
# 0.03139715

## compute DIC
(dic = dic.samples(hiepoirelog_mod, n.iter=1e3))
# Mean deviance:  2976 
# penalty 35.02 
# Penalized deviance: 3011 

# Mean deviance:  3497 
# penalty 36.58  
# Penalized deviance: 3534