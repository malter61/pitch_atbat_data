library(pitchRx)
library(RSQLite)
library(dplyr)
library(data.table)
library(stringr)

masterList <- list()
atbat <- data.frame()
pitch <- data.frame()
action <- list()
runner <- data.frame()

pitch.names <- c('type','pitch_type','inning_side','inning','on_1b','on_2b',
                 'on_3b','gameday_link','num','count')
atbat.names <- c('pitcher','batter','gameday_link','num','b','s','o','stand',
                 'p_throws','event','home_team_runs','away_team_runs',
                 'batter_name','pitcher_name','atbat_des')
action.names <- c('event','gameday_link','num')
runner.names <- c('score','event','gameday_link','num')
### If we download too many files, we get a runtime error, so I download only
### one week at a time.
### For each week, I'm rbinding the new tables all in one step
offseason <- FALSE
a <- as.Date('2016-04-03')
while(a < as.Date('2016-11-03')) {
  b <- a + 7
  masterList <- scrape(start = a, end = b)
  atbat <- rbind(atbat,masterList[['atbat']][,c(atbat.names)])
  pitch <- rbind(pitch,masterList[['pitch']][,pitch.names])
  a <- a + 7
}

pitch <- data.table(pitch)
atbat <- data.table(atbat)
write.csv(pitch,'C:/baseball/data sets/pitch.2015_2016.csv',row.names=F)
write.csv(atbat,'C:/baseball/data sets/atbat.2015_2016.csv',row.names=F)
pitch.atbat <- merge(pitch,atbat,by=c('gameday_link','num'))
pitch.atbat <- pitch.atbat[order(gameday_link,num)]
pitch.atbat <- pitch.atbat[,c('gameday_link','num','inning','inning_side','o','on_1b',
                              'on_2b','on_3b','count','batter','batter_name','event',
                              'away_team_runs','home_team_runs','atbat_des',
                              'pitcher','pitcher_name'),with=F]
pitch.atbat <- pitch.atbat[, .SD[c(.N)], by=.(gameday_link,num)]
write.csv(pitch.atbat,'C:/baseball/data sets/pitch.atbat.2015_2016.csv',row.names=F)