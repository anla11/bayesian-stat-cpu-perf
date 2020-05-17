# Computer Hardware Estimation using Hierarchical Poisson Regression

Capstone project report of the course: Bayesian Statistics - Techniques and Models

## 1. Problem and Data description

The dataset was collected from 209 computers on the market from 1981 - 1984, with machine names and 7 attributes:
- Vendor name (30 unique names)
- Model Name
- MYCT: machine cycle time in nanoseconds (integer [17; 1500]).
- MMIN: minimum main memory in KB (integer [64; 32000]).
- MMAX: maximum main memory in KB (integer [64; 64000] )
- CACHE: cache memory in KB (integer [0; 256]).
- CHMIN: minimum channels in units (integer [0; 52])
- CHMAX: maximum channels in units (integer [0; 176])
- PRP: published relative performance (integer)
- ERP: estimated relative performance from Qi Zhou et al (integer)

MYCT means the actual time computers take complete all of operations to do something. The larger MYCT, the lower performance. MMIN, MMAX, CACHE indicates size of memory device. More memory, less time running. CHMIN, CHMAX are related to transfer data rate, so that faster speed, higher CPU performance. 

Qi Zhou et al found that applying log transformation to MYCT, MMIN, MMAX and PRP was the best solution when using linear regression.

For full dataset, more details of data description and Qi Zhou, see this link:
- [https://archive.ics.uci.edu/ml/datasets/Computer+Hardware](https://archive.ics.uci.edu/ml/datasets/Computer+Hardware).
- [https://www.slideshare.net/QiGilbertZhou/evaluating-cpu-performance](https://www.slideshare.net/QiGilbertZhou/evaluating-cpu-performance).

## 2. Explore data

PRP has poisson data shape. As a "traditional" solution of predicting counting number, I immediately think of poisson regression. Beside that, poisson distribution can be seen as right-skew normal distribution, then skewness can be removed by using log transformation. Therefore, using log of PRP, we can apply linear regression. 

Inspired by work of Qi Zhou et al, I not only took log of PRP, but also some independent variables. The advantage of
this pre-processing step is removing skewness, but it also reduces value ranges. So that variable with highly-right-skew and
small range are not suitable. Just MYCT, MMIN, MMAX are satisfied.

![Histogram of vars and their log transformation](/images/histogram.png)

![Their relationship](/images/plot_log.png)

Plotting relationship between vendor and log(prp), it can be seen that computers from same vendor are more likely to be
similar than those from different vendors. 

![Vendor and PRP](/images/vendor.png)

After this exploring data, I decided to:
- Compare poisson regression and linear regression with log(PRP)
- Compare using those model with and without log transformation of MYCT, MMIN, MMAX.
- Construct hierachical model.

## 3. Model

- Linear Regression with target is log(PRP)
- Poisson Regression 
- Apply log transformation to MYCT, MMIN, MMAX: attributes: [logmyct; logmmin; logmmax; cache; chmin; chmax].
- Hierarchical Poisson Regression: Instead of β0 for all vendors, use βvendor ∼ norm(0:0; 106)

![Vendor and PRP](/images/equations.png)

## 4. Results

- Convergence: Linear Regression with log(PRP) is easy to reach convergence (lag 50). The second one is Poisson
Regression. When using log of MYCT, MMIN, MMAX, coefficients of those variables need larger number of iterators
to be converged (lag 2000). In hierachical model, intercepts of vendors have slower convergence speed, too (lag 3000).
- Residual: All models have good residual plots (without any trending or pattern). No correlation between parameters.
- Precision and Complexity of Model: use DIC.
- Predictive performance: I use Root Mean Square Error (RMSE) to calculate the difference between PRP and prediction. RMSE between PRP and ERP (estimating result of Qi Zho et al) is also be calculated to comapre with my
model.

![poison_converge](/images/poison_converge.png)

![poison_cor](/images/poison_cor.png)

![poison_residual](/images/poison_residual.png)

![Results](/images/results.png)
