#VGChartz website has 55,002 games listed in their table with varying amounts of sales data.
#VG Chartz has table that contains video games with sales numbers
library(rvest)
library(XML)

#read default webpage to get the number
webpage <- read_html("http://www.vgchartz.com/games/games.php?page=1&results=50&name=&console=&keyword=&publisher=&genre=&order=Sales&ownership=Both&boxart=Both&banner=Both&showdeleted=&region=All&goty_year=&developer=&direction=DESC&showtotalsales=1&shownasales=1&showpalsales=1&showjapansales=1&showothersales=1&showpublisher=1&showdeveloper=1&showreleasedate=1&showlastupdate=1&showvgchartzscore=1&showcriticscore=1&showuserscore=1&showshipped=1&alphasort=&showmultiplat=No")

#change webpage to text#
webpagetext <- as.character(webpage)

#split text before where the number of games is shown
splittext <- strsplit(webpagetext, "Results: (", fixed = T)
firsthalf <- unlist(splittext)[2]

#remove text after the number of games is shown
splittext <- strsplit(firsthalf, ")", fixed = T)
secondhalf <- unlist(splittext)[1]

#change number shown to be converted to a number
numgames <- as.numeric(gsub(",", "", secondhalf))

#determine number of iterations
numiterations <- ceiling(numgames / 250)

#create empty dataframe to hold data
gamedata <- data.frame()
for (i in 1:numiterations){
  #create url
  url <- paste("http://www.vgchartz.com/games/games.php?page=", i, "&results=250&name=&console=&keyword=&publisher=&genre=&order=Sales&ownership=Both&boxart=Both&banner=Both&showdeleted=&region=All&goty_year=&developer=&direction=DESC&showtotalsales=1&shownasales=1&showpalsales=1&showjapansales=1&showothersales=1&showpublisher=1&showdeveloper=1&showreleasedate=1&showlastupdate=1&showvgchartzscore=1&showcriticscore=1&showuserscore=1&showshipped=1&alphasort=&showmultiplat=No", sep = "")
  #create prelminary data table, ignore first two rows from VG chartz website
  prelimtable <- readHTMLTable(url, which = 7, skip.rows = c(1,2))
  #change col names
  colnames(prelimtable) <- c("Pos", "Box_Art", "Game", "Console", "Publisher", "Developer", "VGChartz_Score", "Critic_Score", "User_Score", "Total_Shipped",	"Total_Sales",	"NA_Sales", "PAL_Sales",	"Japan_Sales",	"Other_Sales",	"Release_Date",	"Last_Update")
  #Consoles are displayed using an image, the alt text is needed for this column
  consoles <- url %>% read_html() %>% html_nodes("td") %>% html_node("img") %>% html_attr("alt")
  #remove alt text that did not exist
  consoles <- subset(consoles, !is.na(consoles))
  #remove alt text for box arts (also displayed using images)
  consoles <- subset(consoles, consoles != "Boxart Missing")
  #add consoles to data table
  prelimtable$Console <- consoles
  #remove "Read the review" from game titles
  prelimtable$Game <- gsub("Read the review", "", prelimtable$Game)
  #bind with data frame
  gamedata <- rbind(gamedata, prelimtable)
  #put system to sleep for 5 seconds to prevent VG Chartz from registering attack/server side issues.
  Sys.sleep(5) 
  print(round(i/numiterations*100, 1))#print percentage completed
}
#remove extra characters from the name of the game
gamedata$Game <- trimws(gamedata$Game)

#write basic data file
write.csv(gamedata, file = "VGChartz_data.csv")

View(gamedata)
str(gamedata)
      