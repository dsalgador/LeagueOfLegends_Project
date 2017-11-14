########################
#Model fitting
#########################
#n = 180
#all
test_datasub <- test_data

#Quarter finals
#test_datasub <- test_data[1:34,]
#Semi finals
#test_datasub <- test_data[35:52,] 

#Final
#test_datasub <- tail(test_data)


n=dim(test_datasub)[1]
nc = 10000
acc <- numeric(nc)

train <- train_data
model <- glm(result ~.,family=binomial(link='logit'),data=train)

#testing if our model accuracy is greater than the mean accuracy of peopli
#that have done the pick'em for the second stage.
pval<- numeric(nc)

for(k in 1:nc){
  ##index1 <- sample(1:n, 25)
  # train <- train_data[index2,]
  #test <- train_data[index1,]
  # index1 <- sample(seq(1,n,2), replace= TRUE)
  # index1 <- c(index1, index1+1)
  #test <- sample_n(test_datasub,n, replace = TRUE)
  index <- sample(seq(1,n/2), replace = TRUE)
  test_odd <- test_datasub[seq(1 ,n,2) ,]
  test_even <- test_datasub[seq(2 ,n,2) ,]
  
  test <- rbind(test_odd[index[1],], test_even[index[1], ])
  for(j in 2:(n/2)){
    test <- rbind(test, test_odd[index[j],], test_even[index[j], ])
    }

  # fitted.results <- predict(model,newdata=test,type='response')
  # fitted.results <- ifelse(fitted.results > 0.5,1,0)
  fitted.results <- predict(model,newdata=test,type='response')
  num_results <- length(fitted.results)
  for(i in seq(1,num_results, 2) ){
    fitted.results[i] <- ifelse(fitted.results[i]>fitted.results[i+1],1,0)
    fitted.results[i+1] <- abs(fitted.results[i]-1)
  }
  
  
  
  misClasificError <- mean(fitted.results != test$result) #proportion of failures 
  acc[k] = 1-misClasificError
 # print(paste('Accuracy',1-misClasificError)) #proportion of right predictions
  pval[k] = ifelse(acc[k]>mean_accuracy ,1,0)
  
}

for(k in 1:nc){
  pval[k] = ifelse(acc[k]< mean_accuracy ,1,0)
}
pval = sum(pval)/nc

quantile(acc, probs = c(0.025, 0.975))
quantile(acc, probs = c(0.05, 0.95))

mean(acc)
plot(density(acc))

#write.csv(acc,"accuracy")

###Results
#Bootstraping 10.000 iterations  we have obtained a
#95% confidence interval for the accuracy of our model related
#to the test data from worlds 2017
#In addition the estimated probability that the accuracy of our model
#is smaller than the mean accuracy of people that filled the pick'em,
# is approx 3.8%

#If we consider a confidence interval of the 90%, i.e. asume a 
#significance level of the 10%, we can conclude that there are 
#statistical evidences of the fact that the accuracy of our
#model with respect to the test data is creater than the mean accuracy
#that filled the pick'em,,











#############3
nb <- 10000
N <- length(acc)
acc_boost <- numeric(N)

sttrue = mean(acc)-mean_accuracy[[1]]
cnt = 0;
for(i in 1:nb){
  acc_boost[i]<- mean(sample( acc,N, replace = T)) -mean_accuracy[[1]]
  
  if(acc_boost[i]<sttrue){cnt = cnt +1;}
  
}
pv <- cnt/nb
quantile(acc_boost, c(0.025,0.975) )

