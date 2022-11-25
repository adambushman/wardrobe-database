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
  

freq <- 
  execute("SELECT t.typeName, f.freq, t.total, f.freq / t.total AS usagerate
FROM (
  SELECT wItemType.typeName, COUNT(DISTINCT wFitItems.itemID) AS freq
  FROM wFitItems
  INNER JOIN wFit ON wFit.fitID = wFitItems.fitID
  INNER JOIN wItem ON wItem.itemID = wFitItems.itemID
  INNER JOIN wItemType ON wItemType.typeID = wItem.itemTypeId
  WHERE wItem.active = TRUE
  AND wFit.fitDateTime >= DATE(now() - INTERVAL 3 MONTH)
  GROUP BY wItemType.typeName
) f
INNER JOIN (
  SELECT wItemType.typeName, COUNT(itemID) AS total 
  FROM wItem 
  JOIN wItemType ON wItemType.typeID = wItem.itemTypeId 
  WHERE active = TRUE
  GROUP BY wItemType.typeName
) t ON t.typeName = f.typeName
ORDER BY t.total DESC, f.freq DESC;")



freq %>%
  mutate(
    ymax_s = cumsum(total), 
    ymin_s = ymax_s - total, 
    xmax_s = usagerate, 
    xmin_s = 0, 
    xlab = 0, 
    ylab = ((ymax_s - ymin_s) / 2) + ymin_s
  ) %>%
  ggplot(
    ., 
    aes(xmin = xmin_s, xmax = xmax_s, 
        ymin = ymin_s, ymax = ymax_s, 
        label = typeName)
  ) +
  geom_rect(
    show.legend = FALSE, 
    fill = "#6D9F71", 
    color = "black", 
    size = 0.25
  ) +
  geom_vline(
    xintercept = 0.7, 
    color = "#51344D", 
    linetype = 'dashed', 
    size = 0.65
  ) +
  xlim(-0.15, 1) +
  ylim(0, 165) +
  ggrepel::geom_text_repel(
    aes(xlab, ylab), 
    size = 2.5,
    force = 0.5,
    nudge_x = -0.15,
    direction = "y",
    hjust = 1,
    segment.size = 0.2,
    segment.curvature = -0.1
  ) +
  annotate(
    "text", 
    x = 0.72, y = 165,
    hjust = 0, 
    color = "#51344D", 
    size = 3.25, 
    label = "Usage\nGoal"
  ) +
  labs(
    title = "Clothing Type Usage", 
    subtitle = "Past 3 Months Fit Data", 
    x = "Usage Rate"
  ) +
  theme_minimal() +
  theme(
    # Text
    plot.title = element_text(size = 15, hjust = 0.5, face = "bold"), 
    plot.subtitle = element_text(hjust = 0.5), 
    
    # Other Styling
    plot.background = element_rect(fill = "#D7DEDC", color = NA), 
    axis.text.y = element_blank(), 
    axis.title.y = element_blank()
  )
  

