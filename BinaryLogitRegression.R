########################
#Model fitting  
########################
setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")
library(ROCR)

train_data <- read.csv("train_data.csv")
test_data <- read.csv("test_data.csv")

withTeamsinfo <- F #1
withSideinfo <- T  #1
withChampiongginfo <-T #5
withPlayerinfo <- T

field_names <- names(train_data)
selected_fields <- c(field_names[1])
if(withTeamsinfo){selected_fields <- c(selected_fields, field_names[2] )}
if(withSideinfo){selected_fields <- c(selected_fields, field_names[3] )}
if(withChampiongginfo){selected_fields <- c(selected_fields, field_names[4:8] )}
if(withPlayerinfo){selected_fields <- c(selected_fields, field_names[9:13] )}

train_data <- subset(train_data, select = selected_fields)

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


library(aod)
#install.packages("aod")

####CIs
confint(model)
confint.default(model)

names(model$coefficients)

if(withTeamsinfo & withSideinfo & withChampiongginfo & withPlayerinfo){
  ##WALD TEST: http://www.statisticshowto.com/wald-test/
  #Overall effect of team names
  wald.test(b = coef(model), Sigma = vcov(model), Terms = 2:24)
  
  #Overall effect of side of the map
  wald.test(b = coef(model), Sigma = vcov(model), Terms = 25)
  
  #Overall effect of matchup_champion win rates
  wald.test(b = coef(model), Sigma = vcov(model), Terms = 26:30)
  wald.test(b = coef(model), Sigma = vcov(model), Terms = c(26,27,29,30))
  
  #Overall effect of player_champion win rates
  wald.test(b = coef(model), Sigma = vcov(model), Terms = 31:35)
  # wald.test(b = coef(model), Sigma = vcov(model), Terms = 31)
  # wald.test(b = coef(model), Sigma = vcov(model), Terms = 32)
  # wald.test(b = coef(model), Sigma = vcov(model), Terms = 33)
  # wald.test(b = coef(model), Sigma = vcov(model), Terms = 34)
  # wald.test(b = coef(model), Sigma = vcov(model), Terms = 35)
  # 
}




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


prf_list <- list()
accuracies <- numeric(4)
auc_list <- numeric(4)

for(j in 1:4){
  
  if(j == 1){
    #test ==all train_data
    } else if(j==2){ #quarter finals
      test <- test_data[1:34,]
  }else if(j==3){#semi finals
      test <- test_data[35:52,] 
  }else{#Final
    test <- tail(test_data)
  }
  
  #Criteria
  fitted.results <- predict(model,newdata=test,type='response')
  num_results <- length(fitted.results)
  for(i in seq(1,num_results, 2) ){
    fitted.results[i] <- ifelse(fitted.results[i]>fitted.results[i+1],1,0)
    fitted.results[i+1] <- abs(fitted.results[i]-1)
  }
  
  misClasificError <- mean(fitted.results != test$result) #proportion of failures 
  #print(paste('Accuracy',1-misClasificError)) #proportion of right predictions
  accuracies[[j]] = 1-misClasificError
  
  p <- predict(model, newdata=test, type="response")
  pr <- prediction(p, test$result)
  prf <- performance(pr, measure = "tpr", x.measure = "fpr")
  prf_list[[j]] = prf
  # plot(prf)
  # title("Finals")
  
  auc <- performance(pr, measure = "auc")
  auc <- auc@y.values[[1]]
  auc_list[j] = auc
  #varImp(model)
}


#install.packages("ddalpha")
#install.packages("lava")
library(caret)
#install.packages("caret")

varImp(model)

######################
# GRAPHICS, PLOTS
####################

library(ggplot2)
# Basic barplot
df_auc <- data.frame(stage=c("QF+SF+F", "QF", "SF", "F"),
                     auc=auc_list)

p<-ggplot(data=df_auc, aes(x=stage, y=auc)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(auc,2)), vjust=1.6, color="white", size=3.5)
#+  theme_minimal()
p <- p + scale_x_discrete(limits=df_auc$stage)
p <- p + labs(title="AUC per pick'em stage", x="Stage", y = "AUC")
#p + theme_classic()
p <- p + theme(plot.title = element_text(hjust = 0.5))
p

##Wr accuracies
df_acc <- data.frame(stage=c("QF+SF+F", "QF", "SF", "F"),
                     acc=accuracies)

p2<-ggplot(data=df_acc, aes(x=stage, y=acc)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(acc,2)), vjust=1.6, color="white", size=3.5)
#+  theme_minimal()
p2 <- p2 + scale_x_discrete(limits=df_acc$stage)
p2 <- p2 + labs(title="Model prediction accuracy per pick'em stage", x="Stage", y = "Accuracy")
#p + theme_classic()
p2 <- p2 + theme(plot.title = element_text(hjust = 0.5))
p2


varimp <- varImp(model)
df_varimp <- data.frame( field = rownames(varimp), overall = varimp$Overall)

p<-ggplot(data=df_varimp, aes(x=field, y=overall)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=round(overall,2)), vjust=1.6, color="white", size=3.5)
#+  theme_minimal()

p <- p + scale_x_discrete(limits=df_varimp$field)
p <- p + labs(title="Field importance", x="Field", y = "Importance")
#p + theme_classic()
p <- p + theme(plot.title = element_text(hjust = 0.5))
p




####################
#Pick'em vs model analyses
#################

pickem <- read.csv("pickem_qf_smf_f.txt", header = F)
colnames(pickem) <- c("name", "people", "percentage", "points")
pickem <- as.data.table(pickem)
pickem[, accuracy:=points/40]
pickem[, percentage:=percentage/100]

mean_accuracy <- 0
for(i in 1:9){
  mean_accuracy = mean_accuracy + quiniela[i,"percentage"] * quiniela[i,"accuracy"]
}
