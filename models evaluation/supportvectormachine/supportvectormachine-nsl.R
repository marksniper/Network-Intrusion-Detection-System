library(e1071)
library(caret)
kdd_prediction <- read.csv("kdd_prediction_NSL.csv")
percentage = round(nrow(kdd_prediction) *70/100)
cat('There are ', percentage, 'necessary to divide KDD dataset in train (70%) in test (30%).')
train <- kdd_prediction[ (1:percentage), ]
test <- kdd_prediction[ ((percentage+1):nrow(kdd_prediction)), ]
dim(kdd_prediction)
dim(train)
dim(test)
#turn on profilng
Rprof()
#fit
fit_svm <- svm(factor(result) ~.,data = train, scale=FALSE)
svm.fitted = predict(fit_svm)
#table(svm.fitted)
#predict
svm_predict = predict(fit_svm,newdata = test)
#turn off profiling
Rprof(NULL) 
#print test result
test_result=table(svm_predict,test$result)
test_result
#get profiling informations
prof<-summaryRprof()
#print profiling informations
prof$by.total
#confusion matrix
confusionMatrix(factor(svm_predict), factor(test$result), mode = "everything")
library(pROC)
predictions <- as.numeric(as.numeric(factor(svm_predict)),as.numeric(test$result))
roc.multi <- multiclass.roc(test$result, predictions)
print(roc.multi)
rs <- roc.multi[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))
auc(roc.multi)
print(roc.multi[['rocs']])