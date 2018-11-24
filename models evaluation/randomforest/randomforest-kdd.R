library(caret)
kdd_prediction <- read.csv("kdd_prediction.csv")
#cross validation 70% train 30% test
percentage = round(nrow(kdd_prediction) *70/100)
cat('There are ', percentage, 'necessary to divide KDD dataset in train (70%) in test (30%).')
train <- kdd_prediction[ (1:percentage), ]
test <- kdd_prediction[ (percentage:nrow(kdd_prediction)), ]
#turn on profilng
Rprof()
modFit <- train(result ~ .,method="rf",data=train)
modFit
## Prediction
pred <- predict(modFit,test); 
test$predRight <- pred==test$result
#turn off profiling
Rprof(NULL) 
#print test result
test_result=table(pred,test$result)
test_result
#get profiling informations
prof<-summaryRprof()
#print profiling informations
prof$by.total
#confusion matrix
confusionMatrix(factor(pred), factor(test$result), mode = "everything")
library(pROC)
predictions <- as.numeric(as.numeric(factor(pred)),as.numeric(factor(test$result)))
roc.multi <- multiclass.roc(test$result, predictions)
print(roc.multi)
rs <- roc.multi[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))
auc(roc.multi)
print(roc.multi[['rocs']])