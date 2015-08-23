# For reasons I cannot understand, my application runs in my machine but
# I cannot port it to shinyapps, this is, the code is ported but not the leaflet
#       SO, I just have the code of my application!
# Also, I had it working in GIST: devtools::source_gist("43f4f16e7ca430a2315f", sha1="0aa320c8af36130597606f652aa545822d2dee98")
# but is not working now! So, the poorest of the solutions:
# Download this to your_machine/R_arena and execute
# a map of Chile area affected by the February 27, 2018 8.8 Richter Magnitude
# earthquake will be displayed and there you will be able to 'follow' the aftershocks
# of the first 24 hours after that main event; can you see it? many of these aftershocks
# have in common the same DEPTH, 35 kilometers. Well I was unable to do a better job!


library(RCurl)
library(Hmisc)
library(leaflet)
library(stringi)
library(htmltools)
library(RColorBrewer)

x<-getURL("https://raw.githubusercontent.com/rlaviles/DevDataProducts_shiny/master/Quakes.csv")
quakesRaw_n<- read.csv(text = x)

qRaw_n <-quakesRaw_n[complete.cases(quakesRaw_n[,7]),]
qRaw_n$latCut <- cut2(qRaw_n$latitude, g = 5)
qRaw_n$lonCut <- cut2(qRaw_n$longitude, g = 5)
qRaw_n$nstCut <- cut2(qRaw_n$nst, g = 5)
qRaw_n$log10depth <- log10(qRaw_n$depth + 1)
qRaw_n$time <- strptime(qRaw_n$time, format = "%Y-%m-%dT%H:%M:%S")
magTime <- subset(qRaw_n, qRaw_n$mag>=5.8 & qRaw_n$time < '2010-02-28' & qRaw_n$mag!=8.8, select=c(qRaw_n$longitude, qRaw_n$latitude))

leaflet() %>% 
  addTiles() %>% 
  addPopups(-72.898, -36.122, popup = "8.8Richter, Lat=-36.1, Lon=-72.9, Depth= 22.9[km], 2010/02/27") %>%
  addCircles(data=magTime[magTime$mag>5.8,], ~longitude, ~latitude, color="#03F", fill="#03F", radius=2500,
             popup=~sprintf("<b>Aftershock: %s</b><hr noshade size='1'/> 
                            Longitude: %1.3f<br/> 
                            Latitude: %1.3f<br/>
                            Magnitude: %1.3f [Richter]<br/>
                            Depth: %1.3f [km]", 
                            htmlEscape(time), htmlEscape(longitude), 
                            htmlEscape(latitude), htmlEscape(mag), 
                            htmlEscape(depth))) %>% html_print