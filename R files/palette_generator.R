#install.packages("RMySQL")
library(RMySQL)
library(dplyr)
library(lubridate)


printItemPal = function() {
  mydb = dbConnect(MySQL()
                   , user='AdamB'
                   , password='clt@42jSKNdXKzoHsV3Y'
                   , dbname='wardrobeDB'
                   , host='localhost')
  
  res = dbSendQuery(mydb, "SELECT * FROM vAllItemColors")
  data.colors = dbFetch(res, n=-1) %>%
    data.frame(.)
  
  dbDisconnect(mydb)
  printPal(data.colors, 'Wardrobe')
}

printFitPal = function(dateStart = NULL, dateEnd = NULL) {
  mydb = dbConnect(MySQL()
                   , user='AdamB'
                   , password='clt@42jSKNdXKzoHsV3Y'
                   , dbname='wardrobeDB'
                   , host='localhost')
  
  res = dbSendQuery(mydb, "SELECT * FROM vAllFitColors")
  data = dbFetch(res, n=-1)
  
  if(is.null(dateStart) || is.null(dateEnd)) {
    i = interval(date(min(data$fitDate)), date(max(data$fitDate)))
  } else {
    i = interval(date(dateStart), date(dateEnd))
  }

  data.colors = data %>%
    data.frame(.) %>% 
    mutate(fitDate = date(fitDate)) %>%
    filter(fitDate %within% i) %>%
    group_by(hexCode, commonName) %>%
    summarise(totalShare = sum(totalShare), .groups = 'drop')

  dbDisconnect(mydb)
  printPal(data.colors, 'Fit')
}

printPal = function(colorTbl, type) {
  data.colors = colorTbl %>%
    mutate(
      share = totalShare / sum(totalShare),
      portion = round(share * (50^2), 0)
    ) %>%
    arrange(commonName)
  
  par(bg = "#e8e8e4")
  plot(NULL
       , main = paste(type, "Color Palette")
       , xlim = c(1,50)
       , ylim = c(1,50)
       , xlab = ""
       , ylab = ""
       , xaxt = "n"
       , yaxt = "n")
  
  colorPlot = function(hex, xPos, yPos) {
    rect(xPos[1]
         , yPos[1]
         , xPos[2]
         , yPos[2]
         , col = hex
         , border = NA)
  }
  
  for(i in 1:nrow(data.colors)) {
    #Setup coordinates
    if(i == 1) {
      Y = c(49,50)
      X = c(0,1)
    }
    
    #Get a color and find out how much area
    color = data.colors$hexCode[i]
    squares = data.colors$portion[i]
    
    #Loop for to plot color units for appropriate amount of area
    for(j in 1:squares) {
      if(Y[1] < 0) {
        Y = Y + 50
        X = X + 1
      }
      
      #Plot the color unit
      colorPlot(color, X, Y)
      Y = Y - 1
    }
  }
}

par(mfrow = c(2, 1))
printItemPal()
printFitPal()
