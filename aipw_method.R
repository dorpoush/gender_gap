library(imputeTS)
library(glmnet)

# import and clean data
raw_data <- read.csv("./data.csv")
norm_data <- na_mean(raw_data)
cleaned_data <- subset(norm_data, hours > 0 & emp == 1)

#------------------------- Propensity Score ------------------------
# define X = all covariates except wage, emp and Y = treat for PS
X_ps <-
  model.matrix( ~ 0 + (
    female + IQ + tenure + married + urban + black +
      poly(age, 3) + poly(educ, 3) + poly(exper, 3)
  ) ^ 3,
  data = cleaned_data)
Y_ps <- cleaned_data$treat

# calculating Propensity Score
fit.lasso <- cv.glmnet(X_ps, Y_ps, nfolds=3)
ps <- predict(fit.lasso, newx=X_ps, s="lambda.min") %>% as.numeric 

#------------------------- Expectations ------------------------
# define X = all covariates and Y = wage

X <-
  model.matrix(
    ~ 0 + (
      treat + female + IQ + tenure + married + south +
        poly(age, 3) + poly(educ, 3) + poly(exper, 3)
    ) ^ 3,
    data = cleaned_data
  )
Y <- log(cleaned_data$wage / cleaned_data$hours)

# extracting treated and untreated records
treated <- X[cleaned_data$treat == 1 & cleaned_data$year == 2010, ]
untreated <- X[cleaned_data$treat == 0 & cleaned_data$year == 2010, ]

# calculating the expectations
mu_i<- cv.glmnet(X, Y, nfolds=3)
mu_1 <- mean(predict(mu_i, newx=treated, s="lambda.min"))
mu_0 <- mean(predict(mu_i, newx=untreated, s="lambda.min"))

#------------------------ AIPW ---------------------------
# define aipw function
aipw <- function(D, Y, ps, mu_1, mu_0) {
  mean(((D * Y) / ps - (1 - D) * Y / (1 - ps)) - (D - ps) / (ps * (1 - ps)) *
         ((1 - ps) * mu_1 + ps * mu_0))
} 
aipw(
  D = cleaned_data$treat,
  ps = ps,
  Y = Y,
  mu_1 = mu_1,
  mu_0 = mu_0
)
#------------------CATE--------------------------
# define Psi
psi <-function(D, Y, ps, mu_1, mu_0) {
 ((D * Y) / ps - (1 - D) * Y / (1 - ps)) - (D - ps) / (ps * (1 - ps)) *
         ((1 - ps) * mu_1 + ps * mu_0)
} 
est_psi <- psi(
  D = cleaned_data$treat,
  ps = ps,
  Y = Y,
  mu_1 = mu_1,
  mu_0 = mu_0
)
# estimate CATE
ols <- lm(est_psi ~  female , data = cleaned_data)
summary(ols)
