library(neuralnet)
library(caret)
library(ggplot2)
kdd_prediction <- read.csv("kdd_prediction.csv")
#transform factor variable in numeric variable
which(sapply(kdd_prediction, is.factor))
kdd_prediction <- transform(kdd_prediction, flag=as.integer(flag)) 
kdd_prediction <- transform(kdd_prediction, protocol_type=as.integer(protocol_type)) 
kdd_prediction <- transform(kdd_prediction,  service=as.integer(service)) 
#keep name of attack before integer transform
table(as.numeric(kdd_prediction$result), kdd_prediction$result)
trans <- c("dos","normal","probe","r2l","u2r")
names(trans) <- c(1,2,3,4,5)
#transform factor variable in numeric and scaling
kdd_prediction_numeric <- kdd_prediction
kdd_prediction_numeric <- transform(kdd_prediction, result=as.integer(result)) 
scl <- function(x){ (x - min(x))/(max(x) - min(x)) }
kdd_prediction_numeric <- data.frame(lapply(kdd_prediction_numeric, scl))
#delete NAN value
kdd_prediction_numeric <- kdd_prediction_numeric[colSums(!is.na(kdd_prediction_numeric)) > 0]
#cross validation
percentage = round(nrow(kdd_prediction_numeric) *70/100)
cat('There are ', percentage, 'necessary to divide KDD dataset in train (70%) in test (30%).')
train <- kdd_prediction_numeric[ (1:percentage), ]
test <- kdd_prediction_numeric[ (percentage:nrow(kdd_prediction_numeric)), ]
#print dim train and test
dim(train)
dim(test)
#turn on profiling
Rprof()
#fit neural net
n <- names(train[, -ncol((train))])
f <- as.formula(paste("result ~", paste(n, collapse = " + ")))
print(f)
nn <- neuralnet(f,data=train,hidden=c(15,10,5,3),linear.output=F, threshold=0.1)
plot(nn)
pr.nn <- compute(nn,test[, -ncol(test)])
#turn off profiling
Rprof(NULL) 
pr.nn_ <- pr.nn$net.result*(max(kdd_prediction_numeric$result)-min(kdd_prediction_numeric$result))+min(kdd_prediction_numeric$result)
test.r <- (test$result)*(max(kdd_prediction_numeric$result)-min(kdd_prediction_numeric$result))+min(kdd_prediction_numeric$result)
#graph with ggplot
graph_result <- data.frame(test.r,pr.nn_)
ggplot(graph_result, aes(x=graph_result$test.r, y=graph_result$pr.nn_)) +
  geom_point(colour = "black", size = 3)+
  xlab("Type of attacks in test")+
  ylab("Type of attacks predict")+
  scale_x_continuous(labels=c("0" = "DoS", "0.25" = "Normal",
                              "0.5" = "Probe", "0.75" = "r2l","1" = "u2r"))
MSE.nn <- sum((test.r - pr.nn_)^2)/nrow(test)
MSE.nn
# round numbers according to a fixed interval
# Multiple
mult <- .25   
pr.nn_round <- round(mult*round(pr.nn_[,1]/mult), digits =2)
pr.nn_round <- pr.nn_round*4+1
test.r <- test.r*4+1
pr.nn_round <- trans[ as.character(pr.nn_round) ]
test.r <- trans[ as.character(test.r) ]
#pr.nn_round <- pr.nn_round[ !is.na(pr.nn_round)]
length(pr.nn_round)
length(test.r)
confusionMatrix(factor(pr.nn_round), factor(test.r), mode = "everything")
#get profiling informations
prof<-summaryRprof()
#print profiling informations
prof$by.total
library(pROC)
predictions <- as.numeric(as.numeric(factor(pr.nn_round)),as.numeric(factor(test.r)))
roc.multi <- multiclass.roc(test$result, predictions)
print(roc.multi)
rs <- roc.multi[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))
auc(roc.multi)
print(roc.multi[['rocs']])
