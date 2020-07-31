# Packages ----------------------------------------------------------------

library(caret)
library(glmnet)
library(mgcv)
options(java.parameters = "-Xmx8g")
library(extraTrees)
library(tidyverse)

# Data Cleaning -----------------------------------------------------------

raw <- foreign::read.arff("Data/messidor_features.arff")

VIM::aggr(raw) # no missing data

table(raw$`0`) # 4 images with "poor quality"

dat <- raw %>% 
  filter(`0` == 1) %>% # drop poor quality images
  select("DR" = Class, # outcome: Diabetic Retinopathy
         "AMFM" = `18`, # AM/FM prediction of DR
         "PRE" = `1`, # Pre-screening retinal issues
         "DMD" = `16`, # Optic Disk-Macula Distance
         "ODD" = `17`, # Optic Disk Diameter
         "MA1" = `2`, # Microaneurysm count at differing confidence levels
         "MA2" = `3`, # (higher = more conservative)
         "MA3" = `4`,
         "MA4" = `5`,
         "MA5" = `6`,
         "MA6" = `7`,
         "EX1" = `8`, # Exudate count at differing confidence levels
         "EX2" = `9`, # (higher = more conservative)
         "EX3" = `10`,
         "EX4" = `11`,
         "EX5" = `12`,
         "EX6" = `13`,
         "EX7" = `14`,
         "EX8" = `15`) %>% 
  mutate(AMFM = as.factor(AMFM),
         PRE = as.factor(PRE))

hist(dat[, 13])

dat[, 6:19] <- dat[, 6:19] %>% 
  mutate_all(.funs = function(x) log(1 + x))

hist(dat[, 13])

Y <- dat$DR

set.seed(2894)
train.index <- createDataPartition(Y, p = 0.6, list = F)
test.index <- createDataPartition(Y[-train.index], p = 0.5, list = F)

train <- dat[train.index, ]
not.train <- dat[-train.index, ]
test <- not.train[test.index, ]
valid <- not.train[-test.index, ]

Y_train <- train$DR
X_train <- train[, -1]

Y_test <- test$DR
X_test <- test[, -1]

Y_valid <- valid$DR
X_valid <- valid[, -1]

# Penalized Logistic Regression -------------------------------------------

# glmnet.tc <- trainControl(method = "cv", number = 5)
# glmnet.grid <- expand.grid(alpha = seq(0, 1, 0.05),
#                            lambda = seq(0.00001, 0.01, length.out = 50))
# 
# (glmnet.caret <- train(x = data.matrix(X_train), y = Y_train,
#                        family = "binomial", method = "glmnet", trControl = glmnet.tc, 
#                        tuneGrid = glmnet.grid))
# 
# View(glmnet.caret$results %>% group_by(alpha) %>% summarize(m = mean(Accuracy)))

glmnet.cv <- cv.glmnet(x = data.matrix(X_train), y = Y_train, family = "binomial", 
               alpha = 1)

glmnet.mod <- glmnet(x = data.matrix(X_train), y = Y_train, family = "binomial", 
       alpha = 1, lambda = glmnet.cv$lambda.min)

#plot(glmnet.mod, xvar = "lambda")
#abline(v = log(glmnet.cv$lambda.min), col = "gray")

# GAM GAM -----------------------------------------------------------------

gam.mod <- gam(DR ~ AMFM + PRE + s(DMD) + s(ODD) + s(MA1) + s(MA2) + s(MA3) + s(MA4) + 
                 s(MA5) + s(MA6) + s(EX1) + s(EX2) + s(EX3) + s(EX4) + s(EX5) + s(EX6) + 
                 s(EX7) + s(EX8), data = train, family = binomial)

# Random Forest -----------------------------------------------------------

rf.tc <- trainControl(method = "cv", number = 5)
# rf.grid <- expand.grid(mtry = 1:5, numRandomCuts = 1:5)
# 
# set.seed(2894)
# (rf.mod <- train(DR ~ ., data = train, method = "extraTrees", trControl = rf.tc,
#                   tuneGrid = rf.grid, nodesize = 20))

set.seed(2894)
(rf.mod <- train(DR ~ ., data = train, method = "extraTrees", trControl = rf.tc,
                tuneGrid = data.frame(mtry = 5, numRandomCuts = 2), nodesize = 20))

# Test Accuracy -----------------------------------------------------------     
cutoff <- 0.5

glmnet.pred <- predict(glmnet.mod, newx = data.matrix(X_test), type = "response")
glmnet.pred <- as.factor(as.numeric(glmnet.pred > cutoff))

(glmnet.cm <- confusionMatrix(glmnet.pred, Y_test, positive = "1")) 
# 0.7729, 0.7787, 0.7664

gam.pred <- predict(gam.mod, newdata = X_test, type = "response")
gam.pred <- as.factor(as.numeric(gam.pred > cutoff))

(gam.cm <- confusionMatrix(gam.pred, Y_test, positive = "1")) 
# 0.7817, 0.7787, 0.7850

rf.pred <- predict(rf.mod, newdata = X_test, type = "prob")
rf.pred <- as.factor(as.numeric(rf.pred$`1` > cutoff))

(rf.cm <- confusionMatrix(rf.pred, Y_test, positive = "1")) 
# 0.7467, 0.7458, 0.7477

# Get Stacked -------------------------------------------------------------

glmnet.valid <- as.numeric(predict(glmnet.mod, newx = data.matrix(X_valid), 
                                   type = "response"))

gam.valid <- predict(gam.mod, newdata = X_valid, type = "response")

rf.valid <- predict(rf.mod, newdata = X_valid, type = "prob")
rf.valid <- rf.valid$`1`

ensemble.dat <- data.frame(Y = Y_valid, glmnet = glmnet.valid, gam = gam.valid, 
                           rf = rf.valid)

(ensemble.mod <- glm(Y ~ glmnet + gam + rf, data = ensemble.dat, family = "binomial"))

glmnet.pred.prob <- as.numeric(predict(glmnet.mod, newx = data.matrix(X_test), 
                                       type = "response"))

gam.pred.prob <- predict(gam.mod, newdata = X_test, type = "response")

rf.pred.prob <- predict(rf.mod, newdata = X_test, type = "prob")
rf.pred.prob <- rf.pred.prob$`1`

ensemble.dat.test <- data.frame(glmnet = glmnet.pred.prob, gam = gam.pred.prob, 
                                rf = rf.pred.prob)

ensemble.pred <- predict(ensemble.mod, newdata = ensemble.dat.test, type = "response")
ensemble.pred <- as.factor(as.numeric(ensemble.pred > cutoff))

(ensemble.cm <- confusionMatrix(ensemble.pred, Y_test, positive = "1")) 
# 0.7773, 0.7869, 0.7664

# Prediction Averaging ----------------------------------------------------

pred.matrix <- rbind(glmnet.pred.prob, gam.pred.prob, rf.pred.prob)
ave.pred <- as.factor(as.numeric(colMeans(pred.matrix) > cutoff))

glmnet.valid <- as.factor(as.numeric(glmnet.valid > cutoff))
gam.valid <- as.factor(as.numeric(gam.valid > cutoff))
rf.valid <- as.factor(as.numeric(rf.valid > cutoff))

glmnet.acc.valid <- confusionMatrix(glmnet.valid, Y_valid, positive = "1")$overall[1]
gam.acc.valid <- confusionMatrix(gam.valid, Y_valid, positive = "1")$overall[1]
rf.acc.valid <- confusionMatrix(rf.valid, Y_valid, positive = "1")$overall[1]

wt <- c(glmnet.acc.valid, gam.acc.valid, rf.acc.valid) / (glmnet.acc.valid + gam.acc.valid +
                                                            rf.acc.valid)

weighted.pred <- apply(pred.matrix, MARGIN = 2, FUN = function(x) weighted.mean(x, w = wt))

weighted.pred <- as.factor(as.numeric(weighted.pred > cutoff))

(ave.cm <- confusionMatrix(ave.pred, Y_test, positive = "1")) 
# 0.7729, 0.7869, 0.7570
(weighted.cm <- confusionMatrix(weighted.pred, Y_test, positive = "1")) 
# 0.7773, 0.7869, 0.7664