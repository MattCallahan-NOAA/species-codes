library(odbc)
library(tidyverse)
library(getPass)

#connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())

####get_spec_codes####
#function to pull species codes from akr.agency_specie
#based on species input
get_spec_codes<- function(species, species2) {
  if(missing(species2)) {
  dbFetch(dbSendQuery(con,
                           paste0("select* 
                                  from akr.agency_specie
                                  where lower(name) like '%",species,"%'
                                  and agency in ('OBS', 'AKR', 'RACE', 'ADFG')")))%>%
    rename_with(tolower)
  } else {
  dbFetch(dbSendQuery(con,
                      paste0("select* 
                                  from akr.agency_specie
                                  where lower(name) like '%",species,"%'
                                  and lower(name) like '%",species2,"%'
                                  and agency in ('OBS', 'AKR', 'RACE', 'ADFG')")))%>%
    rename_with(tolower)
  }
}

#test for sablefish, pcod, and dusky rockfish
sablefish_spec_codes<-get_spec_codes(species="sablefish")
pcod_spec_codes<-get_spec_codes(species="cod", species2="pacific")
drf<-get_spec_codes(species="rockfish", species2="dusky")

