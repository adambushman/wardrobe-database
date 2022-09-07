#install.packages("RMySQL")
library(RMySQL)
library('tidyverse')
library(lubridate)


###
# Get Color Data
###

get_colors <- function(type = c("items", "fits"), dateRange = NULL) {
  mydb = dbConnect(MySQL()
                   , user='AdamB'
                   , password='clt@42jSKNdXKzoHsV3Y'
                   , dbname='wardrobeDB'
                   , host='localhost')
  
  if(type == "items") {
    res <- dbSendQuery(mydb, "SELECT * FROM vAllItemColors")
  }
  else {
    res <- dbSendQuery(mydb, "SELECT * FROM vAllFitColors")
  }
  
  raw <- dbFetch(res, n=-1) %>% data.frame(.)
  
  dbClearResult(res)
  dbDisconnect(mydb)
  
  if(type == "fits") {
    if(is.null(dateRange)) {
      today = ymd(Sys.Date())
      dateRange = c(today - 90, today)
    }
    dateRange = ymd(dateRange)
    if(dateRange[1] > dateRange[2]) {
      dateRange = rev(dateRange)
    }
    raw <-
      raw %>%
      mutate(fitDate = ymd(fitDate)) %>%
      filter(fitDate %within% interval(dateRange[1], dateRange[2]))
  }
    
  raw  %>% 
    group_by(hexCode, commonName) %>%
    summarise(totalShare = sum(totalShare), .groups = 'drop')
}


colors.all <- 
  get_colors("items") %>%
  mutate(
    type = "Wardrobe Items"
  ) %>%
  select(type, hexCode, commonName, totalShare) %>%
  rbind(
    get_colors("fits") %>%
      mutate(
        type = "Outfit Items"
      ) %>%
      select(type, hexCode, commonName, totalShare)
  )


###
# Print Palette Function
###


p.data <- 
  colors.all %>%
  group_by(type, commonName, hexCode) %>%
  summarise(share = sum(totalShare), .groups = 'drop') %>%
  group_by(type, commonName) %>%
  mutate(
    id = paste(type, commonName), 
    ymax = cumsum(share), 
    ymin = ymax - share
  ) %>%
  inner_join(
    colors.all %>%
      group_by(type, commonName) %>%
      summarise(share = sum(totalShare), .groups = 'drop') %>%
      group_by(type) %>%
      mutate(
        id = paste(type, commonName), 
        xmax = cumsum(share), 
        xmin = xmax - share
      ), 
    by = c("id" = "id")
  ) %>%
  group_by(type.x) %>%
  mutate(
    xmax_s = xmax / max(xmax, xmin), 
    xmin_s = xmin / max(xmax, xmin)
  ) %>%
  group_by(type.x, commonName.x) %>%
  mutate(
    ymax_s = ymax / max(ymax, ymin), 
    ymin_s = ymin / max(ymax, ymin)
  ) %>%
  select(type.x, commonName.x, hexCode, xmax_s, xmin_s, ymax_s, ymin_s)

 

ggplot(p.data, aes(xmin = xmin_s, xmax = xmax_s, ymin = ymin_s, ymax = ymax_s, 
             fill = hexCode)) +
  geom_rect(show.legend = FALSE, fill = p.data$hexCode) +
  facet_wrap(~type.x, nrow = 2, ncol = 1) + 
  labs(
    title = "Wardrobe Color Comparison", 
    subtitle = "Wardrobe Items (Actives) vs Outfit Items (Worn in Past 3 Months)"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", color = "#53c3ce"), 
    plot.subtitle = element_text(hjust = 0.5, face = "italic", color = "#333333"), 
    plot.background = element_rect(fill = "#f1f7f4"), 
    
    panel.background = element_rect(fill = "#f1f7f4"), 
    panel.grid = element_blank(), 
    
    strip.background = element_rect(color = "#333333", fill = NA), 
    strip.text = element_text(face = "bold", color = "#333333"), 
    
    axis.title = element_blank(), 
    axis.text = element_blank(), 
    axis.ticks = element_blank()
  )
