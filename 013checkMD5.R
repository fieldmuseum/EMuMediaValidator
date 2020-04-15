# library("digest")
library("stringr")

mediaDir <- Sys.getenv("MEDIA_DIR")
mediaSubdir <- Sys.getenv("MEDIA_SUBDIR")


# add MD5 hashes to EMu audit log 

# prep emu md5 + filenames ####
emu2md5 <- unique(emu2[grepl("^ChaMd5Sum|^SupMD5Checksum_tab|^Multimedia|^Supplementary_tab", 
                             emu2$AudNewValue) > 0,
                       c("eaudit_key", "AudNewValue")])

# Can't trust original AudColumnName & AudNewValue match in each row
emu2md5 <- separate(emu2md5, AudNewValue, 
                    into = c("AudColumnName", "AudNewValue"),
                    sep = ": ")

# # to test, uncomment next 5 lines
# emu2md5 <- rbind(emu2md5,
#                  c("38",
#                    "Supplementary_tab",
#                    "Supplementary_tab: <table><tuple><atom>3/8/Supp/file1.ext</atom></tuple><tuple><atom>3/8/Supp/file2.dng</atom></tuple></table>"),
#                  c("38",
#                    "SupMD5Checksum_tab",
#                    "SupMD5Checksum_tab: <table><tuple><atom>1cc9ff23b1352cb69de255963c6dbd38</atom></tuple><tuple><atom>1f44d7cbc9d88adc81dcfb392c1beebf</atom></tuple></table>"))
# emu2md5$eaudit_key <- as.integer(emu2md5$eaudit_key)

# clean emu md5 audit data
emu2md5$AudNewValue <- gsub("</atom></tuple><tuple><atom>", "|", emu2md5$AudNewValue)
emu2md5$AudNewValue <- gsub("<table>|<tuple>|<atom>|</atom>|</tuple>|</table>", "", emu2md5$AudNewValue)


# Count # supp here to setup keys
emu2md5$supp <- str_count(emu2md5$AudNewValue, "\\|") + 1
emu2md5$supp[grepl("^Sup", emu2md5$AudColumnName)<1] <- 0


# split/gather Supp media files
emu2md5$AudNewValue <- gsub("^ChaMd5Sum: |^SupMD5Checksum_tab: |^Multimedia: |^Supplementary_tab: ", "", 
                            emu2md5$AudNewValue)

emu2md5 <- separate(emu2md5, AudNewValue, 
                    into = paste0("EMuValue_", 1:(max(emu2md5$supp))),
                    sep = "\\|")


# Form keys for corresponding filename-MD5 pairs
emu2md5$eaudit_key <- paste0(emu2md5$eaudit_key, "_", emu2md5$supp)

emu2md5$AudColumnName <- gsub("SupMD5Checksum_tab|ChaMd5Sum", "EMu_MD5", emu2md5$AudColumnName)

emu2md5$AudColumnName <- gsub("Supplementary_tab|Multimedia", "EMu_Filename", emu2md5$AudColumnName)


# FIX HERE -- in gather, number of col's changes w/ max # supp files -- make dynamic
emu2md5 <- gather(emu2md5, 3:(2 + max(emu2md5$supp)),
                  key = "Count",
                  value = "EMuValue",
                  na.rm = T)

emu2md5 <- unite(emu2md5, "irn_Count", c(eaudit_key, Count))

emu2md5 <- spread(emu2md5[,c("irn_Count", "AudColumnName", "EMuValue")],
                  key = AudColumnName,
                  value = EMuValue,
                  fill = "")

emu2md5 <- emu2md5[nchar(emu2md5$EMu_MD5) > 0,]

emu2md5$path.from <- paste0(mediaDir, mediaSubdir, emu2md5$EMu_Filename)

# prep filer MD5s ####
filerMD5 <- unique(filerBU[grepl("Create File", filerBU$event.type)==T,
                           c("event.type", "path.from")])


# # if files are local, could add MD5 hashes to Filer audit log with this:
# filerBU$md5 <- ""
# 
# for (i in 1:NROW(filerBU)) {
#   
#   filerBU$md5[i] <- digest(file = paste0(mediaDir, filerBU$path.from[i]))
#   
# }


if (NROW(emu2md5) > 0) {
  # write.csv(filerMD5$path.from, 
  #           file = paste0(Sys.getenv("OUT_DIR"),"filelist.txt"),
  #           row.names = F)  

  # to write MD5 output to a file:
  # for f in `cat pathlist.txt`; do md5sum.exe ${f} &>> md5list.txt; done;

  # out <- ssh_exec_internal(session, 
  #                          command = paste0("for f in `cat ",
  #                                           Sys.getenv("OUT_DIR"),
  #                                           "filelist.txt",
  #                                           "`; do md5sum.exe ${f} &>> md5list.txt; done;"))
  # out2 <- rawToChar(out$stdout)
  
  # Sys.sleep(2)
  
  # ssh_disconnect(session)
  
  # Simpler to pull md5s for EMu-paths, not for filer-log paths?
  # # outAll <- data.frame("MD5path" = rep("", NROW(filerMD5)),
  # #                      "errors" = rep("", NROW(filerMD5)),
  # #                      stringsAsFactors = F)
  
  outAll <- data.frame("MD5path" = rep("", NROW(emu2md5)),
                       "errors" = rep("", NROW(emu2md5)),
                       stringsAsFactors = F)
  
  session <- ssh_connect(host = paste0(serverID, "@", serverIP),
                         verbose = 2)
  
  for (i in 1:NROW(emu2md5)) {

    
    # check that file exists first

    path <- ssh_exec_internal(session, 
                              command = paste0("(ls '",
                                               emu2md5$path.from[i],
                                               "' && echo yes) || echo no"
                                               ))

    if (grepl("yes\n", rawToChar(path$stdout)) == TRUE) {
    
    # generate checksum    
    out <- ssh_exec_internal(session, 
                             command = paste0("md5sum '",
                                              emu2md5$path.from[i],
                                              "'"))

    outAll$MD5path[i] <- rawToChar(out$stdout)

    outAll$errors[i] <- rawToChar(out$stderr)
    
    Sys.sleep(1)
    
    } else {
      
      outAll$errors[i] <- rawToChar(path$stderr)
      
      Sys.sleep(1)
      
    }
    
  }
  
  ssh_disconnect(session)  
  
}


# Split MD5 output 
outAll$Filer_MD5 <- substr(outAll$MD5path, 1, 32)
outAll$path.from <- substr(outAll$MD5path, 35, nchar(outAll$MD5path))
outAll$path.from <- gsub("\n", "", outAll$path.from)
# outAllb <- outAll[grepl("thumb.jpg$", outAll$path.from) < 1,]

# Merge / Compare MD5s from EMu & filer
md5check <- merge(emu2md5[,c("path.from", "EMu_MD5")],
                  outAll[,c("path.from", "Filer_MD5")],
                  by = "path.from",
                  all = T)

md5check[is.na(md5check)] <- ""

# flag non-matching MD5s
# NEED TO pre-set dataframe w/ each column's data type?

md5nomatch <- md5check[!(md5check$EMu_MD5 == md5check$Filer_MD5) 
                       & is.na(md5check$EMu_MD5)==F
                       & grepl("\\.thumb.jpg$", md5check$path.from) < 1,]

if (NROW(md5nomatch) > 0) {
  
  write.csv(md5nomatch,
            paste0(Sys.getenv("OUT_DIR"),"md5nomatch",
                   # format(max(timeEMu$ctime), "%Y%m%d_%a"),
                   ".csv"),
            row.names = F)
  
}
