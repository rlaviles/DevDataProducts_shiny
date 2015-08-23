library(RCurl)
library(Hmisc)
library(leaflet)
library(stringi)
library(htmltools)
library(RColorBrewer)

shinyApp(
  ui = fluidPage(leafletOutput('myMap')),
  server = function(input, output) {
    x<-getURL("https://raw.githubusercontent.com/rlaviles/DevDataProducts_shiny/master/Quakes.csv")
    
    quakesRaw_n<- read.csv(text = x)
    
    qRaw_n <-quakesRaw_n[complete.cases(quakesRaw_n[,7]),]
    
    qRaw_n$time <- strptime(qRaw_n$time, format = "%Y-%m-%dT%H:%M:%S")
   
    magTime <- subset(qRaw_n, qRaw_n$mag>=5.8 & qRaw_n$time < '2010-02-28' & qRaw_n$mag!=8.8, select=c(qRaw_n$longitude, qRaw_n$latitude))

    map = leaflet() %>% 
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
    myMap <- renderLeaflet(map)
  })

