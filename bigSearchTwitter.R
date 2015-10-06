
Sys.setenv(HADOOP_HOME="/usr/local/hadoop/")
Sys.setenv(HADOOP_BIN="/usr/local/hadoop/bin")
Sys.setenv(HADOOP_CONF_DIR="/usr/local/hadoop/conf")
Sys.setenv(HADOOP_CMD="/usr/local/hadoop/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/usr/local/hadoop/contrib/streaming/hadoop-streaming-1.2.1.jar")
Sys.setenv(JAVA_HOME='/usr/lib/jvm/java-7-openjdk-amd64')

source("http://127.0.0.1/DataPedia/bigScor.r")
source("http://127.0.0.1/DataPedia/scor.R")

library("rJava", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("rJava", lib.loc="/usr/local/lib/R/site-library")
library("RJSONIO", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("itertools", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("digest", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("Rcpp", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("httr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("functional", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("devtools", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("plyr", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library("reshape2", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
library(stringr)

library("rmr2", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")

library("rhdfs", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.1")
#hdfs.mkdir("/users/rtask/")
#hdfs.mkdir("/users/rtaskoutput/")
#hdfs.put("/var/www/html/GP-last-task_v4//tst",dest = "/users/rtask")

args <- commandArgs(TRUE)

N <- args[1]
#N<- "21-4.csv"
path <- paste("http://127.0.0.1/DataPedia/",N,sep = "")
df <- read.csv(path)
#df <- read.csv("http://127.0.0.1/DataPedia/bigDataOrg.csv")
df <- df[!duplicated(df[,c('text')]),]
#t <- df[1,]
df$text <- as.character(df$text)
Text <- df$text
Text <- as.character(Text)

#Text = gsub('[[:punct:]]', '', Text)
Text = gsub("\\.", " . ", Text)
Text = gsub("," , " , ", Text)
Text = gsub("\\?", " ? ", Text)
Text = gsub("!", " ! ", Text)
Text = gsub('[[:cntrl:]]', '', Text)
Text = gsub('\\d+', '', Text)
Text = gsub('"', ' " ', Text)
Text = iconv(Text, "latin1", "ASCII", sub="")
# # and convert to lower case:
Text = tolower(Text)
Text <- paste(' ', Text, ' ')
Text <- paste(Text,"\r\n")
#write.table(Text,"Downloads/babasa/text.txt")

hdfs.init()
#Text <- Text[1:100]
input = to.dfs(Text,format = "text")

#hdfs.mkdir("/user/abanou/tst")
#hdfs.put("/home/abanoub/dataspli/newab","/users/tst")

lexicon <- read.table("http://127.0.0.1/DataPedia/FinalLexicon.txt")

    score <- function(input, lexicon, output=NULL){
        
        wc.map = function(.,lines){
            keyval(lines,bigscore.sentiment(lines,lexicon))
        }
        
        wc.reduce = function(k,counts){
           keyval(k,sum(counts))
        }
        
        mapreduce(input = input, output = output, map = wc.map, reduce = wc.reduce, input.format = "text",combine = T,
        backend.parameters = list(hadoop=list(D='mapred.reduce.tasks=2',D='mapred.map.tasks=4')))
    }
#,backend.parameters = list(hadoop=list(D='mapred.reduce.tasks=1',D='mapred.map.tasks=2'))

result <- as.data.frame(from.dfs(score(input,lexicon)))
colnames(result)<-c("Tweet","Score")

#hashtags
hasht <- as.character(result$Tweet)
hasht <- hasht[1:1000]
hasht <- unlist(hasht)
hasht <- paste(hasht,collapse=" ")
hasht <- str_split(hasht, '\\s+')
hasht <- unlist(hasht)
hasht <- grep("^#",hasht,perl = T,value = T)
hash <- as.data.frame(table(hasht))
hash <- arrange(hash,desc(hash$Freq))

#piechart
opinion <- table(sign(result$Score))

#lineChart
timeData <- aggregate(result$Score, by=list(0:(length(result$Score)-1) %/% 13000), mean)
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


#map
#EFTEKEER TEZABAT EL SIZE
locatedTweets <- df[which(!is.na(df$longitude)),]
locatedTweets <- locatedTweets[which(locatedTweets$longitude != 0),]
locatedTweets$text <- as.character(locatedTweets$text)
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
               mostRetweeted = df[which.max(df$retweetCount),2],
               mostFavorited = df[which.max(df$favoriteCount),2],
               hash1 = hash[1,1],hash2 = hash[2,1],hash3 = hash[3,1],
               numOfTweets = length(result$Tweet),
               numOfUsers = length(unique(df$screenName)),
               lineChart = smplTxt,
               to= as.character(df$created[nrow(df)]),
               from=as.character(df$created[1]),
               sourcePieChart = smplTxt2,
               mapData = smplTxt3,
               sourcesMapData = smplTxt4
)

cat(toJSON(output))
