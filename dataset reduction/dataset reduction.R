#Load datasets
kdd <- read.csv("train_KDD_without_dulicated.csv")
nsl_kdd <- read.csv("train_NSl_KDD.csv")
#show dataset dimension
dim(kdd)
dim(nsl_kdd)
#check NA value
NAcol_KDD = 0
NAcol_nsl_KDD =0
NAcol_KDD <- which(colSums(is.na(kdd)) > 0)
NAcol_nsl_KDD <- which(colSums(is.na(nsl_kdd)) > 0)
print(NAcol_KDD)
print(NAcol_nsl_KDD)
#count numeric variables
numericVars <- which(sapply(kdd, is.numeric)) 
numericVarNames <- names(numericVars) 
cat('There are', length(numericVars), 'numeric variables')
#show factor variables
Charcol <- names(kdd[,sapply(kdd, is.factor)])
cat('There are', length(Charcol), 'remaining columns with factor values')
#corrplot KDD dataset
library(corrplot)
kdd_numVar2 <- kdd[,5:41]
correlation <- cor(kdd_numVar2)
corrplot(correlation, method="circle", na.label= '.')
kdd_without_features_correlated <- kdd[,-(24:41)]
which(sapply(kdd_without_features_correlated, is.factor))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, result=as.integer(result))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, flag=as.integer(flag))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, protocol_type=as.integer(protocol_type))
kdd_without_features_correlated <- transform(kdd_without_features_correlated,  service=as.integer(service))
correlation <- cor(kdd_without_features_correlated)
corrplot(correlation, method="circle", na.label= '.')
#corrplot NSL dataset
nsl_kdd2 <- nsl_kdd[,5:41]
correlation <- cor(nsl_kdd2)
corrplot(correlation, method="circle", na.label= '.')
kddNSL_without_features_correlated <- nsl_kdd[,-(24:41)]
which(sapply(kddNSL_without_features_correlated, is.factor))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, result=as.integer(result))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, flag=as.integer(flag))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, protocol_type=as.integer(protocol_type))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated,  service=as.integer(service))
correlation <- cor(kddNSL_without_features_correlated)
corrplot(correlation, method="circle", na.label= '.')
#scale kdd
kdd_without_features_correlated <- kdd[,-(24:41)]
mean <- apply(kdd_without_features_correlated[,(5:23)], 2, mean)
std <- apply(kdd_without_features_correlated[,(5:23)], 2, sd)
kdd_without_features_correlated[,(5:23)] <- scale(kdd_without_features_correlated[,(5:23)], center = mean, scale = std)
mean <- mean(kdd_without_features_correlated$duration)
std <- sd(kdd_without_features_correlated$duration)
kdd_without_features_correlated$duration <- scale(kdd_without_features_correlated$duration, center = mean, scale = std)
#scale nsl-kdd
kddNSL_without_features_correlated <- nsl_kdd[,-(24:41)]
mean <- apply(kddNSL_without_features_correlated[,(5:23)], 2, mean)
std <- apply(kddNSL_without_features_correlated[,(5:23)], 2, sd)
kddNSL_without_features_correlated[,(5:23)] <- scale(kddNSL_without_features_correlated[,(5:23)], center = mean, scale = std)
mean <- mean(kddNSL_without_features_correlated$duration)
std <- sd(kddNSL_without_features_correlated$duration)
kddNSL_without_features_correlated$duration <- scale(kddNSL_without_features_correlated$duration, center = mean, scale = std)
#data frame conversion
kdd_without_features_correlated <- data.frame(kdd_without_features_correlated)
kddNSL_without_features_correlated <- data.frame(kddNSL_without_features_correlated)
#show na value
NAcol_KDD = 0
NAcol_KDD <- which(colSums(is.na(kdd_without_features_correlated)) > 0)
NAcol_nsl_KDD =0
NAcol_nsl_KDD <- which(colSums(is.na(kddNSL_without_features_correlated)) > 0)
print(NAcol_KDD)
print(NAcol_nsl_KDD)
#data frame conversion
kdd_without_features_correlated <- data.frame(kdd_without_features_correlated)
kddNSL_without_features_correlated <- data.frame(kddNSL_without_features_correlated)
#delete Na features
kdd_without_features_correlated <- kdd_without_features_correlated[ ,-(20:21)]
kddNSL_without_features_correlated <- kddNSL_without_features_correlated[ ,-(20)]
#see na value after manupilation
NAcol_KDD = 0
NAcol_nsl_KDD =0
NAcol_KDD <- which(colSums(is.na(kdd_without_features_correlated)) > 0)
NAcol_nsl_KDD <- which(colSums(is.na(kddNSL_without_features_correlated)) > 0)
print(NAcol_KDD)
print(NAcol_nsl_KDD)

kdd_without_features_correlated <- data.frame(kdd_without_features_correlated)
kddNSL_without_features_correlated <- data.frame(kddNSL_without_features_correlated)
#remove unseuful attributes KDD
attr(kdd_without_features_correlated$duration, "scaled:scale") <- NULL
attr(kdd_without_features_correlated$duration, "scaled:center") <- NULL
#remove unseuful attributes KDD-NSL
attr(kddNSL_without_features_correlated$duration, "scaled:scale") <- NULL
attr(kddNSL_without_features_correlated$duration, "scaled:center") <- NULL
#save kdd dataset for prediction
write.csv(kdd_without_features_correlated,file = "kdd_for_prediction.csv",row.names = F)
#save kdd-NSl dataset for prediction
write.csv(kddNSL_without_features_correlated,file = "kddNSL_for_prediction.csv",row.names = F)
#Finding variable importance with a quick Random Forest
set.seed(2018)
library(randomForest)
library(caret)
kdd_without_features_correlated <- data.frame(kdd_without_features_correlated)
kddNSL_without_features_correlated <- data.frame(kddNSL_without_features_correlated)
#transform in numeric and scaling kdd
kdd_without_features_correlated <- kdd[,-(24:41)]
which(sapply(kdd_without_features_correlated, is.factor))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, result=as.integer(result))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, flag=as.integer(flag))
kdd_without_features_correlated <- transform(kdd_without_features_correlated, protocol_type=as.integer(protocol_type))
kdd_without_features_correlated <- transform(kdd_without_features_correlated,  service=as.integer(service))

mean <- apply(kdd_without_features_correlated, 2, mean)
std <- apply(kdd_without_features_correlated, 2, sd)
kdd_without_features_correlated <- scale(kdd_without_features_correlated, center = mean, scale = std)

#quick rf for kdd
quick_RF <- randomForest(x=kdd_without_features_correlated[1:1500 ,-(22)], y=kdd_without_features_correlated$result[1:1500], ntree=100,importance=TRUE)
imp_RF <- importance(quick_RF)
imp_DF <- data.frame(Variables = row.names(imp_RF), MSE = imp_RF[,1])
imp_DF <- imp_DF[order(imp_DF$MSE, decreasing = TRUE),]

ggplot(imp_DF[1:20,], aes(x=reorder(Variables, MSE), y=MSE, fill=MSE)) + geom_bar(stat = 'identity')+
  labs(x = "Variables", y= "% increase MSE if variable is randomly permuted") + coord_flip() + 
  theme(legend.position="none")
#transform in numeric and scaling kdd-nsl
kddNSL_without_features_correlated <- nsl_kdd[,-(24:41)]
which(sapply(kddNSL_without_features_correlated, is.factor))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, result=as.integer(result))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, flag=as.integer(flag))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated, protocol_type=as.integer(protocol_type))
kddNSL_without_features_correlated <- transform(kddNSL_without_features_correlated,  service=as.integer(service))

mean <- apply(kddNSL_without_features_correlated, 2, mean)
std <- apply(kddNSL_without_features_correlated, 2, sd)
kddNSL_without_features_correlated <- scale(kddNSL_without_features_correlated, center = mean, scale = std)
#quick rf for kdd-NSL
quick_RF <- randomForest(x=kddNSL_without_features_correlated[1:1500 ,-(23)], y=kddNSL_without_features_correlated$result[1:1500], ntree=100,importance=TRUE)
imp_RF <- importance(quick_RF)
imp_DF <- data.frame(Variables = row.names(imp_RF), MSE = imp_RF[,1])
imp_DF <- imp_DF[order(imp_DF$MSE, decreasing = TRUE),]

ggplot(imp_DF[1:20,], aes(x=reorder(Variables, MSE), y=MSE, fill=MSE)) + geom_bar(stat = 'identity')+
  labs(x = "Variables", y= "% increase MSE if variable is randomly permuted") + coord_flip() + 
  theme(legend.position="none")