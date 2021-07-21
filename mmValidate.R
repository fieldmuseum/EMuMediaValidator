# Run this script to retrieve & check multimedia audit logs
# 2018-Dec-09
# FMNH-IT

# Use 'Rscript mmValidate.R' to run this from a bash shell.


library("ssh")
library("tidyverse")
library("mailR")
# library("digest")
library("stringr")


print(paste("Current working dir: ", getwd()))

source("005checkEnv.R", verbose = F)

# source("008copyLogs.R", verbose = T) # requires ssh

source("010openLogs.R", verbose = T)

# source("013checkMD5.R", verbose = T) # requires stringr, tidyr; optional: digest

source("020compare.R", verbose = T) # requires tidyverse

source("025notify.R", verbose = T)  # requires mailR

source("030cleanup.R", verbose = T)

print(paste("finished at", Sys.time()))