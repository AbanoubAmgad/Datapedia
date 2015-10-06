# First install the following packages
#install.packages(c("twitteR", "xlsx", "rJava"))

#Then we load them
library(twitteR)
library(xlsx)
library(rJava)
library(rjson)
library(reshape2)
library(stringr)

source("http://127.0.0.1//projects//DataPedia//scor.R")
# #source("D://scor.R")
# #Now we start the setup of twitter oauth (please check this like for this part: http://thinktostart.com/sentiment-analysis-on-twitter/)
# 
# #Add your own api key, api secret, access token, access token secret
api_key <- "ZGEp4bBF1JoJu6pkOF0WQqdvg" 
api_secret <- "mL7665Tft5zp5ErJnkOHPbPgPHyFuvl8t6rAvn4M2a6W6AX60k"
access_token <- "112967627-gM87d2o1CdiK3ORkImEXhXUmVWEMtJXTtzJtnWpv"
access_token_secret <- "u5md52crZoeZqfE4Rp4uWxcTqkSTa9vkRXHmuQZD9JQ4B"
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)
# capture.output( setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret), file='NUL')
args <- commandArgs(TRUE)

N <- args[1]

#Now we can search twitter 
#we created a list called "mytweets" to store the tweets in it.
df <- searchTwitter(N, n=300,lang = 'en')

#then we convert the list into a data frame to get all the attributes of the tweets
df <- do.call("rbind", lapply(df, as.data.frame))
#df <- read.csv("http://127.0.0.1/DataPedia/21-4.csv")
df <- df[!duplicated(df[,c('text')]),]
#then we are exporting the tweets
#write.table(df,"D:\\tweets.txt",append = T)
#df <- read.table("D:\\test.txt")
lexicon <- read.table("http://127.0.0.1/projects/DataPedia/FinalLexicon.txt")
Text <- df$text
Text <- as.character(Text)

#Text <- Text[1:500]
#Text = gsub('[[:punct:]]', '', Text)
Text = gsub("\\.", " . ", Text)
Text = gsub("," , " , ", Text)
Text = gsub("\\?", " ? ", Text)
Text = gsub("!", " ! ", Text)
Text = gsub('[[:cntrl:]]', '', Text)
Text = gsub('\\d+', '', Text)
Text = iconv(Text, "latin1", "ASCII", sub="")
# # and convert to lower case:
Text = tolower(Text)
result <- score.sentiment(Text,lexicon)

#hashtags
hasht <- as.character(result$Tweet)
hasht <- unlist(hasht)
hasht <- paste(hasht,collapse=" ")
hasht <- str_split(hasht, '\\s+')
hasht <- unlist(hasht)
hasht <- grep("^#",hasht,perl = T,value = T)
hash <- as.data.frame(table(hasht))
hash <- arrange(hash,desc(hash$Freq))

#tmp <- read.table("http://127.0.0.1/projects/GP-last-task_v4/tst.txt")

#piechart
opinion <- table(sign(result$Score))

##########################################################################
#timeData <- data.frame(date = df$created,score = result$Score)
#meltTimeData <- melt(timeData,id=c("date"),measure.vars = c("score")) 
#meltTimeData <- dcast(meltTimeData,date~variable,mean)
#meltTimeData$date <- 1:nrow(meltTimeData)
#smplTxt <- character()

#lineChart
timeData <- aggregate(result$Score, by=list(0:(length(result$Score)-1) %/% 10), mean)
smplTxt <- character()
for (i in 1:nrow(timeData)){
  smplTxt<-c(smplTxt,paste("[",i,",",timeData$x[i],"],"))
}
smplTxt <- paste(smplTxt,collapse = '')


#sourcesPieChart
sourcesData <- as.data.frame(table(df$statusSource))
sourcesData <- arrange(sourcesData,desc(sourcesData$Freq))
sourcesData$Var1 <- as.character(sourcesData$Var1)
smplTxt2 <- character()
for (i in 1:4){
  part <- character()
  part <- strsplit(sourcesData[i,1],">")
  part <- part[[1]][2]
  part <- strsplit(part,"<")
  part <- part[[1]][1]
  smplTxt2<-c(smplTxt2,paste("['",part,"', ",sourcesData[i,2],"],"))
}
smplTxt2<-c(smplTxt2,paste("['Others', ",sum(sourcesData[5:nrow(sourcesData),2]),"],"))

smplTxt2 <- paste(smplTxt2,collapse = '')
#smplTxt2 <-gsub("' ", "'",smplTxt2)
#smplTxt2 <-gsub(" '", "'",smplTxt2)

locatedTweets <- df[which(!is.na(df$longitude)),]
locatedTweets <- locatedTweets[which(locatedTweets$longitude != 0),]
locatedTweets$text <- as.character(locatedTweets$text)

if (nrow(locatedTweets) != 0  )
{
#map
#EFTEKEER TEZABAT EL SIZE
smplTxt3 <- character()
mapText <- locatedTweets$text
mapText <- as.character(mapText)
#Text = gsub('[[:punct:]]', '', Text)
mapText = gsub("\\.", " . ", mapText)
mapText = gsub("," , " , ", mapText)
mapText = gsub("\\?", " ? ", mapText)
mapText = gsub("!", " ! ", mapText)
mapText = gsub('[[:cntrl:]]', '', mapText)
mapText = gsub('\\d+', '', mapText)
mapText = iconv(mapText, "latin1", "ASCII", sub="")
mapText = tolower(mapText)
mapText <- gsub("'","",mapText)
mapResult <- score.sentiment(mapText,lexicon)
for (i in 1:nrow(locatedTweets)){
    if (mapResult$Score[i] > 0) {
        smplTxt3<-c(smplTxt3,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'green'],"))
    } else if (mapResult$Score[i] < 0){
        smplTxt3<-c(smplTxt3,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'red'],"))
    } else {
        smplTxt3<-c(smplTxt3,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'blue'],")) 
    }
    
}

smplTxt3 <- paste(smplTxt3,collapse = '')


#ٍSourcesMap
#EFTEKEER TEZABAT EL SIZE
locatedTweets <- df[which(!is.na(df$longitude)),]
locatedTweets <- locatedTweets[which(locatedTweets$longitude != 0),]
locatedTweets$text <- as.character(locatedTweets$text)

locatedTweets$statusSource <- as.character(locatedTweets$statusSource)
sources <- character()
for (i in 1:nrow(locatedTweets)){
    part <- character()
    part <- strsplit(locatedTweets$statusSource[i],">")
    part <- part[[1]][2]
    part <- strsplit(part,"<")
    part <- part[[1]][1]
    sources <- c(sources,part)
}

smplTxt4 <- character()

for (i in 1:nrow(locatedTweets)){
    if (sources[i] == "Twitter for Android") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Android'],"))
    } else if (sources[i] == "Twitter for BlackBerry®") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'blackBerry'],"))
    } else if (sources[i] == "Instagram") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Instagram'],"))
    } else if (sources[i] == "Twitter for iPad") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Iphone'],"))
    } else if (sources[i] == "Twitter for iPhone") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Iphone'],"))
    } else if (sources[i] == "Twitter Web Client") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Twitter'],"))
    } else if (sources[i] == "Twitter for Windows Phone") {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'Twitter for Windows Phone'],"))
    }  else {
        smplTxt4<-c(smplTxt4,paste("[",locatedTweets$latitude[i],", ",locatedTweets$longitude[i],
                                   ", '",mapText[i],"', 'other'],"))
    }
    
}

smplTxt4 <- paste(smplTxt4,collapse = '')




output <- list(Positive=opinion[[3]],Negative=opinion[[1]],Neutral=opinion[[2]],
               mostRetweeted = df[which.max(df$retweetCount),1],
               mostFavorited = df[which.max(df$favoriteCount),1],
               hash1 = hash[1,1],hash2 = hash[2,1],hash3 = hash[3,1],
               numOfTweets = length(result$Tweet),
               numOfUsers = length(unique(df$screenName)),
               lineChart = smplTxt,
               from= as.character(df$created[nrow(df)]),
               to=as.character(df$created[1]),
               sourcePieChart = smplTxt2,
               mapData = smplTxt3,
               sourcesMapData = smplTxt4
               )

cat(toJSON(output))
}else {

  output <- list(Positive=opinion[[3]],Negative=opinion[[1]],Neutral=opinion[[2]],
                 mostRetweeted = df[which.max(df$retweetCount),1],
                 mostFavorited = df[which.max(df$favoriteCount),1],
                 hash1 = hash[1,1],hash2 = hash[2,1],hash3 = hash[3,1],
                 numOfTweets = length(result$Tweet),
                 numOfUsers = length(unique(df$screenName)),
                 lineChart = smplTxt,
                 from= as.character(df$created[nrow(df)]),
                 to=as.character(df$created[1]),
                 sourcePieChart = smplTxt2,
                 mapData = '',
                 sourcesMapData = ''
  )
  
  cat(toJSON(output))
  
}

#aggregate(tmp$score,by=list((substr(tmp$date,1,18))),mean)
#colnames(tmp) <- c("date","score")


