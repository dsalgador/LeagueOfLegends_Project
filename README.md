# Open data analysis to predict the results of the League of Legends World Championship

Project members: Josep Castell, Sergi Laut  & Daniel Salgado

## Abstract
 League of Legends (LoL) is a MOBA which has become the online computer game with more active users in the world. In League of Legends, players assume the role of an unseen "summoner" that controls a "champion" with unique abilities and battle against a team of other players. Each team usually consists of five players and the main goal is to destroy the opposing team's "nexus", a structure which lies at the heart of a base protected by defensive structures ("turrets") situated along the three streets or lanes that constitute the map. There are currently 138 champions in League of Legends (by October 2017) which are classified in different types or classes which generally determine what part of the map the champions gravitates towards during the early game. There is the top-lane player, the mid-lane player, two bot-lane players which play together, and the player who heads to the "jungle", the areas of the map that lie between the three mentioned lanes.

This game also has the most solid competitive structure between all the e-sports (the League of Legends competitive scene moves more money than the European basketball League), and the sports betting sites are starting to offer services in this fields. 

The aim of our project is to predict some of the results of the 2017 World Championship, the biggest event in the e-sports, using open data resources from different APIs. To do it, we will use the data of the different professional players and teams which compete in the World Championship, and the data of the different champions that they can play, and we will develop a logistic regression model to predict the results of the knock-out stage (quarter-finals, semi-finals and final) using data from the group stage.

## Data sources:

* Matches: http://oracleselixir.com/match-data/, Data Dictionary: http://oracleselixir.com/match-data/match-data-dictionary/
* http://champion.gg/ API
* Riot API: https://developer.riotgames.com/
* https://lol.gamepedia.com/playername (example: playername = Faker)

The .xlsx files have been converted to .cvs via the web page https://convertio.co/es/xlsx-csv/

## License

Unless otherwise stated, all material is licensed under a Creative Commons Attribution-ShareAlike 3.0 License. This means you are free to copy, distribute and transmit the work, adapt it to your needs as long as you cite its origin and, if you do redistribute it, do so under the same license.
