library('RMySQL')
library('tidyverse')
library('lubridate')

camcorder::gg_record(
  dir = 'C:/Users/Adam Bushman/Pictures/_test', 
  device = 'png', 
  width = 10, 
  height = 10, 
  units = 'cm', 
  dpi = 300
)


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


# Get Data

fit <- 
  execute("SELECT typeName, hexCode
FROM wFitItems fi
LEFT JOIN wItemColors c
	ON c.itemId = fi.itemId
LEFT JOIN (
	SELECT * FROM wItem i LEFT JOIN wItemType it ON i.itemTypeId = it.typeId
	) im ON im.itemId = fi.itemId
WHERE fi.fitId = (SELECT MAX(fitID) - 25 FROM wFit)
GROUP BY typeName, hexCode;") %>%
  mutate(
    typeName = factor(typeName, levels = rev(c(
      "Hats", "Jackets", "Sweaters", "Sweatshirts", "Blazer", "Suits", "Dresses", 
      "Shirts", "Ties", "Belts", "Pants", "Shorts", "Skirts", "Shoes"
    ))))


ggplot(
  fit, 
  aes(x = typeName)
) +
  geom_dotplot(
    fill = fit$hexCode, 
    dotsize = 8
  ) +
  coord_flip() +
  ylim(0, 0.5) +
  labs(
    title = "Fit ID Something"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#D7DEDC", color = NA), 
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16), 
    axis.text.x = element_blank(), 
    axis.title = element_blank()
  )
