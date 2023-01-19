library(tidyverse)
library(httr)
library(taxize)

#list species in a vector
#scientific
splist<-c("Anoplopoma fimbria", "Gadus macrocephalus")
#common
splist<-c("sablefish", "pacific cod")

#get tsn with get_tsn function
get_tsn(splist, searchtype = "scientific")

#bind rows into dataframe
splist_tsn<-get_tsn_(splist)%>%
  bind_rows()

#download race codes
race<-dbFetch(dbSendQuery(con, paste0("select* 
                                  from afsc.race_racespeciescodes")))%>%
  rename_with(tolower)

#take scientific name from RACE
splist<-race$species_name

#test
#This only pulls from valid species scientific names
splist_tsn<-get_tsn_(splist)%>%
  bind_rows()

#save output
saveRDS(splist_tsn, "race_tsn.RDS")
#we could right join this back...
