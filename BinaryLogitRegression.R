########################
#Model fitting  
########################
setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")


####################
#Pick'em analyses
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



###Plot list inisialization
plots_p <- list()
plots_p2 <- list()
plots_p3 <- list()
prf_listOf_prf_lists <- list()

############
#Model analyses
###########

library(ROCR)


for(version in 1:4){
  train_data <- read.csv("train_data.csv")
  test_data <- read.csv("test_data.csv")
  
  
  withTeamsinfo <- T #1
  withSideinfo <- T  #1
  withChampiongginfo <-T #5
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
  
  avoid_0and1 <- F
  if(avoid_0and1){
    results <- train_data$result
    wr_min = 0.25
    wr_max = 0.75
    train_data[ train_data == 0] <- wr_min
    train_data[ train_data == 1] <- wr_max
    train_data$result = results
  }
  
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
  #print(round(cbind( coef(model),confint(model)),1))
  round(cbind( coef(model), confint.default(model)) ,1)
  
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
  
  if(version == 2){
    #Overall effect of side of the map
    wald.test(b = coef(model), Sigma = vcov(model), Terms = 2)
    #Overall effect of matchup_champion win rates
    wald.test(b = coef(model), Sigma = vcov(model), Terms = 3:7)

    #Overall effect of player_champion win rates
    wald.test(b = coef(model), Sigma = vcov(model), Terms = 8:12)
    
  }
  
  
  #########################
  #Assessing the predictive ability of the model
  ############################
  
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
  
  version_name <- paste("Model v", version, sep = "")
  ###########
  #AUC plots
  ###########
  
  df_auc <- data.frame(stage=c("All", "QF", "SF", "F"),
                       auc=auc_list)
  
  p<-ggplot(data=df_auc, aes(x=stage, y=auc)) +
    geom_bar(stat="identity") +
    geom_text(aes(label=round(auc,2)), vjust=1.6, color="white", size=3.5)
  p <- p + scale_x_discrete(limits=df_auc$stage)
  p <- p + labs(title=paste("",version_name), x="Pick'em stage", y = "AUC")
  p <- p + theme(plot.title = element_text(hjust = 0.5))
  plots_p[[version]] <- p
  
  ###########
  #Accuracy plots
  ###########
  
  df_acc <- data.frame(stage=c("All", "QF", "SF", "F"),
                       acc=accuracies)
  
  p2<-ggplot(data=df_acc, aes(x=stage, y=acc)) +
    geom_bar(stat="identity") +
    geom_hline(yintercept = mean_accuracy[[1]]) +
    #annotate("text", 'F', mean_accuracy[[1]], vjust = -1, label = "Mean pick'em accuracy")+
    geom_text(aes(label=round(acc,2)), vjust=1.6, color="white", size=3.5)
  p2 <- p2 + scale_x_discrete(limits=df_acc$stage)
  p2 <- p2 + labs(title=paste("", version_name), x="Pick'em stage", y = "Accuracy")
  p2 <- p2 + theme(plot.title = element_text(hjust = 0.5))
  #p2 <- p2 +  geom_hline(yintercept = mean_accuracy[[1]]) 
  plots_p2[[version]] <- p2
  
  
  ###########
  #VarImportance plots
  ###########
  varimp <- varImp(model)
  df_varimp <- data.frame( field = rownames(varimp), overall = varimp$Overall)
  
  p3<-ggplot(data=df_varimp, aes(x=field, y=overall)) +
    geom_bar(stat="identity") +
    geom_text(aes(label=round(overall,2)), vjust=1.6, color="white", size=3.5)
  
  p3 <- p3 + scale_x_discrete(limits=df_varimp$field)
  p3 <- p3 + labs(title=paste("Field importance", version_name), x="Field", y = "Importance (abs(t-statistic))")
  p3 <- p3 + theme(plot.title = element_text(hjust = 0.5))
  plots_p3[[version]] <- p3
  
  
  ###########
  #ROC curve plots
  ###########
  prf_listOf_prf_lists[[version]] <- prf_list
 
  # plot(prf_list[[1]])
  # plot(prf_list[[2]], add = TRUE, col=2, lty = 2)
  # plot(prf_list[[3]], add = TRUE, col=3, lty = 2)
  # plot(prf_list[[4]], add = TRUE, col=4, lty = 2)
}

######MULTIPLE PLOTS FUNCTION
#Source code: http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
#######
multiplot(plotlist = plots_p, cols = 4)
multiplot(plotlist = plots_p2, cols = 4)
multiplot(plotlist = plots_p3[c(2,4)], cols = 2)
plots_p3[2]
plots_p3[4]
#par(mfrow = c(2,2),pty="m")
par(mfrow = c(2,2), pty = 's')
for(ver in 1:4){
  prf_list = prf_listOf_prf_lists[[ver]]
  plot(prf_list[[1]], xlim = c(0,1), ylim = c(0,1), lwd =1.5, main = paste("Model v",ver, sep = ""))
  #legend(0.8,0.2, c("QF+SF+F,QF, SF, F") , lty = c(1,2,2,2), lwd = 1.5, col = 1:4)
  
  plot(prf_list[[2]], add = TRUE, col=2, lty = 2, lwd =1.5)
  plot(prf_list[[3]], add = TRUE, col=3, lty = 2, lwd =1.5)
  plot(prf_list[[4]], add = TRUE, col=4, lty = 2, lwd =1.5)

}

par(mfrow = c(1,1), pty = 'm')
ver = 1
prf_list = prf_listOf_prf_lists[[ver]]
plot(prf_list[[1]], xlim = c(0,1), ylim = c(0,1), lwd =1.5)
legend("right",cex = 0.75, bty = 'n',c("QF+SF+F","QF", "SF", "F") , lty = c(1,2,2,2), lwd = 1.5, col = 1:4)

plot(prf_list[[2]], add = TRUE, col=2, lty = 2, lwd =1.5)
plot(prf_list[[3]], add = TRUE, col=3, lty = 2, lwd =1.5)
plot(prf_list[[4]], add = TRUE, col=4, lty = 2, lwd =1.5)


##Analysing predictivity of Finals by the four models 
#

v1 =c(0.9999988, 0.5308298, 0.9999919, 0.0108322, 0.9965328, 0.5184713) 
v2= c(0.9954209, 0.6160834, 0.9861073, 0.2659355, 0.8761955, 0.8145542) 
v3 = c(0.9952628, 0.6327470, 0.9855164, 0.2798750, 0.8731010, 0.8217733)
v4 = c(0.9842462, 0.8421150, 0.9407421, 0.7601461, 0.9365140, 0.6324281)

v = rbind(v1,v2,v3,v4)

par(mfrow = c(1,3))
plot(v[,1]- v[,2],cex.lab = 1.5 ,pch = 21, bg = 1, cex = 2, main = "First match", xaxt = 'n', xlab = "Model", ylab = "P(SSG win) - P(SKT win)")
axis(side = 1, at = seq(1,4,1))
plot(v[,3]- v[,4],cex.lab = 1.5,pch = 21, bg = 1, cex = 2, main = "Second match",xaxt = 'n', xlab = "Model", ylab = "P(SSG win) - P(SKT win)")
axis(side = 1, at = seq(1,4,1))
plot(v[,5]- v[,6],cex.lab = 1.5,pch = 21, bg = 1, cex = 2, main = "Third match",xaxt = 'n', xlab = "Model", ylab = "P(SSG win) - P(SKT win)")
axis(side = 1, at = seq(1,4,1))
