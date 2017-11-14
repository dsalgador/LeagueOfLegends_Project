########################
#Model fitting  
########################
setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")

model = 1
if (model == 1){
  train_data <- read.csv("train_data.csv")
  test_data <- read.csv("test_data.csv")
} else if (model == 2){
 train_data <- read.csv("train_data_2ndmodel.csv")
test_data <- read.csv("test_data_2ndmodel.csv") 
} else {
  print("Invalid model number (only 1 or 2 allowed)")}


withoutChampiongginfo <- T
if(withoutChampiongginfo){
  train_data <- train_data[, c(1:3, 9:13)]
  test_data <- test_data[, c(1:3, 9:13)]
}

avoid_0and1 <- F
if(avoid_0and1){
  results <- train_data$result
  wr_min = 0.25
  wr_max = 0.75
  train_data[ train_data == 0] <- wr_min
  train_data[ train_data == 1] <- wr_max
  train_data$result = results
  }

#when SF, F, and QF was not available:
# train <- train_data[1:150,]
# test <- train_data[151:180,]
train <- train_data
test <- test_data


if(model == 1){
  model1 <- glm(result ~.,family=binomial(link='logit'),data=train)
  
}else if (model == 2){
  model2 <- glm(result ~.,family=binomial(link='logit'),data=train)
  
}

model <- glm(result ~.,family=binomial(link='logit'),data=train)
summary(model)

#########################
#Interpreting the results of our logistic regression model
###############################

#we can run the anova() function on the model to analyze the table of deviance
anova(model, test="Chisq")
#A large p-value here indicates that the model without the variable explains more or less the same amount of variation. 
#install.packages("pscl")
library(pscl)

#While no exact equivalent to the R2 of linear regression exists, the McFadden R2 index can be used to assess the model fit.
pR2(model)


#########################
#Assessing the predictive ability of the model
############################
#All
#test
#Quarter finals
#test <- test[1:34,]
#Semi finals
#test <- test[35:52,] 

#Final
#test <- tail(test)


fitted.results <- predict(model,newdata=test,type='response')
num_results <- length(fitted.results)
for(i in seq(1,num_results, 2) ){
  fitted.results[i] <- ifelse(fitted.results[i]>fitted.results[i+1],1,0)
  fitted.results[i+1] <- abs(fitted.results[i]-1)
}
#fitted.results <- ifelse(fitted.results > 0.5,1,0)



misClasificError <- mean(fitted.results != test$result) #proportion of failures 
print(paste('Accuracy',1-misClasificError)) #proportion of right predictions


library(ROCR)
p <- predict(model, newdata=test, type="response")
pr <- prediction(p, test$result)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc


#varImp(model)

###########################
#############################
anova(model1, model2, test ="Chisq")

library(lmtest)
#install.packages("lmtest")
lrtest(model1, model2)


quiniela <- read.csv("quniela_qf_smf_f.txt", header = F)
colnames(quiniela) <- c("name", "people", "percentage", "points")
quiniela <- as.data.table(quiniela)
quiniela[, accuracy:=points/40]
quiniela[, percentage:=percentage/100]

mean_accuracy <- 0
for(i in 1:9){
  mean_accuracy = mean_accuracy + quiniela[i,"percentage"] * quiniela[i,"accuracy"]
}

###To print for the report:
train_data_print <- head(train_data ,2)
train_data_print[, 4:13] <- round(train_data_print[, 4:13],2)
