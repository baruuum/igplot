# short unit-test for procrustes analysis
library(igplot)

# rotation
theta = runif(1L, -2 * pi, 2 * pi)
Rstar = matrix(
    c(cos(theta), sin(theta), -1.0 * sin(theta), cos(theta)), 
    nrow = 2, ncol = 2
)

# translation
tstar = c(runif(2L, -1, 1))

# scaling
sstar = runif(1L, .2, 2)

# target
n = 20; k = 2
Xstar = matrix(
    rnorm(n*k), 
    n,
    k
)

# distorted matrix
X = sstar * sweep(Xstar, 2L, tstar, "+") %*% Rstar


# get procrustes transform
res = procrustes(X, Xstar)

# check results
expect_equal(res, Xstar)

