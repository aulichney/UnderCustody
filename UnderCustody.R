setwd("/Users/annieulichney/Desktop")
library(rjson)
library(lubridate)
library(rbin)

#Read in data
data <- read.csv("undercustodydata.csv")


#eliminate unneeded cols
keep = c("last.name" , "first.name", "sex" , "date.of.birth", "ethnic.group", "race", "original.reception.date", "maximum.expiration.date",  "code.owning.facility.name")
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

#round age and time served to whole number
data$age <- round(data$age,0)
#round age and time served to whole number
data$time.served <- round(data$time.served,0)

#bin age data
a = c(18,24,34,50,64,91)
data$age.binned <- cut(data$age, a, labels = c("18-24", "25-34","35-49","50-64","65+"))

#bin time served data
breaks = c(0,5,10,15,20,25,30,35,40,45,50,55,60)
data$time.served.binned <- cut(data$time.served, breaks, labels = c("0-5","6-10","11-15","16-20","21-25","26-30","31-35","36-40","41-45","46-50","51-55","56-60"))

#rename columns to eliminate periods
colnames(data)[1] <- 'lastName'
colnames(data)[2] <- 'firstName'
colnames(data)[4] <- 'dob'
colnames(data)[5] <- 'ethnicGroup'
colnames(data)[7] <- 'originalReceptionDate'
colnames(data)[8] <- 'maximumExpirationDate'
colnames(data)[10] <- 'timeServed'
colnames(data)[12] <- 'timeServedBinned'
colnames(data)[13] <- 'ageBinned'


#Write CSV
write.csv(data,"/Users/annieulichney/Desktop/undercustodybinned.csv", row.names = FALSE)

# #Write JSON
# write(toJSON(data), 'undercustodymod.json')


# dfFreq <- function(data,myName=""){
#   ctTable <- table(data)
#   sumTable <- sum(ctTable)
#   oCtTable <- order(ctTable,decreasing = T)
#   dfTableCt <- as.data.frame(ctTable[oCtTable])
#   TableDec <-prop.table(ctTable[oCtTable])
#   
#   TablePct  <- round(100*TableDec,1)
#   sumTablePct <- sum(TablePct)
#   dfTableRaw <- cbind(TablePct,dfTableCt)
#   colnames(dfTableRaw) <- c(myName,"pct",paste0(myName,"1"),"count")
#   myCat <- levels(dfTableRaw[,1])[dfTableRaw[,1]]
#   dfTable <- data.frame(pct=c(TablePct,sumTablePct),count=c(dfTableCt[,2],sumTable),row.names=c(names(TableDec),"Sum"))
#   return(dfTable)
# }
# 
# #frequency tables as df to later write as csv
# sexfreq <- data.frame(dfFreq(data$sex))
# agefreq <- data.frame(dfFreq(data$age))
# racefreq <- data.frame(dfFreq(data$race))
# ethnicGroupfreq <- data.frame(dfFreq(data$ethnicGroup))
# 


#Write csv
#write.csv(sexfreq,"/Users/annieulichney/Desktop/sex.csv", row.names = TRUE)

