#!/usr/bin/Rscript

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(getopt)
library(tidyr)

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
command = matrix(c(
    'input', 'i', 1, "character",
    'output', 'o', 1, "character"), byrow=TRUE, ncol=4)

args = getopt(command)


##help info--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (!is.null(args$help) || is.null(args$input) || is.null(args$output)) {
  cat(paste(getopt(command, usage = T), "\n"))
  q()
}


## --------------------------------------------------Pre-processsing phenotype worksheet--------------------------------------------------------------------------------------------
#load phenotyping worksheet
Raspi <- read.csv(args$input, header = T)

#Split Time series information
Raspi <- Raspi %>% separate(plantID, c("RasPi.ID","Cam.ID", "timestamp", "ID"))

#Remove NA rows
Raspi <- na.omit(Raspi)

# substring month, hour, minute for each time stamp
Raspi$month <- substr(Raspi$timestamp, 1,1)
Raspi$day <- substr(Raspi$timestamp, 2, 3)
Raspi$hour <- substr(Raspi$timestamp, 4, 5)
Raspi$min <- substr(Raspi$timestamp, 6, 7)

# Transform data type for time series
numeric_list <- c("month", "day", "hour", "min")
for (num in numeric_list){
  Raspi[, num] <- as.numeric(as.character(Raspi[, num]))
}

#Order the time series based on Plant-ID and month-day-hour-min manner
Raspi <- Raspi[
  order(Raspi[,19], Raspi[,20], Raspi[,21], Raspi[,22], Raspi[,18]),
]

#disable the row name
rownames(Raspi) <- NULL

## --------------------------------------------------Timeseries (stamp) transformation--------------------------------------------------------------------------------------------

# Transform all timestamps into minutes (where we have to also integrate the month):
Raspi$month.min <- (Raspi[,19] - Raspi[1,19])*31*24*60
Raspi$day.min <- (Raspi[,20]-Raspi[1,20])*24*60
Raspi$hour.min <- (Raspi[,21]-Raspi[1,21])*60
Raspi$all.min <- Raspi$month.min + Raspi$day.min + Raspi$hour.min  + (Raspi$min)

write.csv(Raspi,args$output)

## -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
