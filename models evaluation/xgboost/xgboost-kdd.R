library(xgboost)
library(dplyr)
library(caret)
kdd_prediction <- read.csv("kdd_prediction.csv")
#transform factor variable in numeric variable
which(sapply(kdd_prediction, is.factor))
kdd_prediction <- transform(kdd_prediction, flag=as.integer(flag)) 
kdd_prediction <- transform(kdd_prediction, protocol_type=as.integer(protocol_type)) 
kdd_prediction <- transform(kdd_prediction,  service=as.integer(service)) 
#cross validation 70% train 30% test
percentage = round(nrow(kdd_prediction) *70/100)
cat('There are ', percentage, 'necessary to divide KDD dataset in train (70%) in test (30%).')
train <- kdd_prediction[ (1:percentage), ]
test <- kdd_prediction[ (percentage:nrow(kdd_prediction)), ]
#keep name of attack before integer transform
table(as.numeric(kdd_prediction$result), kdd_prediction$result)
train_labs <- as.numeric(train$result) - 1
val_labs <- as.numeric(test$result) - 1
new_train <- model.matrix(~ .+0,data = train[,-22])
new_val <- model.matrix(~ .+0,data = test[,-22])
#preparate matrices
xgb_train <- xgb.DMatrix(data = new_train, label = train_labs)
xgb_val <- xgb.DMatrix(data = new_val, label = val_labs)
# Set parameters(default)
params <- list(booster = "gbtree", objective = "multi:softprob", num_class = 5, eval_metric = "mlogloss")
#watchlist
watchlist <- list(train=xgb_train)
#turn on profilng
Rprof()
#fit model
xgb_model <- xgb.train(params = params, data = xgb_train, nrounds=200, watchlist=watchlist,nthread=4)
# Predict for validation set
xgb_val_preds <- predict(xgb_model, newdata = xgb_val)
#turn off profiling
Rprof(NULL) 
#change data for classification method
xgb_val_out <- matrix(xgb_val_preds, nrow = 5, ncol = length(xgb_val_preds) / 5) %>% 
  t() %>%
  data.frame() %>%
  mutate(max = max.col(., ties.method = "last"), label = val_labs + 1) 
table(as.numeric(kdd_prediction$result), kdd_prediction$result)
trans <- c("dos","normal","probe","r2l","u2r")
names(trans) <- c(1,2,3,4,5)
# Now translate the values into a new column and print it out 
xgb_val_out$labelfactor <- trans[ as.character(xgb_val_out$label) ]
xgb_val_out$maxfactor <- trans[ as.character(xgb_val_out$max) ]
# Automated confusion matrix 
xgb_conf_mat_2 <- confusionMatrix(factor(xgb_val_out$maxfactor),
                                  factor(test$result),
                                  mode = "everything")

print(xgb_conf_mat_2)

#get profiling informations
prof<-summaryRprof()
#print profiling informations
prof$by.total
library(pROC)
predictions <- as.numeric(as.numeric(factor(xgb_val_out$maxfactor)),as.numeric(factor(test$result)))
roc.multi <- multiclass.roc(test$result, predictions)
rs <- roc.multi[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))
auc(roc.multi)
print(roc.multi[['rocs']])