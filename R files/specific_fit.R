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
  execute(
    "SELECT f.fitDate, i.typeName, o.occasionName, f.hexCode, w.words
    FROM (
    	SELECT
    		fi.fitID, fi.itemID, 
    		DATE_FORMAT(f.fitDateTime, '%M %e, %Y') AS fitDate, 
            f.occasionID, ic.hexCode
        FROM wFitItems fi
        LEFT JOIN wFit f ON f.fitID = fi.fitID
        LEFT JOIN wItemColors ic ON ic.itemID = fi.itemID
    ) f
    LEFT JOIN (
    	SELECT itemID, typeName
        FROM wItemType it
        LEFT JOIN wItem i ON i.itemTypeId = it.typeID
    ) i ON i.itemID = f.itemID
    LEFT JOIN (
    	SELECT f.fitID, fo.occasionName
        FROM wFit f
        LEFT JOIN wFitOccasion fo ON fo.occasionID = f.occasionID
    ) o ON o.fitID = f.fitID
    LEFT JOIN (
    	SELECT ik.itemID, GROUP_CONCAT(' ', k.word) AS words
    	FROM wItemKeywords ik
    	LEFT JOIN wKeyword k ON k.wordID = ik.wordID
    	LEFT JOIN wItem i ON i.itemID = ik.itemID
    	GROUP BY ik.itemID
    ) w ON w.itemID = f.itemID
    WHERE f.fitID = 339;"
  ) %>%
  mutate(
    xlab = 0.5, 
    words = stringr::str_wrap(words, 12), 
    typeName = factor(typeName, levels = rev(c(
      "Hats", "Jackets", "Sweaters", "Sweatshirts", "Blazer", "Suits", "Dresses", 
      "Shirts", "Ties", "Belts", "Pants", "Shorts", "Skirts", "Shoes"
    )))) %>%
  arrange(typeName)


ggplot(
  fit, 
  aes(x = typeName, label = words)
) +
  geom_dotplot(
    fill = fit$hexCode, 
    dotsize = 8
  ) +
  geom_text(
    aes(x = typeName, y = xlab), 
    hjust = 1, 
    size = 3
  ) +
  coord_flip() +
  ylim(0, 0.5) +
  labs(
    title = "Fit Palette", 
    subtitle = paste(
      fit$fitDate[1], 
      fit$occasionName[1], 
      sep = " | "
    )
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#D7DEDC", color = NA), 
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16), 
    plot.subtitle = element_text(hjust = 0.5, face = "italic", size = 10),
    axis.text.x = element_blank(), 
    axis.text.y = element_text(size = 10), 
    axis.title = element_blank()
  )
