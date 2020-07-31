# Packages ----------------------------------------------------------------

# if (!require("pacman")) install.packages("pacman")
# pacman::p_load(locfit)

library(locfit)

# Functions ---------------------------------------------------------------

CompEst <- function(
  x, # predictor variable
  y, # response variable
  numcenpts = 27, # number of points at which the local, pointwise estimates 
  # will be calculated; points will be equally spaced throughout the range of 
  # [-1,1]
  J = 2, # maximum derivative to be estimated; int in [0,3]
  deg = 2, # degree of local polynomial used for pointwise estimates; int >= J
  beta = 50, # compound estimation smoothing parameter; smaller is smoother
  h = 0.25 # local smoothing parameter; nearest neighbors fraction in (0,1)
)
{
  
  # making sure all integer args are integers
  numcenpts <- floor(numcenpts)
  J <- floor(J)
  deg <- floor(deg)
  
  # making sure deg >= J
  if (deg < J) {
    warning("deg arg must be >= J arg; deg set equal to J")
    deg <- J
  }
  
  # making sure x is confined to [-1,1]
  x <- (x - mean(range(x))) / ((1/2) * diff(range(x)))
  
  # calculating centering point locations from numcenpts
  cenpts <- seq(-1, 1, length.out = numcenpts + 1)
  cenpts <- cenpts[-1] - (1 / numcenpts)
  
  # calculating local fit pointwise estimates c0 - cJ
  local_pw <- lapply(
    0:J, 
    FUN = function(j) {
      temp <- locfit.raw(x, 
                         y, 
                         alpha = h, 
                         deg = deg, 
                         kern = "rect", 
                         deriv = rep(1, j), 
                         family = "gaussian", 
                         link = "ident")
      return(predict(temp, cenpts) / factorial(j))
    }
  )
  
  names(local_pw) <- paste0("c", 0:J)
  list2env(local_pw, envir = environment())
  
  # calculating pointwise estimates of mu and its derivatives
  dmu0 <- function(x) {
    switch(
      J + 1,
      c0,
      c0 + c1*(x - cenpts)^1,
      c0 + c1*(x - cenpts)^1 + c2*(x - cenpts)^2,
      c0 + c1*(x - cenpts)^1 + c2*(x - cenpts)^2 + c3*(x - cenpts)^3
    )
  }
  
  dmu1 <- function(x) {
    switch(
      J,
      c1,
      c1 + 2*c2*(x - cenpts)^1,
      c1 + 2*c2*(x - cenpts)^1 + 3*c3*(x - cenpts)^2
    )
  }
  
  dmu2 <- function(x) {
    switch(
      J - 1,
      2*c2,
      2*c2 + 6*c3*(x - cenpts)^1
    )
  }
  
  dmu3 <- function(x) {
    6*c3
  }
  
  # calculating smoothing weight function and its derivatives
  dW0 <- function(x) {
    f <- exp(-beta*(x - cenpts)^2)
    g <- sum(f)^-1
    return(
      f*g
    )
  }
  
  dW1 <- function(x) {
    f <- exp(-beta*(x - cenpts)^2)
    g <- sum(f)^-1
    df <- -2*beta*(x - cenpts)*f
    dg <- -g^2*sum(df)
    return(
      df*g + f*dg
    )
  }
  
  dW2 <- function(x) {
    f <- exp(-beta*(x - cenpts)^2)
    g <- sum(f)^-1
    df <- -2*beta*(x - cenpts)*f
    dg <- -g^2*sum(df)
    d2f <- -2*beta*f + df^2/f
    d2g <- 2*g^3*sum(df)^2 - g^2*sum(d2f)
    return(
      d2f*g + 2*df*dg + f*d2g
    )
  }
  
  dW3 <- function(x) {
    f <- exp(-beta*(x - cenpts)^2)
    g <- sum(f)^-1
    df <- -2*beta*(x - cenpts)*f
    dg <- -g^2*sum(df)
    d2f <- -2*beta*f + df^2/f
    d2g <- 2*g^3*sum(df)^2 - g^2*sum(d2f)
    d3f <- -6*beta*df + df^3/f
    d3g <- -6*g^4*sum(df)^3 + 6*g^3*sum(df)*sum(d2f) - g^2*sum(d3f)
    return(
      d3f*g + 3*d2f*dg + 3*df*d2g + f*d3g
    )
  }
  
  # calculating estimates of mu and its derivatives
  mu0est <- function(x) {
    dmu0(x)*dW0(x)
  }
  
  mu1est <- function(x) {
    dmu1(x)*dW0(x) + dmu0(x)*dW1(x)
  }
  
  mu2est <- function(x) {
    dmu2(x)*dW0(x) + 2*dmu1(x)*dW1(x) + dmu0(x)*dW2(x)
  }
  
  mu3est <- function(x) {
    dmu3(x)*dW0(x) + 3*dmu2(x)*dW1(x) + 3*dmu1(x)*dW2(x) + dmu0(x)*dW3(x)
  }
  
  mu <- lapply(
    0:J, 
    function(j) {
      switch(
        j + 1,
        apply(as.matrix(as.data.frame(lapply(x, mu0est), 
                                      col.names = 1:length(x))), 2, sum),
        apply(as.matrix(as.data.frame(lapply(x, mu1est), 
                                      col.names = 1:length(x))), 2, sum),
        apply(as.matrix(as.data.frame(lapply(x, mu2est), 
                                      col.names = 1:length(x))), 2, sum),
        apply(as.matrix(as.data.frame(lapply(x, mu3est), 
                                      col.names = 1:length(x))), 2, sum)
      )
    }
  )
  
  names(mu) <- paste0("mu", 0:J)
  return(mu)
}

# Test Example ------------------------------------------------------------

# Simulate toy data, with known derivatives
mu0sim <- function(x) {
  sin(2*pi*x) + 3*x^2
}

mu1sim <- function(x) {
  2*pi*cos(2*pi*x) + 6*x
}

mu2sim <- function(x) {
  -4*pi^2*sin(2*pi*x) + 6
}

mu3sim <- function(x) {
  -8*pi^3*cos(2*pi*x)
}

set.seed(2894)

n <- 2000
xx <- runif(n, -2, 2)
yy <- mu0sim(xx) + rnorm(n, sd = 1)
plot(xx, yy, pch = 20)
plot(mu0sim, add = T, from = -2, to = 2, col = "red", lwd = 3)

# J = 0, deg = 0

mu <- CompEst(x = xx, y = yy, J = 0, deg = 0)

# plot(xx, yy, pch = 20)
plot(mu0sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu0[order(xx)], col = "blue", lwd = 2)

# J = 1, deg = 1

mu <- CompEst(x = xx, y = yy, J = 1, deg = 1)

# plot(xx, yy, pch = 20)
plot(mu0sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu0[order(xx)], col = "blue", lwd = 2)


plot(mu1sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu1[order(xx)], col = "blue", lwd = 2)

# J = 2, deg = 2

mu <- CompEst(x = xx, y = yy, J = 2, deg = 2)

# plot(xx, yy)
plot(mu0sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu0[order(xx)], col = "blue", lwd = 2)

plot(mu1sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu1[order(xx)], col = "blue", lwd = 2)

plot(mu2sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu2[order(xx)], col = "blue", lwd = 2)

# J = 3, deg = 3

mu <- CompEst(x = xx, y = yy, J = 3, deg = 3)

# plot(xx, yy)
plot(mu0sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu0[order(xx)], col = "blue", lwd = 2)

plot(mu1sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu1[order(xx)], col = "blue", lwd = 2)

plot(mu2sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu2[order(xx)], col = "blue", lwd = 2)

plot(mu3sim, from = -2, to = 2, col = "red", lwd = 2)
lines(xx[order(xx)], mu$mu3[order(xx)], col = "blue", lwd = 2)

# Test Cases --------------------------------------------------------------

# J > 3
mu <- CompEst(x = xx, y = yy, J = 4, deg = 4) # creates empty mu4 object in output

# J < 0
mu <- CompEst(x = xx, y = yy, J = -1) # error in locfit call; rep(1,j) breaks

# deg < J
mu <- CompEst(x = xx, y = yy, J = 2, deg = 1) # warning works properly
