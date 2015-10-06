bigscore.sentiment = function(Text, lexicon, .progress='none')
{
    require(plyr)
    require(stringr)
    
    # we got a vector of sentences. plyr will handle a list
    # or a vector as an "l" for us
    # we want a simple array ("a") of scores back, so we use 
    # "l" + "a" + "ply" = "laply":
    scores = laply(Text, function(Text, lexicon) {
        
        # clean up sentences with R's regex-driven global substitute, gsub():
        
        
        # split into words. str_split is in the stringr package
        word.list = str_split(Text, '\\s+')
        # sometimes a list() is one level of hierarchy too much
        #words = unlist(word.list)
        negation <- c("can't","wouldn't","not","shouldn't","isn't","aren't","couldn't"
                      ,"mustn't","don't","doesn't","didn't"
                      ,"won't","hasn't","haven't","hadn't","nobody")
        # compare our words to the dictionaries of positive & negative terms
        sc = lapply( word.list, function (x){
            #print(x)
            sign <-  T 
            sc <- numeric()
            for(i in 1:length(x)){
                match <- match(x[i],lexicon$Word)
                if (sum(match(x[i],negation),na.rm = T)) {
                    sign <- F
                }
                if("." == x[i]){
                    sign <- T
                }
                else if ("," == x[i]){
                    sign <- T
                }
                else if ("?" == x[i]){
                    sign <- T
                }
                
                if(sign) {
                    sc <- c(sc,lexicon$Score[match])
                }
                else {
                    sc <- c(sc,lexicon$Score[match]*-1)
                } 
            }
            sc <- sum(sc,na.rm = T)
            return (sc)
            #       matches <- match(x ,lexicon$Word )
            #       sc <- lexicon$Score[matches]
            #       sc <- sum(lexicon$Score[matches],na.rm = T)
            #       if(sum(negation %in% x)) {return (sc*-1)}
            #       else {return (sc)}
        } )       
        return(sc)
    }, lexicon , .progress=.progress )
    sc = unlist(scores)
    scores.df = data.frame(Tweet=Text, Score=sc)
    return(scores.df$Score)
}