#######################################################################################
#############################   FINAL MODEL EVALUATION ################################
#######################################################################################
### Final models should be evaluated using test occurrence data (i.e., data that have 
### not been used in the fitting model process). This scipt evaluates final models 
### based on statistical significance (partial ROC) and omission rate (E) This function 
### will return a .csv file with the results of the evaluation
### NicheToolBox Package is used / see: https://rdrr.io/github/luismurao/ntbox/########
#######################################################################################
###################################  Index  ###########################################
### 1 - Installing & Load packages
### 2 - Calculate Partial ROC AUC
### 3 - Calculate Omission Rate
#######################################################################################

#######################################################################################
########################### 1 - Installing & Load packages ############################
#######################################################################################

rm(list = ls(all = TRUE))
# Set a directory
setwd ("C:/Cactaceae")
getwd()

#Instal package
install.packages("remotes")
remotes::install_github("luismurao/ntbox")

#Load Packages
library(raster) # stack(), scale(), crop(), writeRaster() & raster() functions
library(sp) # required for raster packages, coordinates() function
library(ntbox)

#######################################################################################
############################ 2 - Calculate Partial ROC AUC ############################
#######################################################################################

# Load a continuous final model
conti_model <- raster("C:/Cactaceae/Final_Models/S12/continuous_model.tif")###CHANGE####
 
# Read validation (test) data
file <- paste("C:/Cactaceae/S12_test.csv", sep="")################CHANGE################
test <- read.table(file, header=TRUE, sep=',')

# we do not need the first column
test_data <- test[,-1]

# Calculate Partial ROC AUC
### function pROC is used - Osorio-Olvera et al., 2020
partial_roc <- pROC(continuous_mod=conti_model,
                     test_data = test_data,
                     n_iter=1000,E_percent=5,
                     boost_percent=50,
                     parallel=FALSE)
					 
print (partial_roc$pROC_summary)

# Partial ROC AUC are exported as .asc file
write.csv(x = partial_roc$pROC_summary, 
          file = "C:/Cactaceae/Final_Models/S12/partial_roc_auc.csv")######CHANGE#######

#######################################################################################
############################# 3 - Calculate Omission Rate #############################
#######################################################################################

#Calculate Omission Rate				 
### function omission_rate is used - Osorio-Olvera et al., 2020

# Read fitting (train) data
file <- paste("C:/Cactaceae/S12_train.csv", sep="")################CHANGE###############
train <- read.table(file, header=TRUE, sep=',')
					 
 thresholds <- seq(0.0, 0.1,by = 0.05)
 omrs <- omission_rate(model = conti_model,
                       threshold = thresholds,
                       occ_train = train,
                       occ_test = test)

 print(omrs)

# Omission Rate are exported as .asc file
write.csv(x = omrs, file = "C:/Cactaceae/Final_Models/S12/omrs.csv")######CHANGE########

#######################################################################################
################################  END OF CODE  ########################################
#######################################################################################

#References
#Osorio-Olvera, L., Lira-Noriega, A., Soberón, J., Townsend Peterson, A., Falconi, M., 
#Contreras-Díaz, R.G., Martínez-Meyer, E., Barve, V. and Barve, N. (2020), ntbox: an 
#R package with graphical user interface for modeling and evaluating multidimensional 
#ecological niches. Methods Ecol Evol. v. 11, n. 10, p. 1199-1206. 
#doi:10.1111/2041-210X.13452

