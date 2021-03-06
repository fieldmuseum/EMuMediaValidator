# Import the latest logs to R
#
# Import log of EMu records modified on previous day ####
# # background & alternatives here:
# # https://stackoverflow.com/questions/33446888/r-convert-xml-data-to-data-frame

## NOTE:
## pathEMu & pathFiler are defined in 050checkRenv.R and .Renviron

# get date & local enviro variables
origdir <- getwd()
locEMu <- Sys.getenv("EMU_LOC")
locFiler <- Sys.getenv("FILER_LOC")

filerDate <- gsub("-","",(Sys.Date() - 1))

## Get most recent EMu audit log
##  NOTE:
##   EMu audit logs are generated by a periodic export
##    - Tues-Fri EMu audit logs represent the previous day's activity
##    - Mon EMu audit log represents Fri+Sat+Sun activity <-- TESTING THIS

# timeEMu <- file.info(list.files(paste(pathEMu), full.names = T))
timeEMu <- file.info(list.files(locEMu, full.names = T))

# dfEMu <- list.dirs(paste(pathEMu), full.names = T)
dfEMu <- list.dirs(locEMu, full.names = T)


if (NROW(list.dirs(locEMu)) < 2) {
  
  print(paste("no EMu audit log for", filerDate))
  write.table(print(paste("No EMu log for", filerDate)), 
              file = paste0("EMuauditErrorlog_",filerDate,".txt"))
  
} else {
  emu1 <- read.csv(paste0(dfEMu[NROW(dfEMu)], "/",
                          list.files(dfEMu[NROW(dfEMu)], pattern = "eaudit")),
                   # rownames(dfEMu)[which.max(dfEMu$ctime)],
                   stringsAsFactors = F)

  emu2 <- read.csv(paste0(dfEMu[NROW(dfEMu)], "/",
                          list.files(dfEMu[NROW(dfEMu)], pattern = "Group1")),
                   # rownames(dfEMu)[which.max(dfEMu$ctime)],
                   stringsAsFactors = F)

}

# Get most recent Filer audit log with corresponding EMu log
# dfFiler <- list.dirs(paste0(origdir, locFiler), full.names = T)
dfFiler <- list.dirs(locFiler, full.names = T)

# if (!dir.exists(paste0(origdir, locFiler, filerDate))) {
if (!dir.exists(paste0(locFiler, filerDate))) {
  
  print(paste("no filer audit log for", filerDate))
  # write.table(print(paste("No Filer log for", filerDate)), 
  #             file = paste0("auditErrorlog_",filerDate,".txt"))
  filerBU <- data.frame("timestamp.UTC." = character(),        
                        "category" =  character(),
                        "event.type" =  character(),
                        "path.from" =  character(),
                        "new.path.to" = logical(),
                        "user" = integer(),
                        "group" = integer(),
                        "sid" = integer(),
                        "share.export.name" = logical(),
                        "volume.type" =  character(),
                        "client.IP" = logical(),
                        "snapshot.timestamp.UTC." = logical(),
                        "shared.link" = logical(),
                        stringsAsFactors = F)
  
} else {

    filerBU <- read.csv(paste0(dfFiler[NROW(dfFiler)], "/",
                             list.files(dfFiler[NROW(dfFiler)], pattern = "audit")),
                      stringsAsFactors = F)
}


# On Mondays, get Friday logs, too.
# (May need to fix this -- On Mon, need Fri filer log; on Tues, need Sat & Sun Filer logs)
if (!is.null(timeEMu$ctime)) {
  if (format(max(timeEMu$ctime), "%a") == "Mon") {
    for (i in 2:3) {
      filerDateMon <- gsub("-","",(Sys.Date() - i))
      if (dir.exists(locFiler, filerDateMon)==FALSE) {
        
        print(paste("no filer audit log for", (filerDateMon)))
        
        filerTMP <- data.frame("timestamp.UTC." = character(),        
                               "category" =  character(),
                               "event.type" =  character(),
                               "path.from" =  character(),
                               "new.path.to" = logical(),
                               "user" = integer(),
                               "group" = integer(),
                               "sid" = integer(),
                               "share.export.name" = logical(),
                               "volume.type" =  character(),
                               "client.IP" = logical(),
                               "snapshot.timestamp.UTC." = logical(),
                               "shared.link" = logical(),
                               stringsAsFactors = F)
        
      } else {
  
        locFilerMon <- paste0(locFiler, filerDateMon, sep = "/")
        filerTMP <- read.csv(paste0(locFilerMon, "/",
                                    list.files(locFilerMon, pattern = "audit")),
                             stringsAsFactors = F)
      }
  
      filerBU <- rbind(filerBU, filerTMP)
      
    }
  }
}
