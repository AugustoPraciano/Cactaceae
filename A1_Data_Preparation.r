#######################################################################################
###  Written by Sampaio, A. C. P. (1) & Cavalcante, A. de M. B. (2), 2023
###  1, 2 Instituto Nacional de Pesquisas Espaciais (INPE), Eusébio, Brazil
###  Published in: 
#######################################################################################
##############################  DATA PREPARATION  #####################################
#######################################################################################
### This script is used to prepare and select of species' presence data and 
### environmental variables to be used in the model fitting step.
### Applied to R software version 4.3.1
#######################################################################################
###################################  Index  ###########################################
### 1 - Load packages
### 2 - Presence records preparation (check for duplicates)
### 3 - Analysis of multicollinearity & selection of predictors variables
#######################################################################################

#######################################################################################
################################## 1 - Load packages ##################################
#######################################################################################

# If you have your own data and they are organized as in the first part of Figure 1, 
# change your directory and follow the instructions below.

rm(list = ls(all = TRUE))
# Set a directory
setwd ("C:/Cactaceae")
getwd()

library(raster) # stack(), scale(), crop(), crs(), writeRaster() & raster() functions
library(sp) # required for raster packages, coordinates() function
library(dismo) # for evaluate() gridsample() & maxent() functions
library(rJava) # required for dismo
library(Hmisc) # rcorr() function

#######################################################################################
################ 2 - Presence records preparation (check for duplicates)###############
#######################################################################################

# this is the species' sample file we will use:
file <- paste("C:/Cactaceae/cactaceae.csv", sep="")
# read it
cactaceae <- read.table(file, header=TRUE, sep=",")
# inspect the values of the file (first rows)
head(cactaceae)

# get only specific specie / Specify the species name in the " " field
presence <- dplyr::filter(cactaceae, Species=="Pilosocereus_pernambucoensis")######CHANGE#########
# we only need coordinates columns:
presence <- presence[,c("Species","Longitude","Latitude")]
head(presence)

# check for duplicate records
dups2 <- duplicated(presence[, c('Longitude', 'Latitude')])
sum(dups2) # number of duplicates
# keep the records that are not duplicated
pres <- presence[!dups2, ]

# we only need columns 2 and 3:
pres <- pres[,1:3]
head(pres)

# a set of 75% of randon select presence records are used to fit the model
samp <- sample(nrow(pres), round(0.75 * nrow(pres)))
train <- pres[samp,]
# the others 25% is only used to evaluate the final model
test <- pres[-samp,]

# save the train and test and joint records.csv
write.csv(x = train, row.names = FALSE, file = "C:/Cactaceae/S12_train.csv")###CHANGE###
write.csv(x = test, row.names = FALSE, file = "C:/Cactaceae/S12_test.csv")####CHANGE####
write.csv(x = pres, row.names = FALSE, file = "C:/Cactaceae/S12_joint.csv")####CHANGE###

#######################################################################################
######## 3 - Analysis of multicollinearity & selection of predictors variables ########
#######################################################################################

# load all environmental variables (predictors)

# finds all the files with extension "asc" in the directory
files <- list.files(path=paste('C:/Cactaceae/Layers/Set1', sep=''), pattern='asc', 
full.names=TRUE)
filesStack <- stack(files) # create a raster stack
projection(filesStack) <- CRS('+proj=longlat +datum=WGS84') # Project stack
names(filesStack) # get the predictor names
# plot a single layer in a RasterStack, and plot some additional data on top of it
plot(filesStack, 1) # first layer of the RasterStack

filesVector <- na.omit(values(filesStack)) # As vector (NA's are omitted)
filesDf <- data.frame(filesVector) # put in a dataframe
# convert to matrix, required by fucntion rcorr()
filesMatrix <- as.matrix(filesDf)
colnames(filesMatrix)

# calculate the Spearman rank correlation between all predictors variables
setwd ("C:/Cactaceae/Layers/Set1")
predRcorr <- rcorr(filesMatrix, type = "spearman")
# export the Spearman r values and significance levels
write.table(predRcorr$r,
         file = "predSpearmanR.txt",
         sep = ",",
         quote = FALSE,
         append = FALSE,
         na = "NA",
         qmethod = "escape")
write.table(predRcorr$P,
         file = "predSpearmanSignificance.txt",
         sep = ",",
         quote = FALSE,
         append = FALSE,
         na = "NA",
         qmethod = "escape")
		 
# outside R, keep only non correlated variables (Spearman rank > 0.7)

#######################################################################################
################################  END OF CODE  ########################################
#######################################################################################