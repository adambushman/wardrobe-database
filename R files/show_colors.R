library(RMySQL)
library(dplyr)

mydb = dbConnect(MySQL()
                 , user='AdamB'
                 , password='clt@42jSKNdXKzoHsV3Y'
                 , dbname='wardrobeDB'
                 , host='localhost')

res = dbSendQuery(mydb, "SELECT * FROM vAllItemColors")
data.colors = dbFetch(res, n=-1)

dbDisconnect(mydb)

print.palette <- function(x, ...) {
  n <- length(x)
  old <- par(mar = c(0.5, 0.5, 0.5, 0.5))
  on.exit(par(old))
  
  image(1:n, 1, as.matrix(1:n), col = x,
        ylab = "", xaxt = "n", yaxt = "n", bty = "n")
  
  #rect(0, 0.92, n + 1, 1.08, col = rgb(1, 1, 1, 0.8), border = NA)
  #text((n + 1) / 2, 1, labels = attr(x, "name"), cex = 2.5, family = "serif")
}

cols = c(unname(data.colors %>% filter(commonName %in% c('White')) %>% select(hexCode))[[1]])
print.palette(cols)
cols[1]
