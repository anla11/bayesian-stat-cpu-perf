setwd("E:/Workspace/R/R-coursera/Bayessian/project_2")

dat = read.csv("cpu.csv", header = FALSE)
colnames(dat) = c("vendor_name", "model_name", "myct", "mmin", "mmax","cache", "chmin", "chmax", "prp", "erp")

#get log
colMeans(dat[, c("prp", "myct", "mmin", "mmax","cache", "chmin", "chmax")] > 0)
dat["log2prp"] = log2(dat$prp)
dat["log2erp"] = log2(dat$erp)

model  = lm(log2prp ~ myct + mmin + mmax + cache + chmin + chmax, data = dat)
log2yhat = predict(model)
plot(log2yhat, dat$log2prp)
plot(log2yhat, resid(model))

yhat = 2**log2yhat
mean(dat$prp - yhat)
#-12.50726
sqrt(mean((dat$prp - yhat)**2))
#196.8759

dat["log2myct"] = log2(dat$myct)
dat["log2mmin"] = log2(dat$mmin)
dat["log2mmax"] = log2(dat$mmax)
dat["log2cache"] = dat$cache
dat$log2cache[dat$log2cache>0] <- log2(dat$log2cache[dat$log2cache>0])


model_loginput_1  = lm(log2prp ~ log2myct + log2mmin + log2mmax + cache + chmin + chmax, data = dat)
log2yhat = predict(model_loginput_1)
plot(log2yhat, dat$log2prp)
plot(log2yhat, resid(model_loginput_1))

yhat = 2**log2yhat
mean(dat$prp - yhat)
#7.790664
sqrt(mean((dat$prp - yhat)**2))
#73.73902


model_loginput_2  = lm(log2prp ~ log2myct + mmin + mmax + log2cache + chmin + chmax, data = dat)
log2yhat = predict(model_loginput_2)
plot(log2yhat, dat$log2prp)
plot(log2yhat, resid(model_loginput_2))

yhat = 2**log2yhat
mean(dat$prp - yhat)
#-4.605396
sqrt(mean((dat$prp - yhat)**2))
#136.4586