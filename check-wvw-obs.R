# Check West Virginia White observations
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2019-05-17

rm(list = ls())

################################################################################
# Want to avoid Papilio rumiko / rumina disaster
# Definitely bad georefs in GBIF data; iNaturalist is OK
# See file read-in code (ca. line 28) for filtering option
# Note additional filtering on dates in GBIF data is warranted (01-Jan-1700)
library(ggplot2)
library(ggmap)
# Set timeout limit higher for slower connections
httr::set_config(httr::config(connecttimeout = 30))

# Plot either gbif data or iNaturalist data
# GBIF data:
# GBIF.org (18 May 2019) GBIF Occurrence 
# Download https://doi.org/10.15468/dl.yo1jwm 

plot.iNaturalist <- FALSE
if (plot.iNaturalist) {
  plot.data <- read.csv(file = "data/observations-52593.csv")
  latlongs <- unique(plot.data[, c("longitude", "latitude")])
  colnames(latlongs) <- c("Longitude", "Latitude")
} else {
  plot.data <- read.delim(file = "data/0015022-190415153152247.csv")
  plot.data <- plot.data[plot.data$decimalLatitude > 29, ]
  plot.data <- plot.data[plot.data$decimalLongitude > -100, ]
  latlongs <- unique(plot.data[, c("decimalLongitude", "decimalLatitude", "eventDate")])
  colnames(latlongs) <- c("Longitude", "Latitude", "Date")
}

# Drop duplicates and missing data
latlongs <- na.omit(latlongs)

map.bounds <- c(floor(min(c(latlongs$Longitude))),
                floor(min(c(latlongs$Latitude))),
                ceiling(max(c(latlongs$Longitude))),
                ceiling(max(c(latlongs$Latitude))))

# Get a map image
# Have to provide min/max for lat and long, otherwise will assume Google map,
# which requires API key
wvw.map <- get_map(location = map.bounds,
                   source = "stamen",
                   maptype = "terrain")

maptitle <- "P. virginiensis, "
if (plot.iNaturalist) {
  maptitle <- paste0(maptitle, "iNaturalist data")
} else {
  maptitle <- paste0(maptitle = "GBIF data")
}

wvw.obs.map <- ggmap(ggmap = wvw.map) +
  geom_point(data = latlongs,
             mapping = aes(x = Longitude, y = Latitude),
             size = 1.0) +
  theme_bw() +
  ggtitle(label = maptitle)
print(wvw.obs.map)
