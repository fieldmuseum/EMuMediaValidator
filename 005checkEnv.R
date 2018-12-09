# Setup .Renviron 
#   - follow https://csgillespie.github.io/efficientR/3-3-r-startup.html#r-startup


proj_renviron = path.expand(file.path(getwd(), ".Renviron"))
if(!file.exists(proj_renviron)) { # check to see if the file already exists
  
  file.create(proj_renviron)
  writeLines(c("## Server variables",
               "",
               "SERVER_IP = 'server-ip-address'",
               "SERVER_ID = 'id'",
               "SERVER_PW = 'pw'",
               "FILER_DIR = 'path/to/filer/audit/directory/'",
               "EMU_DIR = 'path/to/emu/audit/directory/'",
               "OUT_DIR = 'output/'",
               "FILER_LOC = '/filerloc/'",
               "EMU_LOC = '/emuloc/'",
               "SENDER = 'youremail@address.com'",
               "RECIP1 = 'recip1@email.com'",
               "RECIP2 = 'recip2@email.com",
               "SENDPW = 'yourmailpw'"
               ),
             proj_renviron)

  file.edit(proj_renviron) # open with another text editor if this fails
  
  }


# load env variables
serverID <- Sys.getenv("SERVER_ID")
serverIP <- Sys.getenv("SERVER_IP")
serverPW <- Sys.getenv("SERVER_PW")
