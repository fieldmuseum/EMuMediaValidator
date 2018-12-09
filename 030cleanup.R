# cleanup files 

# if (!file.exists(paste0("auditErrorlog_", filerDate, ".txt"))) {
  if (NROW(compareLogs)>0) {
    if (!dir.exists(paste0("checkLogs_", filerDate))) {
      dir.create(paste0("checkLogs_", filerDate))
    }
    file.copy("eaudit/", paste0("checkLogs_", filerDate), recursive = T)
    file.copy("filer02/", paste0("checkLogs_", filerDate), recursive = T)
  } 
# }

unlink(c("eaudit","filer02"), recursive = T)