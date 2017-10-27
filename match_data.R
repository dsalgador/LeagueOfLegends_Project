setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")

# set bolean to 1 and coment the line
bolean <- 1
if(bolean == 1){
  #df <- read.csv("2016_CompleteMatchData.csv", header = T,na.strings=c(""))
  df <- read.csv("2017_WorldsMatchData.csv", header = T,na.strings=c(""))
  bolean = 0;
}

library(data.table)
names(df)
df <- as.data.table(df)
df <- df[league=="WC"]

# library(Amelia)
# missmap(df, main = "Missing values vs observed")

fields <- c("result", "gameid", "playerid", "side", "position", "player", "team", "champion", "gamelength")
dfs <- subset(df, select = fields)

game_ids <- unique(dfs$"gameid")
num_games <- length(game_ids)

#With this function we obtain the train data of all matches of the df read data
fill_traindata <- function(){
  for(j in 1:num_games){
    game <- dfs[gameid == game_ids[j]]
    
    game_team1 <- game[side == 'Blue'][1:5]; 
    game_team2 <- game[side == 'Red'][1:5]
    
    
    #c(ADC, SUP, MID, JNG, TOP).
    team1_champs <- as.character(game_team1$champion)
    team1_players <- as.character(game_team1$player)
    team2_champs <- as.character(game_team2$champion)
    team2_players <- as.character(game_team2$player)
    
    
    ##champ-matchup-winrate  for each of the 5 positions. From champion.gg data
    team1_champwr = winrate_match(team1_champs, team2_champs)
    team2_champwr = 1-team1_champwr
    
    ##champ-player-winrate for each of the 5 players of the team.
    #Using data obtained scraping lol.gamepedia.com/player_name/Champion_Statistics
    
    #TO DO
    
    ####
    
    match_team1 <- data.table(result = game_team1$result[1], team = game_team1$team[1], side = game_team1$side[1])
    match_team2 <- data.table(result = game_team2$result[1], team = game_team2$team[1], side = game_team2$side[1])
    
    poswr_names <- c('topwr_champ', 'jngwr_champ', 'midwr_champ', 'adcwr_champ', 'supwr_champ')
    poswr_list1 <- list()
    poswr_list2 <- list()
    for(i in 1:5){poswr_list1[[i]]= team1_champwr[i];poswr_list2[[i]]= team2_champwr[i]; }
    match_team1[,c(poswr_names):=poswr_list1]
    match_team2[,c(poswr_names):=poswr_list2]
    if(j==1){train_data <- rbind(match_team1, match_team2)}
    else{train_data <- rbind(train_data, match_team1, match_team2)}
  }
  return(train_data)
}
train_data <- fill_traindata()

