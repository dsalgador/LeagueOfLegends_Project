# Open data analysis to predict the results of the League of Legends World Championship

Project members: Josep Castell, Sergi Laut  & Daniel Salgado

## Abstract
  League of Legends (LoL) is a MOBA which has become the online computer game with more active users in the world. In League of Legends, players assume the role of an unseen "summoner" that controls a "champion" with unique abilities and battle against a team of other players. Each team usually consists of five players and the main goal is to destroy the opposing team's "nexus", a structure which lies at the heart of a base protected by defensive structures ("turrets") situated along the three streets or lanes that constitute the map. There are currently 138 champions in League of Legends (by October 2017) which are classified in different types or classes which generally determine what part of the map the champions gravitates towards during the early game. There is the top-lane player, the mid-lane player, two bot-lane players which play together, and the player 
who heads to the "jungle", the areas of the map that lie between the three mentioned lanes.

This game also has the most solid competitive structure between all the e-sports (the League of Legends competitive scene moves more money than the European basketball League), and the sports betting sites are starting to offer services in these fields.


The aim of this project is to predict results of the 2017 World Championship, the biggest event in the e-sports, using open data resources from different APIs and websites. Using data about the different professional players and teams that compete in the World Championship, and the data of the different champions that they can play; a logistic regression model to predict the results of the knockout stage (quarterfinals, semifinals and final) using data from the group and pre-qualifier stages is developed.



## References and Data sources

* [1] Binary logistic regression in R, https://www.r-bloggers.com/evaluating-logistic-regression-models/
* [2] Binary logistic regression example (Titanic survivors) https://www.r-bloggers.com/how-to-perform-a-logistic-regression-in-r/.
* [3] Binary logistic regression with a single categorical predictor https://onlinecourses.science.psu.edu/stat504/node/150
* [4] Binary logistic regression with a categorical predictor of multiple levels https://onlinecourses.science.psu.edu/stat504/node/152
* [5] Static champion data (in english) from patch 7.19 http://ddragon.leagueoflegends.com/cdn/7.19.1/data/en_US/champion.json
* [6] Champion.gg API http://api.champion.gg/.
* [7] Leaguepedia: https://lol.gamepedia.com/<player_name>/Champion_Statistics, where <player_name> must be substituted by the professional Player of interest.
* [8] Tim Sevenhuysen, OraclesElixir.com, 2017. http://oracleselixir.com/gamedata/2017-worlds/.
* [9] xlsx to csv online converter: https://convertio.co/es/xlsx-csv/.
* [10] Visualization and statistics of logistic regressions in R https://stats.idre.ucla.edu/r/dae/logit-regression/.
* [11] Knock out stage Worlds 2017 pick’em results. http://pickem.euw.lolesports.com/en-GB#leaderboards/everyone
* [12] Bootstrap and permutation tests lectures, Pere Puig (Department of Mathematics from the UAB), Data Visualization and Modelling (subject from the Master’s).
* [13] The 2017 Worlds finals between SKT and Samsung Galaxy will be all about adapting, by Austen Goslin.https://www.riftherald.com/lol-worlds/2017/11/3/16603216/lol-worlds-finals-2017-skt-ssg-preview22

## License

Unless otherwise stated, all material is licensed under a Creative Commons Attribution-ShareAlike 3.0 License. This means you are free to copy, distribute and transmit the work, adapt it to your needs as long as you cite its origin and, if you do redistribute it, do so under the same license.
