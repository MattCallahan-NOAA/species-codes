#Configure first draft of AKFIN species table
#Matt Callahan
#1/19/23

#pseudocode
# 1) download codes adfg
# 2) Add tsn from itis & scientific name  from adfg_tsn.RDS (generated from taxize.R script)
# 3) manually go through list and designate which are groundfish
# I might just skip this step and see if I can get away with it.
# pros-more species in the table, less work.
# cons-sorting through the table for error correction later may be harder
# 4) add akr, RACE, OBS, codes from akr.species_translation
# 5) add IPHC from IPHC spreadsheet, join by RACE code
# 6) add species group codes from species_group_content
# check to make sure that I didn't miss any 
# (No species codes in species_group_content that are associated with a group I use)


#load packages
library(odbc)
library(tidyverse)
library(getPass)

#pull ADFG species codes associates with tsn (from taxize.R)
adfg<-readRDS("adfg_tsn.RDS")

#use only current data
adfg<-adfg%>%
  filter(is.na(year_end))
# simplify
adfg<-adfg%>%
  mutate(adfg_code=species_code,
         adfg_comment=comments)%>%
  dplyr::select(tsn, species_common, species_scientific, adfg_code, adfg_comment)

#connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())


#pull species translation table
#determine which fields match adfg records
#ADFG is the "from_agency" for AKR and OBS records
dbFetch(dbSendQuery(con, "select distinct(to_agency) 
                                  from akr.species_translation
                    where from_agency= 'ADFG'"))

# ADFG is also the "to_agency" for AKR and OBS records... looks like we don't link to RACE
# We will try to do that later from OBS or AKR records
dbFetch(dbSendQuery(con, "select distinct(from_agency) 
                                  from akr.species_translation
                    where to_agency= 'ADFG'"))

#download species translation table for modern records only
species_trans<-dbFetch(dbSendQuery(con,
                                   paste0("select* 
                                  from akr.species_translation
                                  where to_end_date is null
                                  and from_end_date is null")))%>%
  rename_with(tolower)

#join AKR codes
#filter to where the from and to agencies are ADFG and AKR respectively
ADFG_AKR<-species_trans%>%
  filter(from_agency=="ADFG" &
           to_agency=="AKR")

#reduce
ADFG_AKR<-ADFG_AKR%>%
  mutate(akr_code1=to_code,
         adfg_code=from_code,
         akr_name1=to_name)%>%
  dplyr::select(akr_code1, akr_name1, adfg_code)

#join
akfin_species<-adfg%>%
  left_join(ADFG_AKR, by="adfg_code")

#inspect
view(akfin_species)

#get rid of macroalgae codes
akfin_species<-akfin_species%>%
  filter(species_common!="Macroalgae Codes")

#validate AKR by reversing the to/from
AKR_ADFG<-species_trans%>%
  filter(from_agency=="AKR" &
           to_agency=="ADFG")

#reduce
AKR_ADFG<-AKR_ADFG%>%
  mutate(akr_code2=from_code,
         adfg_code=to_code,
         akr_name2=from_name)%>%
  dplyr::select(akr_code2, akr_name2, adfg_code)

#join
akfin_species<-akfin_species%>%
  left_join(AKR_ADFG, by="adfg_code")

#inspect
view(akfin_species)

#combine AKR fields
akfin_species<-akfin_species%>%
  mutate(akr_code=ifelse(!is.na(akr_code1), akr_code1, akr_code2),
         akr_name=ifelse(!is.na(akr_name1), akr_name1, akr_name2))%>%
  dplyr::select(-c(akr_code1, akr_code2, akr_name1, akr_name2))

# join obs codes
#filter to where the from and to agencies are ADFG and OBS respectively
ADFG_OBS<-species_trans%>%
  filter(from_agency=="ADFG" &
           to_agency=="OBS")

#reduce
ADFG_OBS<-ADFG_OBS%>%
  mutate(OBS_code1=to_code,
         adfg_code=from_code,
         OBS_name1=to_name)%>%
  dplyr::select(OBS_code1, OBS_name1, adfg_code)

#join
akfin_species<-akfin_species%>%
  left_join(ADFG_OBS, by="adfg_code")

#inspect
view(akfin_species)

#validate OBS by reversing the to/from
OBS_ADFG<-species_trans%>%
  filter(from_agency=="OBS" &
           to_agency=="ADFG")

#reduce
OBS_ADFG<-OBS_ADFG%>%
  mutate(OBS_code2=from_code,
         adfg_code=to_code,
         OBS_name2=from_name)%>%
  dplyr::select(OBS_code2, OBS_name2, adfg_code)

#join
akfin_species<-akfin_species%>%
  left_join(OBS_ADFG, by="adfg_code")

#inspect
view(akfin_species)

#combine OBS fields
akfin_species<-akfin_species%>%
  mutate(OBS_code=ifelse(!is.na(OBS_code1), OBS_code1, OBS_code2),
         OBS_name=ifelse(!is.na(OBS_name1), OBS_name1, OBS_name2))%>%
  dplyr::select(-c(OBS_code1, OBS_code2, OBS_name1, OBS_name2))

#Which agencies can I join on RACE?
#ADFG is the "from_agency" for AKR and OBS records
dbFetch(dbSendQuery(con, "select distinct(to_agency) 
                                  from akr.species_translation
                    where from_agency= 'RACE'"))

#Join in race
#Looks like just a one way path from RACE to OBS
dbFetch(dbSendQuery(con, "select distinct(from_agency) 
                                  from akr.species_translation
                    where to_agency= 'RACE'"))


#filter to where the from and to agencies are RACE and OBS respectively
RACE_OBS<-species_trans%>%
  filter(from_agency=="RACE" &
           to_agency=="OBS")

#reduce
RACE_OBS<-RACE_OBS%>%
  mutate(OBS_code=to_code,
         race_code=from_code,
         race_name=from_name)%>%
  dplyr::select(OBS_code, race_code, race_name)

#join
akfin_species<-akfin_species%>%
  left_join(RACE_OBS, by="OBS_code")

#inspect
view(akfin_species)

#rename to lower
akfin_species<-akfin_species%>%
  rename_with(tolower)


# Add IPHC
iphc<-read.csv("species_code_conv_table.csv")%>%
  rename_with(tolower)

#should I join on race or obs? 
#which has most
length(unique(akfin_species$race_code))
length(unique(akfin_species$obs_code))
#race
#replace 0 with NA
#iphc[iphc == 0] <- NA

#reduce
iphc<-iphc%>%
  mutate(iphc_name=iphc_comm_name,
         sa_comments=notes,
         race_code=as.character(race_code))%>%
  dplyr::select(iphc_code, iphc_name, race_code, sa_comments)

#join
akfin_species<-akfin_species%>%
  left_join(iphc, by="race_code")

#cut duplicate rows
akfin_species<-akfin_species %>% distinct(.keep_all = TRUE)


#Add species group codes
groups<-dbFetch(dbSendQuery(con, "select agency_species_code, management_area_code, sg_effective_date, species_group_code  from akr.species_group_content a
                            inner join (select code from akr.agency_specie
                            where agency = 'AKR') b
                            on a.agency_species_code=b.code"))%>%
  rename_with(tolower)

#try again
#Add species group codes
#sql query filters group contetns table to akr agency codes and groundfish and psc code
groups<-dbFetch(dbSendQuery(con, "with cont as (
select *  from akr.species_group_content),
grp as ( select * from akr.species_group
where species_group_type in ('GROUNDFISH', 'PROHIBITED')),
ag as (select * from akr.agency_specie
                            where agency = 'AKR')
select cont.agency_species_code, cont.management_area_code, cont.sg_effective_date, cont.species_group_code
from cont
inner join grp on cont.species_group_code=grp.code
inner join ag on cont.agency_species_code=ag.code"))%>%
  rename_with(tolower)

#remove duplicates in species and group code
#generated a lot of duplicates...
group_test<-groups %>% distinct(.keep_all = TRUE)

#remove duplicates in species and group code
#group_test<-groups %>% distinct(agency_species_code, management_area_code, species_group_code, .keep_all = TRUE)

#pivot for regional codes
group_test<-group_test%>%
pivot_wider(values_from="species_group_code", 
            names_from="management_area_code")


groups<-groups%>%
  mutate(akr_code=agency_species_code)%>%
  dplyr::select(akr_code, species_group_code)

akfin_species_groups<-akfin_species%>%
  left_join(groups, by="akr_code")

akfin_species_groups%>%
  filter(species_scientific=="Gadus macrocephalus")
