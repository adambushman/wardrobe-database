#############################
# Exploratory Data Analysis #
# Wardrobe Database         #
# Adam Bushman              #
#############################


library('RMySQL')
library('dplyr')
library('tidyr')
library('ggplot2')
library('stringr')
library('wordcloud')

# Querying data for clothing items
mydb = dbConnect(MySQL()
                 , user='AdamB'
                 , password='clt@42jSKNdXKzoHsV3Y'
                 , dbname='wardrobeDB'
                 , host='localhost')

res = dbSendQuery(mydb, "SELECT * FROM vAllActiveItems")
clothing = dbFetch(res, n=-1)

dbDisconnect(mydb)




# Clothing types
# --------------
ggplot(data = clothing %>% count(Type), 
       aes(x = n, y = reorder(Type, n))) +
  geom_bar(stat = "identity", aes(fill = Type), 
           show.legend = FALSE) +
  labs(title = 'Clothing Category Frequency',
       subtitle = 'Wardrobe Database', 
       y = '', 
       x = 'Count of Items in Wardrobe') +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = 'bold'), 
    plot.subtitle = element_text(hjust = 0.5, size =12, face = 'italic')
  )


# Ratios
# ------
topsToBottoms = nrow(clothing %>% filter(Type == 'Shirts')) / nrow(clothing %>% filter(Type %in% c('Shorts', 'Pants')))
print(paste('Tops to Bottoms: ', round(topsToBottoms, 1), ':1', sep = ''))



# Clothing Keywords
# -----------------
kwData = 
  clothing %>%
  select(Keywords) %>%
  filter(!is.na(Keywords)) %>%
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
