#######################################################################################
###############################   CANDIDATE MODELS ####################################
#######################################################################################
# This script is used to creates and executes a batch file for generating Maxent 
# candidate models that will be written in subdirectories in the main directory. 
# Calibration models will be created with multiple combinations of regularization 
# multipliers and feature classes. For each combination, this creates one Maxent model 
# with the complete set of occurrences and another with training occurrences only. 
#######################################################################################
###################################  Index  ###########################################
### 1 - Installing & loading packages
### 2 - Creation of candidate models
### 3 - Evaluation and selection of best models
#######################################################################################

#######################################################################################
########################### 1 - Installing & loading packages #########################
#######################################################################################
#Installing the package
# The kuenm R package is in a GitHub repository and can be installed and/or loaded 
# using the following code (make sure to have Internet connection). To warranty the 
# package functionality, a crucial requirement is to have the maxent.jar application 
# in any user-defined directory (we encourage you to maintain it in a fixed directory). 
# This software is available in the Maxent repository. Another important requirement 
# for using Maxent and therefore the kuenm package is to have the Java Development Kit 
# installed. The Java Development Kit is available in this repository. Finally, for 
# Windows users, Rtools needs to be installed in the computer; it is important that 
# this software is added to the PATH. For instructions on how to download and install 
# it see https://github.com/marlonecobos/kuenm. 

if(!require(devtools)){
    install.packages("devtools")
}

if(!require(kuenm)){
    devtools::install_github("marlonecobos/kuenm")
}

library(kuenm)

# Change "YOUR/DIRECTORY" by your actual directory
setwd("C:/Cactaceae") # set the working directory

dir() # check what is in your working directory

#######################################################################################
########################### 2 - Creation of candidate models ##########################
#######################################################################################
# kuenm_cal function is used (Cobos et al.,2019)
# Maxent will run in command-line interface (do not close the application)
# Variables with information to be used as arguments

occ_joint <- "S12_joint.csv"###########################CHANGE###########################
occ_tra <- "S12_train.csv"#############################CHANGE###########################
M_var_dir <- "Layers"
batch_cal <- "Candidate_models"
out_dir <- "Candidate_Models"
reg_mult <- c(seq(0.5, 1, 0.1), 2, 3)
f_clas <- c("lq", "lp", "lt", "qp", "qt", "qh", "lqp", "lqt", "lqh", "lqpt", "lqph", "lqth", "lqpth")
args <- NULL # e.g., "maximumbackground=20000" for increasing the number of pixels in 
             # the bacground or note that some arguments are fixed in the function and 
			 # should not be changed
maxent_path <- "C:/Cactaceae"
wait <- FALSE
run <- TRUE

kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, batch = batch_cal,
          out.dir = out_dir, reg.mult = reg_mult, f.clas = f_clas, args = args,
          maxent.path = maxent_path, wait = wait, run = run)
		  
#######################################################################################
#################### 3 - Evaluation and selection of best models ######################
#######################################################################################

# kuenm_ceval function is used (Cobos et al.,2019)
occ_test <- "S12_test.csv"##########################CHANGE##############################
out_eval <- "Calibration_results"
threshold <- 5
rand_percent <- 50
iterations <- 100
kept <- TRUE
selection <- "AICc"
paral_proc <- FALSE # make this true to perform pROC calculations in parallel, 
                    # recommended only if a powerfull computer is used 
					# (see function's help)
# Note, some of the variables used here as arguments were already created for previous 
# function
cal_eval <- kuenm_ceval(path = out_dir, occ.joint = occ_joint, occ.tra = occ_tra, 
                        occ.test = occ_test, batch = batch_cal, out.eval = out_eval, 
						threshold = threshold, rand.percent = rand_percent, 
						iterations = iterations, kept = kept, selection = selection, 
						parallel.proc = paral_proc)
						
### We will calibrate the models in the next step with the optimal parameters 
### indicated in the selected_models name file present in the Calibration_results folder

#######################################################################################
################################  END OF CODE  ########################################
#######################################################################################
#References
#Cobos, M. E., Peterson, A. T., Barve, N., & Osorio-Olvera, L. (2019). kuenm: an R 
#package for detailed development of ecological niche models using Maxent. PeerJ, v. 7, 
#p. e6281. Available at: <https://peerj.com/articles/6281/>  Access in: jul 2023.