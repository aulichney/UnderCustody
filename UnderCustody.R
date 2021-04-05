setwd("/Users/annieulichney/Desktop")
library(rjson)
library(lubridate)
library(rbin)
library(stringr)

#Read in data
data1 <- read.csv("undercustodydata.csv")
geo <- read.csv("undercustodygeo.csv")

#create unique variables to use for merging
data1$fullname <- paste(data1$first.name, data1$last.name, sep = "")
data1$namedob <- paste(data1$fullname, data1$date.of.birth, sep = "")
data1$id <- paste(data1$namedob, data1$original.reception.date, sep = "")
data1$id <- gsub(" ", "", data1$id)

geo$fullname <- paste(geo$firstName, geo$lastName, sep = "")
geo$dob <- gsub("-", "", geo$dob)
geo$namedob <- paste(geo$fullname, geo$dob, sep = "")
geo$id <- paste(geo$namedob, geo$originalReceptionDate, sep = "")
geo$id <- gsub(" ", "", geo$id)

#merge
data <- merge(data1, geo, by = 'id')

#rename columns
names(data)[names(data) == 'sex.x'] <- 'sex'
names(data)[names(data) == 'race.x'] <- 'race'
names(data)[names(data) == 'original.reception.date.x'] <- 'original.reception.date'


#eliminate unneeded cols
keep = c("last.name" , "first.name", "sex" , "date.of.birth", "ethnic.group", "race", "original.reception.date", "maximum.expiration.date",  "code.owning.facility.name", "crimeCounty", "downstateResident", "nycResident")

data <-subset(data, select = keep)


#Extract dates
data$date.of.birth <- ymd(data$date.of.birth)
data$original.reception.date <- ymd(data$original.reception.date)
#data$maximum.expiration.date <- ymd(data$maximum.expiration.date)

#calculate age and time served (in years)
data$age <- as.numeric(Sys.Date() - data$date.of.birth) / 365.25
data$time.served <- as.numeric(Sys.Date() - data$original.reception.date) / 365.25
#data$time.served <- as.numeric(data$maximum.expiration.date - data$original.reception.date) / 365.25

#Merge Race & Ethnicity, use full string for plot labels 
data$raceEthnicity[data$race == 'W' & data$ethnic.group == 'N'] <- 'Non-Hispanic White'
data$raceEthnicity[data$race == 'B' & data$ethnic.group == "N"] <- 'Non-Hispanic Black'
data$raceEthnicity[data$ethnic.group == "H"] <- 'Hispanic'
data$raceEthnicity[data$ethnic.group == "U"] <- 'Other'
data$raceEthnicity[data$ethnic.group == " "] <- 'Other'
data$raceEthnicity[data$race == "A"] <- 'Other'
data$raceEthnicity[data$race == " "] <- 'Other'
data$raceEthnicity[data$race == "I"] <- 'Other'
data$raceEthnicity[data$race == "O"] <- 'Other'

data$sex[data$sex == 'M'] <- 'Male'
data$sex[data$sex == 'F'] <- 'Female'

#fill in unknowns given that elmira is men's prison and bedford is women's
data$sex[data$sex == ' ' & data$code.owning.facility.name == 'ELMIRA RECEP'] <- 'Male'
data$sex[data$sex == ' ' & data$code.owning.facility.name == 'BED HIL RECP'] <- 'Female'
#drop facility variable

#remove facility name
data <- data[ , !(names(data) %in% c('code.owning.facility.name'))]

#bin age data
a = c(18,24,34,50,64,92)
data$age.binned <- cut(data$age, a, labels = c("18-24", "25-34","35-49","50-64","65+"))

#bin time served data
breaks = c(0,5,10,15,20,25,30,35,40,45,50,55,60)
data$time.served.binned <- cut(data$time.served, breaks, labels = c("0-5","6-10","11-15","16-20","21-25","26-30","31-35","36-40","41-45","46-50","51-55","56-60"))

#round age and time served to whole number
data$age <- round(data$age,0)
#round age and time served to whole number
data$time.served <- round(data$time.served,0)

#titlecase vars
data$crimeCounty <- str_to_title(data$crimeCounty)
data$downstateResident <- str_to_title(data$downstateResident)

#rename columns to eliminate periods
names(data)[names(data) == 'last.name'] <- 'lastName'
names(data)[names(data) == 'first.name'] <- 'firstName'
names(data)[names(data) == 'date.of.birth'] <- 'dob'
names(data)[names(data) == 'ethnic.group'] <- 'ethnicGroup'
names(data)[names(data) == 'original.receptionDate'] <- 'originalReceptionDate'
names(data)[names(data) == 'maximum.expiration.date'] <- 'maximumExpirationDate'
names(data)[names(data) == 'time.served'] <- 'timeServed'
names(data)[names(data) == 'age.binned'] <- 'ageBinned'
names(data)[names(data) == 'time.served.binned'] <- 'timeServedBinned'


#Write CSV
#write.csv(data,"/Users/annieulichney/Desktop/undercustodygeo.csv", row.names = FALSE)

