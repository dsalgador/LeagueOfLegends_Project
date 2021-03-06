library("rjson")
library(jsonlite)
library(data.table) 
library(dplyr)
setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")


url <- "http://ddragon.leagueoflegends.com/cdn/7.19.1/data/en_US/champion.json"
#GitHub saved as: champ_info.json
#data <- fromJSON(url, simplifyVector = TRUE, simplifyDataFrame =  TRUE)
data <- fromJSON("champ_info.json")

n_champs = 138
champ_names = numeric(n_champs)
champ_ids = numeric(n_champs)

for(i in 1:n_champs){
  champ_names[i] <-data$data[[i]][c('name')]$name
  champ_ids[i] <- data$data[[i]][c('key')]$key
}

champ_data = data.table(name = champ_names, id = champ_ids)
setkey(champ_data,id)  

url2 <- "http://api.champion.gg/v2/champions?&champData=matchups&limit=200&api_key=11a8590ff111c8c2f6d76c43a355b32d"


#GitHub saved as: champion_matchups.json
data2 <- fromJSON("champion_matchups_patch7_21.json")
#data2 <- fromJSON(url2, simplifyVector = TRUE, simplifyDataFrame =  TRUE)
data2$"_id"$championId

champs = data.table(id =data2$championId)
champs[ , name:=champ_data[as.character(champs$id)]$name]
champs[, role:= data2$role]
champs[, winrate:= data2$winRate]

ADCs<- champs %>%  filter(role == 'DUO_CARRY') %>% select(id, name, winrate) %>% as.data.table()
SUPs<- champs %>%  filter(role == 'DUO_SUPPORT') %>% select(id, name, winrate) %>% as.data.table()
MIDs<- champs %>%  filter(role == 'MIDDLE') %>% select(id, name, winrate)%>% as.data.table()
TOPs<- champs %>%  filter(role == 'TOP') %>% select(id, name, winrate)%>% as.data.table()
JNGs<- champs %>%  filter(role == 'JUNGLE') %>% select(id, name, winrate)%>% as.data.table()

#options(error=recover)

winrates_table <- function(POSITION, ROLE){
 
  init = 0.5
  POSITION[, as.character(POSITION$id):=init]
  row.names(POSITION) <- as.character(POSITION$id)
  m=length(data2$"matchups"[, ROLE])
  for(i in 1:m){
    if(!is.null(data2$"matchups"[, ROLE][[i]])){
      n = dim(data2$"matchups"[, ROLE][[i]])[1] #número de files
      if(length(n)<1) break;
      for(j in 1:(n)  ){
        id1 = data2$"matchups"[, ROLE][[i]]$champ1_id[j]
        row = which(rownames(POSITION) == id1)
        id2= as.character(data2$"matchups"[, ROLE][[i]]$champ2_id[j])
        col = which(colnames(POSITION) == id2)
        
        if(POSITION[row, col, with = FALSE] == init){
          POSITION[row, (id2):= round(data2$"matchups"[, ROLE][[i]]$champ1$winrate[j],   4)]
        }
      }
      
      for(j in 1:(n)  ){
        id1 = data2$"matchups"[, ROLE][[i]]$champ2_id[j]
        row = which(rownames(POSITION) == id1)
        id2= as.character(data2$"matchups"[, ROLE][[i]]$champ1_id[j])
        col = which(colnames(POSITION) == id2)
        
        if(POSITION[row, col, with = FALSE] == init){
          POSITION[row, (id2):= round(data2$"matchups"[, ROLE][[i]]$champ2$winrate[j],   4)]
        }
      }
    }
  }
}



winrates_table(ADCs, 'DUO_CARRY')
winrates_table(MIDs, "MIDDLE")
winrates_table(SUPs, "DUO_SUPPORT")
winrates_table(TOPs, "TOP")
winrates_table(JNGs, "JUNGLE") 


row.names(JNGs) <- as.character(JNGs$id)
row.names(TOPs) <- as.character(TOPs$id)
row.names(MIDs) <- as.character(MIDs$id)
row.names(SUPs) <- as.character(SUPs$id)
row.names(ADCs) <- as.character(ADCs$id)

id2name <- function(ID, TABLE){
  #falta posar ifs per evitar errors etc
  return(TABLE[id == ID,name]);}
name2id <- function(NAME, TABLE){
  #falta posar ifs per evitar errors etc
  return(TABLE[name == NAME, id]);}


winrate_pair <- function(champ1, champ2, POSITION){
  wr <- as.numeric(POSITION[name == champ1, which(colnames(POSITION) == name2id(champ2, POSITION) ), with = FALSE])
  if(length(wr) == 1){  return(wr)}
  else if(length(wr) == 0){return(0.5)}
  else{return(0.5)}
}

winrate_match <- function(team1, team2){
  #team1 and team2 must be arrays of characters containing the names of
  #the champions played in each team and in this order:
  #c(TOP, JNG, MID,  ADC, SUP).
  
  #An array containing the champion-matchup winrates of the team1 is returned
  if(length(team1) != length(team2)){return("Team lengths are different");}
  
  adcwr <- winrate_pair(team1[4], team2[4], ADCs)
  supwr <- winrate_pair(team1[5], team2[5], SUPs)
  midwr <- winrate_pair(team1[3], team2[3], MIDs)
  jngwr <- winrate_pair(team1[2], team2[2], JNGs)
  topwr <- winrate_pair(team1[1], team2[1], TOPs)
  winrates1 = c(topwr, jngwr,midwr, adcwr, supwr) 
  #If some matchup has no data available, so that there is a NA value
  # we assign a winrate equal to 0.5
  winrates1[is.na(winrates1)] <- 0.5
  return(winrates1);
  
}

#Example:
team1= c("Tryndamere","Lee Sin", "Yasuo", "Miss Fortune", "Leona")
team2 = c("Dr. Mundo", "Xin Zhao", "Taliyah", "Lucian", "Janna" )

winrate_match(team1, team2)

#IMPORTANT: if some champion matches have no data available, the win rate is
#set to 0.5.




# setwd("C:/Users/Daniel/Dropbox/GitHub/LeagueOfLegends_Model")
# ##Exporting the files used:
# exportJson1 <- toJSON(data)
# exportJson2 <- toJSON(data2)
# ## Save the JSON to file
# write(exportJson1, file="champ_names_and_ids.JSON")
# write(exportJson2, file="champ_matchups.JSON")
# 
# json_data <- fromJSON("champ_names_and_ids.JSON")
# json_data2 <- fromJSON("champ_matchups.JSON")
