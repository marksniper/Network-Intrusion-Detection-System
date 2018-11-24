library(keras)
library(caret)
kdd_prediction <- read.csv("kdd_prediction.csv")
#one hot encoding
table(as.numeric(kdd_prediction$result), kdd_prediction$result)
trans <- c("dos","normal","probe","r2l","u2r")
names(trans) <- c(1,2,3,4,5)
which(sapply(kdd_prediction, is.factor))
kdd_prediction <- transform(kdd_prediction, flag=as.integer(flag)) 
kdd_prediction <- transform(kdd_prediction, protocol_type=as.integer(protocol_type)) 
kdd_prediction <- transform(kdd_prediction,  service=as.integer(service)) 
kdd_prediction_numeric <- kdd_prediction
kdd_prediction_numeric <- transform(kdd_prediction, result=as.integer(result))
kdd_prediction_numeric1 <- kdd_prediction_numeric
#scaling value
scl <- function(x){ (x - min(x))/(max(x) - min(x)) }
kdd_prediction_numeric <- data.frame(lapply(kdd_prediction_numeric, scl))
#delete NAN's values
kdd_prediction_numeric <- kdd_prediction_numeric[colSums(!is.na(kdd_prediction_numeric)) > 0]
kdd_prediction_numeric$result <- kdd_prediction_numeric1$result
#cross validation
percentage = round(nrow(kdd_prediction_numeric) *50/100)
cat('There are ', percentage, 'necessary to divide KDD dataset in train (70%) in test (30%).')
train <- kdd_prediction_numeric[ (1:percentage), ]
test <- kdd_prediction_numeric[ (percentage:nrow(kdd_prediction_numeric)), ]
#print dim train and test
dim(train)
dim(test)
#ecnoding data
matrix_train <- as.matrix(train[, -ncol(train)])
matrix_test <- as.matrix(test[, -ncol(test)])
train_label <- train$result
test_label <- test$result

one_hot_train_labels <- to_categorical(train_label)
one_hot_test_labels <- to_categorical(test_label)
head(test_label)
head(one_hot_test_labels)
#fit first model
model <- keras_model_sequential() %>%
  model <- keras_model_sequential() %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001),  input_shape = c(ncol(train)-1)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1024, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1024, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 512, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 512, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 6, activation = "softmax")
model %>% compile(
  optimizer = "rmsprop",
  loss = "categorical_crossentropy",
  metrics = c("accuracy")
)
val_indices <- 1:200
x_val <- matrix_train[val_indices,]
partial_x_train <- matrix_train[-val_indices,]
y_val <- one_hot_train_labels[val_indices,]
partial_y_train = one_hot_train_labels[-val_indices,]
history <- model %>% fit(
  partial_x_train,
  partial_y_train,
  epochs = 200,
  batch_size = 512,
  validation_data = list(x_val, y_val)
)
plot(history)

#turn on profilng
Rprof()
#fit 
model <- keras_model_sequential() %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001),  input_shape = c(ncol(train)-1)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1024, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 1024, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 1024, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 512, activation = "relu",   kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 512, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dense(units = 6, activation = "softmax")
model %>% compile(
  optimizer = "rmsprop",
  loss = "categorical_crossentropy",
  metrics = c("accuracy")
)
history <- model %>% fit(
  partial_x_train,
  partial_y_train,
  epochs = 15,
  batch_size = 512,
  validation_data = list(x_val, y_val)
)

results <- model %>% evaluate(matrix_test, one_hot_test_labels)
#predict
predictions <- model %>% predict(matrix_test)
#turn off profiling
Rprof(NULL)
#get prediction information
head(predictions)
dim(predictions)
sum(predictions[1,])
which.max(predictions[1,])
result_predict <- apply(predictions,1,function(x) which(x==max(x)))
result_predict <- result_predict -1
#reversing one hot encoding
attack_predict <- trans[ as.character(result_predict) ]
#get profiling informations
prof<-summaryRprof()
#print profiling informations
prof$by.total
#confusion matrix
one_hot_test_ <- apply(one_hot_test_labels,1,function(x) which(x==max(x)))
one_hot_test_ <- one_hot_test_ -1 
attack_test<- trans[ as.character(one_hot_test_) ]
confusionMatrix(factor(attack_predict), factor(attack_test), mode = "everything")
#table (attack_predict, attack_test)
library(pROC)
predictions <- as.numeric(as.numeric(factor(attack_predict)),as.numeric(factor(attack_test)))
roc.multi <- multiclass.roc(test$result, predictions)
print(roc.multi)
rs <- roc.multi[['rocs']]
plot.roc(rs[[1]])
sapply(2:length(rs),function(i) lines.roc(rs[[i]],col=i))
auc(roc.multi)
print(roc.multi[['rocs']])