# Compare daily multimedia audit logs between EMu & filer01
#
# 2018-10-19
#

library("tidyverse")
# library("xml2")

# # import EMu log ####
# emu1 <- read.csv(dataEMu1, stringsAsFactors = F)
# emu2 <- read.csv(dataEMu2, stringsAsFactors = F)


# select only edits of Main OR Supplementary multimedia
emu2 <- unique(emu2[grepl("^Multimedia|^Supplementary_tab", emu2$AudNewValue), -1])
emu2 <- spread(emu2, key = "AudColumnName", value = "AudNewValue", fill = "")

# log includes multiple updates to the same irn
emu <- merge(emu1, emu2,
             by = "eaudit_key",
             all.x = T)


# # import Filer log ####
# filerBU <- read.csv(dataFiler, stringsAsFactors = F)

# split "Delete"/"Create" edits
filerDeleted <- filerBU[filerBU$category=="Delete",]

filer <- filerBU[grepl("File", filerBU$event.type)==T,
                   c("event.type", "path.from")]

filer <- unique(filer[order(filer$path.from, filer$event.type),])


# # don't strip supplementary directories & files
filerMain <- filer # [!grepl("/supplementary", filer$path.from),]


# convert directory paths to irn's
filerMain$key <- gsub("/Multimedia/emufmnh/multimedia/", "", filerMain$path.from)

filerMain <- separate(filerMain, key, 
                      c("irn1", "irn2", "MulIdentifier"),
                      sep = "/",
                      extra = "merge")

filerMain <- filerMain[grepl("\\d+", filerMain$irn2)==T,]

filerMain <- unite(filerMain, irn, c(irn1, irn2), sep = "")

# spread
filerMain$seq <- sequence(rle(filerMain$irn)$length)
filerMain$seq <- paste0(filerMain$event.type, filerMain$seq)

filerMain2 <- unique(filerMain[,c("irn","MulIdentifier","seq")])

filerMain2 <- spread(filerMain2,
                      key = seq,
                      value = MulIdentifier)


# Compare filer & EMu logs
compareLogs <- emu[!emu$AudKey %in% filerMain2$irn,]

# This shouldn't be a thing:
compareLogs2 <- filerMain2[!filerMain2$irn %in% emu$AudKey,]

# Counts of created & deleted files:
countCreated <- paste("Filer-Created-",
                      NROW(unique(filerMain$irn[grepl("Create", filerMain$seq)==T])))
countDeleted <- paste("Filer-Deleted-",
                      NROW(unique(filerMain$irn[grepl("Delete", filerMain$seq)==T])))
countMissing <- paste("Filer-Missing-",
                      NROW(compareLogs))


FilerRecap <- data.frame("FilesOnFiler" = rbind(countMissing, countCreated, countDeleted),
                         "EMuLogDate" = format(max(timeEMu$ctime), "%Y-%m-%d %a"),
                         stringsAsFactors = F)

FilerRecap <- separate(FilerRecap, 1, 
                       c("Where", "Action", "Count"), 
                       sep = "-")

# write missing files to output
if(!dir.exists(Sys.getenv("OUT_DIR"))) {
  dir.create(Sys.getenv("OUT_DIR"))
}

# Uncomment format() line to datestamp the FilerRecap.csv
write.csv(FilerRecap, 
          file = paste0(Sys.getenv("OUT_DIR"),"FilerRecap",
                        # format(max(timeEMu$ctime), "%Y%m%d_%a"),
                        ".csv"),
          row.names = F)  

if (NROW(compareLogs)>0) {
    write.csv(compareLogs, 
              file = paste0(Sys.getenv("OUT_DIR"),"checkMissingFiles_",
                            format(max(timeEMu$ctime), "%Y%m%d_%a"),
                            ".csv"),
              row.names = F)  
}


