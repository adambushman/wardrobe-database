#############################
# Exploratory Data Analysis #
# Wardrobe Database         #
# Adam Bushman              #
#############################


library('RMySQL')
library('tidyverse')
library('stringr')
library('wordcloud')


# Query Execute Function

execute <- function(query) {
  mydb = dbConnect(MySQL()
                   , user='AdamB'
                   , password='clt@42jSKNdXKzoHsV3Y'
                   , dbname='wardrobeDB'
                   , host='localhost')
  
  res <- dbSendQuery(mydb, query)
  
  raw <- dbFetch(res, n=-1) %>% data.frame(.)
  
  dbClearResult(res)
  dbDisconnect(mydb)
  
  return(raw)
}



# "WHAT I OWN" Keyword Cloud
# -----------------
own_items <- 
  execute(
    "SELECT *
    FROM vAllActiveItems;"
  )


# Data prep
kwData = 
  own_items %>%
  filter(!is.na(Keywords)) %>%
  select(Keywords) %>%
  pull(Keywords) %>%
  str_split(., ",") %>%
  unlist(.) %>%
  as.data.frame(.) %>%
  rename(keyword = ".") %>%
  count(keyword, sort = TRUE) %>%
  rename(freq = n)

set.seed(14) # for reproducibility 
wordcloud(words = kwData$keyword, freq = kwData$freq, 
          min.freq = 1, random.order=FALSE, 
          rot.per=0.35, colors=brewer.pal(8, "Dark2"))



# "WHAT I WEAR" Keyword Cloud
# -----------------
wear_items <- 
  execute(
    "SELECT af.`Fit Date/Time`, af.`Occassion`, aai.*
    FROM wFitItems fi
    LEFT JOIN vAllFits af ON af.`Fit ID` = fi.fitID
    LEFT JOIN vAllActiveItems aai ON aai.`Item ID` = fi.itemID
    WHERE af.`Fit Date/Time` BETWEEN DATE(NOW() - INTERVAL 3 month) AND NOW();"
  )


# Data prep
kwData = 
  wear_items %>%
  filter(!is.na(Keywords)) %>%
  select(Keywords) %>%
  pull(Keywords) %>%
  str_split(., ",") %>%
  unlist(.) %>%
  as.data.frame(.) %>%
  rename(keyword = ".") %>%
  count(keyword, sort = TRUE) %>%
  rename(freq = n)

wordcloud(words = kwData$keyword, freq = kwData$freq, 
          min.freq = 1, random.order=FALSE, 
          rot.per=0.35, colors=brewer.pal(8, "Dark2"))