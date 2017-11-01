setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")


library(rjson)
data <- fromJSON("players_info2.json")
data <- as.data.table(data)
data[, winrate:= as.numeric(win)/(as.numeric(win)+as.numeric(lose))]
df_players <- data[2:dim(data)[1], c("champion", "player", "winrate", "kda")]

winrate_player <- function(champ_name,player_name){
  wr <- df_players[champion == champ_name & player == player_name]$winrate
  if(length(wr)<1 || is.nan(wr)){
    wr <- mean(df_players[player == player_name]$winrate, na.rm = T)
    if(length(wr)<1 || is.nan(wr)){return(0.5);}
    else return(wr);
  }
  else  return(wr)
}

kda_player <- function(champ_name,player_name){
  kda <- df_players[champion == champ_name & player == player_name]$kda
  if(length(kda)<1) return(mean(df_players[player == player_name]$kda, na.rm = T)) 
  else return(kda)
}

winrate_teamplayers <- function(team_champs, team_players){
  #c(TOP, JNG, MID,  ADC, SUP).
  adcwr <- winrate_player(team_champs[4], team_players[4])
  supwr <- winrate_player(team_champs[5], team_players[5])
  midwr <- winrate_player(team_champs[3], team_players[3])
  jngwr <- winrate_player(team_champs[2], team_players[2])
  topwr <- winrate_player(team_champs[1], team_players[1])
  winrates <- c(topwr, jngwr,midwr, adcwr, supwr) 
  return(winrates)
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
