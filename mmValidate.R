# Run this script to retrieve & check multimedia audit logs
# 2018-10-19
# FMNH-IT

# Use 'Rscript mmValidate.R' to run this from a bash shell.

# # getAudits <- readline("Do you need to get logs from server? Y/N")

print(paste("Current working dir: ", getwd()))

source("005checkEnv.R", verbose = F)

source("008copyLogs.R", verbose = T)

source("010openLogs.R", verbose = T)

if (!file.exists(paste0("auditErrorlog_", filerDate))) {
  source("020compare.R", verbose = T)
}

source("030cleanup.R", verbose = T)

print(paste("finished at", Sys.time()))