library(odbc)
library(tidyverse)
library(getPass)

#connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())

#download species codes
specie<-dbFetch(dbSendQuery(con,
                    paste0("select* 
                                  from akr.agency_specie
                                  where agency in ('OBS', 'AKR', 'RACE', 'ADFG')")))%>%
  rename_with(tolower)


####get_group_codes####
#pull species group codes from akr.species_group
groups<-dbFetch(dbSendQuery(con,
                            paste0("select* 
                                  from akr.species_group")))%>%
  rename_with(tolower)

#load iphc from 
iphc<-read.csv("species_code_conv_table.csv")%>%
  rename_with(tolower)

#race codes with tsn
race<-dbFetch(dbSendQuery(con, paste0("select* 
                                  from afsc.race_racespeciescodes")))%>%
  rename_with(tolower)

            


#Create table for sablefish
#start with RACE since they have tsn.... no they don't wtf, I guess that's BASIS
sable_race<-race%>%
  filter(grepl("sablefish", tolower(common_name)))


sabletable<-sable_race%>%
  mutate(name=common_name,
         scientific_name=species_name,
         race_code=species_code,
         tsn=167123)%>%
  dplyr::select(tsn, name, scientific_name, race_code)


#species codes
sable_specie<-specie%>%
  filter(grepl("sablefish", tolower(name)))%>%
  #remove legacy species 
  filter(code!="SABL")%>%
  dplyr::select(code, agency)%>%
  pivot_wider(values_from="code", 
              names_from="agency")%>%
  rename_with(tolower)%>%
  #make race_code numeric
  mutate(race=as.numeric(race))
#add "code" suffix  
colnames(sable_specie)<-paste0(colnames(sable_specie),"_code")

             

sabletable<-sabletable%>%
  left_join(sable_specie, by="race_code")

#group codes
sable_group<-groups%>%
  filter(grepl("sablefish", tolower(name)))%>%
  mutate(group_code=code)%>%
  dplyr::select(group_code)
 
sabletable<-sabletable%>%
  bind_cols(sable_group)

#IPHC codes
sable_iphc<-iphc%>%
  filter(grepl("sablefish", tolower(species)))%>%
  dplyr::select(iphc_code)

sabletable<-sabletable%>%
  bind_cols(sable_iphc)
