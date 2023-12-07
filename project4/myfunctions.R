gen_rec = function(genre) {
  movies = read_csv("movies.csv")[-1]
  
  ratings = as.data.frame(read_csv("ratings.csv")[-1])
  colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
  
  full = left_join(ratings, movies, by = "MovieID")
  
  full %>% 
      group_by(MovieID) %>% 
      filter(grepl(genre, Genres)) %>% 
      summarise(avg_rating = mean(Rating), n = n()) %>% 
      filter(n > 50) %>% 
      arrange(desc(avg_rating)) %>% 
      head(10)
  
}

myIBCF = function(newuser) {
  
  movies = read_csv("movies.csv")[-1]
  
  ratings = as.data.frame(read_csv("ratings.csv")[-1])
  colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
  
  S = as.matrix(read_csv("sim.csv"))
  colnames(S) = paste0("m", sort(unique(ratings$MovieID)))
  rownames(S) = paste0("m", sort(unique(ratings$MovieID)))
  
  preds = c()
  for (l in rownames(S)) {
    s = S[l, which(!is.na(S[l, ]))]
    w = newuser[which(!is.na(S[l, ]))]
    
    pred = sum(s * w, na.rm = TRUE) / sum(s * ifelse(!is.na(w), 1, 0), na.rm = TRUE)
    preds = c(preds, pred)
  }
  
  # setting already rated movies to NA
  preds[!is.na(newuser)] = NA
  
  # getting top 10 predicted ratings
  names(preds) = colnames(S)
  toReturn = data.frame(movie = names(preds[order(preds, decreasing = TRUE)][1:10]), 
                        predicted = preds[order(preds, decreasing = TRUE)][1:10])
  
  # in case there are less than 10 non-NA predictions
  if (!all(!is.na(toReturn$predicted))) {
    
    # getting NA indices
    NAs = which(is.na(toReturn$predicted))
    nonNAs = which(!is.na(toReturn$predicted))
    
    # if all are NA, randomly return movies
    if (length(nonNAs) == 0) {
      toReturn$movie = sample(colnames(S), 10)
      
      # otherwise get top genre of those recommended and use part 1 recommender
    } else {
      
      # getting IDs of movies that have already been recommended
      IDs = data.frame(MovieID = as.numeric(str_remove_all(toReturn$movie[nonNAs], "m")))
      
      # getting genre counts of movies that have already been recommended
      tab = table(unname(unlist(sapply(left_join(IDs, movies, by = "MovieID")$Genres, function(movie) {
        strsplit(movie, "|", fixed = TRUE)
      }))))
      
      # getting top genre(s) of movies that have already been recommended
      topgenres = which(tab == max(tab))
      
      # if tie for top genre, select one and output movies using part 1
      if (length(topgenres) > 1) {
        toReturn$movie[NAs] = paste0("m", gen_rec(names(tab)[sample(topgenres, 1)])$MovieID[1:length(NAs)])
      } else {
        toReturn$movie[NAs] = paste0("m", gen_rec(names(tab)[which.max(tab)])$MovieID[1:length(NAs)])
      }
      
    }
    
  }
  
  toReturn
  
}
