########################
#Bootstraping accuracy
#########################
n_versions = 3
nc = 1000 #number of bootstrap iterations
acc_versions <- list()

for(version in 1:n_versions){
  
    train_data <- read.csv("train_data.csv")
    test_data <- read.csv("test_data.csv")
    
    
    withTeamsinfo <- T 
    withSideinfo <- T  
    withChampiongginfo <-T 
    withPlayerinfo <- T
    
    if(version >= 2){
      withTeamsinfo <- F #1
      if(version >=3){
        withSideinfo <- F
        if(version >=4){
          withChampiongginfo <-F}
      }
    }
    
    field_names <- names(train_data)
    selected_fields <- c(field_names[1])
    if(withTeamsinfo){selected_fields <- c(selected_fields, field_names[2] )}
    if(withSideinfo){selected_fields <- c(selected_fields, field_names[3] )}
    if(withChampiongginfo){selected_fields <- c(selected_fields, field_names[4:8] )}
    if(withPlayerinfo){selected_fields <- c(selected_fields, field_names[9:13] )}
    
    train_data <- subset(train_data, select = selected_fields)
    
    
    
    test_datasub <- test_data
    n=dim(test_datasub)[1]
    acc <- numeric(nc)
    
    train <- train_data
    model <- glm(result ~.,family=binomial(link='logit'),data=train)
    
    #Bootstrap loop
    for(k in 1:nc){
     
      index <- sample(seq(1,n/2), replace = TRUE)
      test_odd <- test_datasub[seq(1 ,n,2) ,]
      test_even <- test_datasub[seq(2 ,n,2) ,]
      
      test <- rbind(test_odd[index[1],], test_even[index[1], ])
      for(j in 2:(n/2)){
        test <- rbind(test, test_odd[index[j],], test_even[index[j], ])
      }
    
      fitted.results <- predict(model,newdata=test,type='response')
      num_results <- length(fitted.results)
      for(i in seq(1,num_results, 2) ){
        fitted.results[i] <- ifelse(fitted.results[i]>fitted.results[i+1],1,0)
        fitted.results[i+1] <- abs(fitted.results[i]-1)
      }
      
      misClasificError <- mean(fitted.results != test$result) #proportion of failures 
      acc[k] = 1-misClasificError
    }
    acc_versions[[version]] <- acc

}

#Calculation of confidence intervals
#Quantile method
CIs <- quantile(acc_versions[[1]] ,probs = c(0.025, 0.975)) 
means <- list(mean(acc_versions[[1]]))
variance <- list(var(acc_versions[[1]]))

for(ver in 2:n_versions){
  CIs <- rbind(CIs, quantile(acc_versions[[ver]] ,probs = c(0.025, 0.975)) ) 
  means[[ver]] <-mean(acc_versions[[ver]]) 
  variance[[ver]] <-var(acc_versions[[ver]]) 
  }

CIs <- round(CIs,3)
means <- round(as.numeric(means),3)
variance <- round(as.numeric(variance),5)
CIs <- cbind(means, variance, CIs)
#if n_versions = 4
row.names(CIs) <- c("Model v1", "Model v2", "Model v3", "Model v4")
#round(CIs,3)
CIs

#Standard method (reasonable since the accuracy densities seem to be symetric)
#plot(density(acc))

a <- numeric(n_versions)
b <- numeric(n_versions)
for(ver in 1:n_versions){
  a[ver] <-mean(acc_versions[[ver]]) -1.96*sd(acc_versions[[ver]])
  b[ver] <-mean(acc_versions[[ver]]) +1.96*sd(acc_versions[[ver]])
}

CIs2 <- round(cbind(a, b),3)
CIs_all <- cbind(CIs,CIs2)
colnames(CIs_all)[1:2] <- c("Mean", "Variance")
colnames(CIs_all)[3:4] <- c("2.5%(q)", "97.5%(q)")
colnames(CIs_all)[5:6] <- c("2.5%(s)", "97.5%(s)")

CIs_all


#Box plot for the four models

par(mfrow = c(1,1))
boxplot(acc_versions, main ="Bootstrap accuracies", xaxt = 'n',names  = row.names(CIs),horizontal = TRUE, xlab = "Accuracy", ylab = "Model" ) 
axis(side=1, at = seq(0,1,0.1))
#axis(side=1, at = seq(0,1,0.05), labels = "")
library(Hmisc)
minor.tick(nx=4, ny=0, tick.ratio=0.5)

# 
# quantile(acc, probs = c(0.025, 0.975))
# quantile(acc, probs = c(0.05, 0.95))
# 
# mean(acc)
# plot(density(acc))
# boxplot(acc,las = 2, xlab = "Base model", ylab = "Accuracy",col="grey", main="Bootstrap accuracy")
# 
# 
# data <- acc
# boxplot(data, horizontal = TRUE, range = 0, axes = FALSE, col = "grey",  at = 0.2, varwidth=FALSE, boxwex=0.3)
# valuelabels <- c(round(fivenum(data)[2], digits = 2), round(fivenum(data)[4], digits = 2))
# text(x = valuelabels, y = c(0.35, 0.35), labels = valuelabels, font = 2)
# mtext(c(min(round(data, digits = 2)),max(round(data, digits = 2))), side=1, at=bxp$stats[c(1,5)], line=-3, font = 2)
# 
# a <-mean(acc) -1.96*sd(acc)
# b <-mean(acc) +1.96*sd(acc)
# 
# 
