#### Get tsn ####
# Matt Callahan
# 1/19/23
# this script pulls tsns from ITIS for species in the adfg.species table on AKFIN
# Unlike tables in the AKR schema used for species code translations, 
#adfg.species contains scientific name, which can be linked to the itis database

library(tidyverse)
library(httr)
library(taxize)
library(odbc)
library(getPass)

# Pull scientific names for species of interest
# connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())
# download adfg species codes
adfg <- dbFetch(dbSendQuery(con, paste0("select* 
                                  from adfg.species")))%>%
  rename_with(tolower)

#take scientific name from adfg excluding NAs
splist<-(adfg%>%filter(!is.na(species_scientific)))$species_scientific

# run get_tsn function
# This only pulls from valid species scientific names
adfg_tsn<-get_tsn_(splist)%>%
  bind_rows()

#reduce columns so only tsn will be joined back to adfg data
adfg_tsn<-adfg_tsn%>%
  dplyr::select(tsn, scientificName)

#add tsn to adfg species table
adfg<-adfg%>%
  left_join(adfg_tsn, by=c("species_scientific"="scientificName"))

#save output
saveRDS(adfg, "adfg_tsn.RDS")
write.csv(adfg, "adfg_tsn.csv")

