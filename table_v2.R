#### AKFIN SPECIES TABLE ####
#Matt Callahan
#3/16/23
#This code produces a lookup table of species codes for stocks of commercial interst in Alaskan waters.
#It is based off of The AKR species translation table.
#It also brings in tsn from the taxize package and IPHC from a spreadsheet Jane gave me.
#The result of this script will be the input into another table that also contains species codes.
#This has not been qa/qcd or validated yet. Use with caution.

# load packages
library(odbc)
library(tidyverse)
library(getPass)
library(lubridate)

# connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())

# pull species translation
spectrans<-dbFetch(dbSendQuery(con, "select * from akr.species_translation"))%>%
  rename_with(tolower)

#convert dates to years
spectrans<- spectrans %>% 
  mutate(from_begin_year=year(from_begin_date),
         from_end_year=year(from_end_date),
         to_end_year=year(to_end_date),
         to_begin_year=year(to_begin_date))

# vector of akr relevant species codes
#this was created manually but see akr-code-list.sql
#expansion of this project will require updating this
akr_codes<-readRDS("akr_codes.RDS")


#link AKR and ADFG
akradfg<-spectrans %>%
  filter(from_agency == "AKR" & to_agency == "ADFG")

#filter to fish codes we care about
akradfg<-akradfg %>%
  filter(from_code %in% akr_codes)

#reduce clutter
akradfg<-akradfg%>%
  #translate agencies
  mutate(akr_code=from_code,
         akr_begin_year=from_begin_year,
         akr_end_year=from_end_year,
         akr_name=from_name,
         adfg_code=to_code,
         adfg_begin_year=to_begin_year,
         adfg_end_year=to_end_year,
         adfg_name=to_name) %>%
  dplyr::select(akr_code,
                akr_begin_year,
                akr_end_year,
                akr_name,
                adfg_code,
                adfg_begin_year,
                adfg_end_year,
                adfg_name)

#add observer data
#isolate adfg obs data
adfgobs<-spectrans%>%
  filter(from_agency=="ADFG" &
           to_agency=="OBS") %>%
  mutate(adfg_code=from_code,
         adfg_begin_year=from_begin_year,
         adfg_end_year=from_end_year,
         obs_code=to_code,
         obs_begin_year=to_begin_year,
         obs_end_year=to_end_year,
         obs_name=to_name) %>%
  dplyr:: select(adfg_code, adfg_begin_year, adfg_end_year, obs_code, obs_begin_year, obs_end_year, obs_name)

#join
akfin_species <- akradfg %>% 
  left_join(adfgobs, by=c("adfg_code", "adfg_begin_year", "adfg_end_year"))

#filter to where the from and to agencies are RACE and OBS respectively
RACE_OBS<-spectrans%>%
  filter(from_agency=="RACE" & to_agency=="OBS") %>% 
  mutate(race_code=from_code,
         race_begin_year=from_begin_year,
         race_end_year=from_end_year,
         race_name=from_name,
         obs_code=to_code,
         obs_begin_year=to_begin_year,
         obs_end_year=to_end_year) %>%
  dplyr:: select(race_code, race_begin_year, race_end_year, race_name, obs_code, obs_begin_year, obs_end_year)

#join
akfin_species<-akfin_species%>%
  left_join(RACE_OBS, by=c("obs_code", "obs_begin_year", "obs_end_year"))

# pull ADFG species codes associates with tsn (from taxize.R)
tsn<-readRDS("adfg_tsn.RDS")

#curate
tsn <- tsn %>%
  #remove duplicated rows
  distinct() %>% 
  #change years to numeric
  mutate(year_start=as.numeric(year_start), year_end=as.numeric(year_end)) %>% 
  #remove unwanted fields
  dplyr::select(species_code, species_common, species_scientific, tsn, year_start, year_end)

#join scientific name and tsn
akfin_species<-akfin_species %>% 
  left_join(tsn, by=c("adfg_code"="species_code", "adfg_begin_year"="year_start", "adfg_end_year"="year_end"))

#iphc
iphc<-read.csv("species_code_conv_table.csv")%>%
  rename_with(tolower)
#reduce
iphc<-iphc%>%
  mutate(iphc_name=iphc_comm_name,
         sa_comments=notes,
         race_code=as.character(race_code))%>%
  dplyr::select(iphc_code, iphc_name, race_code, sa_comments)

#join
akfin_species<-akfin_species%>%
  left_join(iphc, by="race_code")

#save
saveRDS(akfin_species, "akfin_species.RDS")
