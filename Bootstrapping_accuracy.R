########################
#Bootstraping accuracy
#########################

test_datasub <- test_data

n=dim(test_datasub)[1]
nc = 1000
acc <- numeric(nc)

train <- train_data
model <- glm(result ~.,family=binomial(link='logit'),data=train)

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


quantile(acc, probs = c(0.025, 0.975))
quantile(acc, probs = c(0.05, 0.95))

mean(acc)
plot(density(acc))
boxplot(acc,las = 2, xlab = "Base model", ylab = "Accuracy",col="grey", main="Bootstrap accuracy")


data <- acc
boxplot(data, horizontal = TRUE, range = 0, axes = FALSE, col = "grey",  at = 0.2, varwidth=FALSE, boxwex=0.3)
valuelabels <- c(round(fivenum(data)[2], digits = 2), round(fivenum(data)[4], digits = 2))
text(x = valuelabels, y = c(0.35, 0.35), labels = valuelabels, font = 2)
mtext(c(min(round(data, digits = 2)),max(round(data, digits = 2))), side=1, at=bxp$stats[c(1,5)], line=-3, font = 2)

a <-mean(acc) -1.96*sd(acc)
b <-mean(acc) +1.96*sd(acc)