setwd("E:/Workspace/R/R-coursera/Bayessian/project")

# https://archive.ics.uci.edu/ml/datasets/Computer+Hardware
dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")
View(dat)

hist(dat$prp)
hist(log(dat$prp))

plot(dat[,c("vendor_name", "prp")])
plot(dat[, c("myct", "mmin", "mmax","cache", "chmin", "chmax", "prp")])

par( mfrow = c( 1, 1 ) ) 
plot(dat$myct, dat$prp)
plot(log(dat$myct), log(dat$prp))

par( mfrow = c( 3, 1 ) ) 
plot(dat$mmax, dat$prp)
plot(dat$mmin, dat$prp)
plot(dat$mmax - dat$mmin, dat$prp)

par( mfrow = c( 3, 1 ) ) 
plot(log(dat$mmax), log(dat$prp))
plot(log(dat$mmin), log(dat$prp))
plot(log(dat$mmax - dat$mmin), log(dat$prp))

par( mfrow = c( 2, 1 ) ) 
plot(dat$mmax, dat$prp)
plot(log(dat$mmax), log(dat$prp))


par( mfrow = c( 3, 1 ) ) 
plot(dat$chmax, dat$prp)
plot(dat$chmin, dat$prp)
plot(dat$chmax - dat$chmin, dat$prp)

par( mfrow = c( 3, 1 ) ) 
plot(log(dat$chmax), log(dat$prp))
plot(log(dat$chmin), log(dat$prp))
plot(log(dat$chmax - dat$chmin), log(dat$prp))

par( mfrow = c( 1, 1 ) ) 
plot(dat$vendor_name, dat$mmax)
plot(dat$vendor_name, dat$mmin)
plot(dat$vendor_name, dat$mmax - dat$mmin)

par( mfrow = c( 3, 1 ) ) 
plot(dat$vendor_name, log(dat$chmax))
plot(dat$vendor_name, log(dat$chmin))
plot(dat$vendor_name, log(dat$chmax - dat$chmin))

hist(dat$myct)
hist(dat$chmax)
hist(dat$chmin)
hist(dat$cache)
hist(dat$mmin)
hist(dat$mmax)

hist(log(dat$myct))
hist(log(dat$chmax))
hist(log(dat$chmin))
hist(log(dat$chmax - dat$chmin))
hist(log(dat$cache))
hist(log(dat$mmin))
hist(log(dat$mmax))
hist(log(dat$mmax - dat$mmin))

# model 1: directly poisson regression
# E[prp[i]] = lambda[i]
# log(lambda[i]) = b0 + b1 * x1...

# model 1.5: hierachiecal model from model 1

# model 2: poisson regression with log input
# colMeans(dat > 0)
# dat2 = dat[,c("vendor_name", "myct", "mmin", "mmax", "cache","chmin", "chmax", "prp")]

