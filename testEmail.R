library("mailR")

send.mail(from = "santa-emu@fieldmuseum.org",
          to = "kwebbink@fieldmuseum.org",
          subject = paste("EMu/Filer Validation results for Christmas"),
          body = "Merry Filer Recap \n If any errors, a 2nd 'checkMissing' yule log will be attached",
          encoding = "utf-8",
          smtp = list(host.name = "aspmx.l.google.com", port = 25), 
          # user.name = Sys.getenv("SENDER"),            
          # passwd = Sys.getenv("SENDPW"), ssl = TRUE),
          authenticate = FALSE,
          send = TRUE,
          debug = TRUE)