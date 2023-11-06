library(imputeTS)
library(glmnet)

#---------------------------- clean data -------------------------
raw_data <- read.csv("data.csv")
norm_data <- na_mean(raw_data)
cleaned_data <- subset(norm_data, hours > 0 & emp == 1)
#--------------------------- Gender Gap in 2005 -----------------------
data_2005 <- subset(cleaned_data, year == 2005)
D <- data_2005$female

W <- model.matrix(
  ~ 0 + (
    IQ + tenure + married + south +
      poly(age, 3) + poly(educ, 3) + poly(exper, 3)
  ) ^ 3,
  data = data_2005)
  W <-
    W[, which(apply(W, 2, var) != 0)] # exclude all constant variables
  demean <- function (x) {
    x - mean(x)
  }
  W <- apply(W, 2, FUN = demean)
  
#
Y <- log(data_2005$wage / data_2005$hours)

# double LASSO estimator

# partial out W from Y
fit.lasso.Y <- cv.glmnet(W, Y)
fitted.lasso.Y <- predict(fit.lasso.Y, newx=W, s="lambda.min")
Ytilde <- Y - fitted.lasso.Y

# partial out W from D
fit.lasso.D <- cv.glmnet(W, D)
fitted.lasso.D <- predict(fit.lasso.D, newx=W, s="lambda.min")
Dtilde <- D - fitted.lasso.D

# run OLS of Ytilde on Dtilde
fit.doubleLASSO <- lm(Ytilde ~ Dtilde)
beta1hat <- coef(fit.doubleLASSO)[2]
print(beta1hat)
#------------------------ Gender pay Gap 2010 -----------------------------
data_2010 <- subset(cleaned_data, year == 2010)
D <- data_2010$female

# create predictors
W <- model.matrix(
  ~ 0 + (
    IQ + tenure + married + south +
      poly(age, 3) + poly(educ, 3) + poly(exper, 3)
  ) ^ 3,
  data = data_2010)
W <-
  W[, which(apply(W, 2, var) != 0)] # exclude all constant variables
demean <- function (x) {
  x - mean(x)
}
W <- apply(W, 2, FUN = demean)
Y <- log(data_2010$wage / data_2010$hours)

# double LASSO estimator

# partial out W from Y
fit.lasso.Y <- cv.glmnet(W, Y)
fitted.lasso.Y <- predict(fit.lasso.Y, newx=W, s="lambda.min")
Ytilde <- Y - fitted.lasso.Y

# partial out W from D
fit.lasso.D <- cv.glmnet(W, D)
fitted.lasso.D <- predict(fit.lasso.D, newx=W, s="lambda.min")
Dtilde <- D - fitted.lasso.D

# run OLS of Ytilde on Dtilde
fit.doubleLASSO <- lm(Ytilde ~ Dtilde)
beta1hat <- coef(fit.doubleLASSO)[2]
print(beta1hat)
