setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")


library(rjson)
data <- fromJSON("players_info.json")
data <- as.data.table(data)
data[, winrate:= as.numeric(win)/(as.numeric(win)+as.numeric(lose))]
df <- data[2:dim(data)[1], c("champion", "Aplayer", "winrate", "kda")]

winrate_player <- function(champ_name,player_name){
  wr <- df[champion == champ_name & Aplayer == player_name]$winrate
  return(wr)
}

kda_player <- function(champ_name,player_name){
  kda <- df[champion == champ_name & Aplayer == player_name]$kda
  return(kda)
}









# 
# 
# 
# df <- read.csv("data957.csv", header = T)
# 
# df <- subset(df, select = c("champion", "kda", "win", "lose"))[2:length(rownames(df)),]
# 
# df <- as.data.table(df)
# df[, winrate:= win/(win+lose)]
# df<- subset(df, select = c("champion", "winrate", "kda"))
# 
# winrate_player <- function(champ_name,player_name){
#   df <- JSON_file$player_name
#   wr <- df[champion == champ_name ,"winrate"][[1]]
#   return(wr)
# }
# 
# 
# write.csv(df, file ="957.csv", row.names = FALSE)
# #df[champion == "Maokai" ,"winrate"]
