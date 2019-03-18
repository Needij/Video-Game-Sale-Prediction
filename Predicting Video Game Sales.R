#VGChartz website has 55,002 games listed in their table with varying amounts of sales data.
gamedata <- data.frame()
for (i in 1:1101){
  #VG Chartz has table that contains video games with sales numbers
  require(XML)
  #create url
  url <- paste("http://www.vgchartz.com/games/games.php?page=", i, "&results=50&name=&console=&keyword=&publisher=&genre=&order=Sales&ownership=Both&boxart=Both&banner=Both&showdeleted=&region=All&goty_year=&developer=&direction=DESC&showtotalsales=1&shownasales=1&showpalsales=1&showjapansales=1&showothersales=1&showpublisher=1&showdeveloper=1&showreleasedate=1&showlastupdate=1&showvgchartzscore=1&showcriticscore=1&showuserscore=1&showshipped=1&alphasort=&showmultiplat=No", sep = "")
  #create prelminary data table, ignore first two rows from VG chartz website
  prelimtable <- readHTMLTable(url, which = 7, skip.rows = c(1,2))
  #change col names
  colnames(prelimtable) <- c("Pos", "Box Art", "Game", "Console", "Publisher", "Developer", "VGChartz Score", "Critic Score", "User Score", "Total Shipped",	"Total Sales",	"NA Sales", "PAL Sales",	"Japan Sales",	"Other Sales",	"Release Date",	"Last Update")
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
  #put system to sleep for 5 seconds to prevent VG Chartz from registering attack/serverv side issues.
  Sys.sleep(5) 
  print(i)#to know what iteration just completed
}

View(gamedata)
str(gamedata)
