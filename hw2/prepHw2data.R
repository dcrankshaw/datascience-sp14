library(plyr)

load_play_data <- function(fname="lastfm-dataset-1K/userid-timestamp-artid-artname-traid-traname.tsv") {
  res <- read.delim(fname, as.is=T, head=F, quote="", col.names=c('userid','timestamp','artid','artname','traid','traname'))
  res$key <- with(res, paste(artid,traid))
  res$timestamp <- as.Date(substr(res$timestamp, 1, 10))
  res
}

load_user_data <- function(fname="lastfm-dataset-1K/userid-profile.tsv") {
  user_data <- read.delim(fname, as.is=T, quote="")
  colnames(user_data)[1] <- "userid"
  user_data$registered <- as.Date(strptime(user_data$registered, "%b %d, %Y"))
  user_data
}

compute_agg_data <- function(df) {
  aggdf <- as.data.frame(table(df$key))
  colnames(aggdf) <- c('key','plays')
  aggdf
}

create_full_agg <- function(df, agg, userdf, thresh=25) {
  fulldf <- subset(df, key %in% subset(agg, plays > thresh)$key)
  z <- merge(fulldf, userdf, by='userid')
  z$datediff <- with(z, as.numeric(timestamp-registered))
  z
}

compute_track_stats <- function(df) {
  group_stats <- function(x) {
    tot <- nrow(x)
    pctmale <- sum(x$gender == 'm', na.rm=T)/tot
    age <- mean(x$age, na.rm=T)
    
    countries <- names(sort(table(x$country), decreasing=T))
    country1 <- countries[1]
    country2 <- countries[2]
    country3 <- countries[3]
    
    usertab <- table(x$user)
    pctgt1 <- length(usertab[usertab > 1])/length(usertab)
    pctgt2 <- length(usertab[usertab > 2])/length(usertab)
    pctgt5 <- length(usertab[usertab > 5])/length(usertab)
    
    account_age <- mean(x$datediff, na.rm=T)   
    
    c(pctmale, age, country1, country2, country3, pctgt1, pctgt2, pctgt5, account_age)
  }

  ddply(df, 'key', group_stats)
}



make_model_data <- function(agg_data, stats_data) {
  merge(agg_data, stats_data)
}

user_artist_matrix <- function(play_data, user_min=0, artist_min=50) {
  arttab <- table(play_data$artid)
  usertab <- table(play_data$userid)
  
  usernames <- names(usertab[usertab > user_min])
  artids <- names(arttab[arttab > artist_min])
  
  userartdf <- unique(subset(play_data, artid %in% artids)[,c('artid','userid')])
  userartdf <- subset(userartdf, artid != "" & userid != "")
  
  userartmat <- with(userartdf, matrix(0, length(unique(artid)), length(unique(userid)), dimnames=list(unique(artid),unique(userid))))
  
  #This could be replaced with counts if we want.
  userartmat[as.matrix(userartdf)] <- 1
  userartmat
}


main <- function() {
  print("Loading data")
  play_data <- load_play_data()

  print("Eliminating records without mbids")
  play_data <- subset(play_data, key!= " ")

  print("Loading user data.")
  user_data <- load_user_data()

  print("Computing aggregate data")
  agg_data <- compute_agg_data(play_data)

  print("Combining aggregate data, user data, and play data")
  full_data <- create_full_agg(play_data, agg_data, user_data)

  print("Computing stats.")
  stats_data <- compute_track_stats(full_data)

  print("Computing user artist matrix")
  userart_data <- user_artist_matrix(play_data)

  print("Computing kmeans model")
  kmeans_model <- kmeans(userart_data, 25)

  print("Generating model data")
  model_data <- make_model_data(agg_data, stats_data)

  #Write out intermediate datasets.
  print("Saving datasets.")
  save(play_data, user_data, agg_data, full_data, stats_data, model_data, userart_data, file="intermediate_data.robj")

}

build_dependent_dsets <- function(play_data) {
  print("Loading user data.")
  user_data <- load_user_data()

  print("Computing aggregate data")
  agg_data <- compute_agg_data(play_data)

  print("Combining aggregate data, user data, and play data")
  full_data <- create_full_agg(play_data, agg_data, user_data)

  print("Computing stats.")
  stats_data <- compute_track_stats(full_data)

  print("Generating model data")
  model_data <- make_model_data(agg_data, stats_data)
  
  list(user_data=user_data, agg_data=agg_data, full_data=full_data, stats_data=stats_data, model_data=model_data)
  
}

train_data <- subset(play_data, userid < "user_000900" & timestamp < "2009-01-01")
validation_data <- subset(play_data, (userid >= "user_000900" & timestamp < "2009-01-01") | (userid < "user_000900" & timestamp >= "2009-01-01"))
test_data <- subset(play_data, userid >= "user_000900" & timestamp >= "2009-01-01")


test_data_sets <- build_dependent_dsets(test_data)
validataion_data_sets <- build_dependent_dsets(validation_data)
train_data_sets <- build_dependent_dsets(train_data)

save(test_data_sets, validataion_data_sets, train_data_sets, file="modeling_data.robj")

merge_km <- function(model_data, kmeans_model) {
  model_data$artid <- unlist(lapply(strsplit(as.character(model_data$key), " "), function(k) k[[1]]))
  merge(model_data, kmeans_model$cluster, by.x='artid', by.y=0)
}

clean_model_data <- function(model_data_base) {
  model_data <- model_data_base
  colnames(model_data) <- c('artid','key','plays','pctmale','age','country1','country2','country3','pctgt1','pctgt2','pctgt5','account_age', 'cluster')
  numcols <- c('plays','pctmale','age','pctgt1','pctgt2','pctgt5','account_age')
  charcols <- c('artid','key')
  faccols <- c('country1','country2','country3', 'cluster')
  model_data[,numcols] <- sapply(model_data[,numcols,drop=F], as.numeric)
  model_data[,charcols] <- sapply(model_data[,charcols,drop=F], as.character)
  model_data[,faccols] <- sapply(model_data[,faccols,drop=F], as.factor)

  model_data
}