#install.packages("RMySQL")
library(RMySQL)
library(dplyr)

mydb = dbConnect(MySQL()
                 , user='AdamB'
                 , password='clt@42jSKNdXKzoHsV3Y'
                 , dbname='wardrobeDB'
                 , host='localhost')

res = dbSendQuery(mydb, "SELECT c.hexCode, c.commonName, SUM(i.colorShare) total FROM wItemColors i JOIN wColor c ON c.hexCode = i.hexCode GROUP BY c.hexCode, c.commonName ORDER BY c.commonName, c.hexCode")
data = dbFetch(res, n=-1)

#Successfully pulled into a data frame
head(data)

dbDisconnect(mydb)

data.colors = data

data.colors$share = data.colors$total / sum(data.colors$total)
data.colors$portion = round(data.colors$share * (50^2), 0)

par(bg = "#e8e8e4")
plot(NULL
     , main = "Wardrobe Color Palette"
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
  
  #Get a color and find out how many area
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



#

mydb = dbConnect(MySQL()
                 , user='AdamB'
                 , password='clt@42jSKNdXKzoHsV3Y'
                 , dbname='wardrobeDB'
                 , host='localhost')

res = dbSendQuery(mydb, "SELECT witemtype.typeName, COUNT(witem.itemID) FROM witem LEFT JOIN witemtype ON witemtype.typeID = witem.itemtypeID GROUP BY witemtype.typeName;")
data = dbFetch(res, n=-1)

#Successfully pulled into a data frame
head(data)

dbDisconnect(mydb)

barplot(data$`COUNT(witem.itemID)`)
