#species groups
library(lubridate)

# connect to AKFIN
con <- dbConnect(odbc::odbc(), "akfin", UID=getPass(msg="USER NAME"), PWD=getPass())

# pull species groups and save
specgroup<-dbFetch(dbSendQuery(con, "select * from akr.species_group"))%>%
  rename_with(tolower)
grpcont<-dbFetch(dbSendQuery(con, "select * from akr.species_group_content"))%>%
  rename_with(tolower)
saveRDS(specgroup, "specgroup.RDS")
saveRDS(grpcont, "grpcont.RDS")

# make dates into years
specgroup <- specgroup %>% mutate(group_effective_year=year(effective_date),
                                  group_begin_year=year(begin_date),
                                  group_end_year=year(end_date))

grpcont <- grpcont %>% mutate(group_effective_year=year(sg_effective_date))

# get start dates and end dates
groups<-grpcont %>%
  left_join(specgroup, by=c("species_group_code"="code",
                            "group_effective_year"="group_effective_year")) %>% 
  mutate(akr_code=agency_species_code,
         group_name=name) %>%
  dplyr::select(akr_code, management_area_code, species_group_code, group_name,
                group_effective_year, group_begin_year, group_end_year,
                weight_or_count_code, species_group_type)

# import akfin_species from table_v2
akfin_species <- readRDS("akfin_species.RDS")

#join species group info to species codes
test <- akfin_species %>% left_join(groups, by="akr_code")

# remove rows where group started after species code ends
# and rows where group ended before species started
test <- test %>% mutate(mismatch=ifelse(group_begin_year>akr_end_year, 1,
                                        ifelse(group_end_year<akr_begin_year, 1, 0))) %>% 
  filter(mismatch==0 | is.na(mismatch))

#explore
#how many species are in each group by year, start and end dates
test %>% group_by(species_group_code, group_name) %>% 
  summarize(count=n(),
            n_akr_code=n_distinct(akr_code),
            n_start_year=n_distinct(group_begin_year),
            n_end_year=n_distinct(group_end_year, na.rm=T)) %>% 
  print(n=Inf)

test %>% group_by(species_group_code, group_name, group_begin_year, group_end_year) %>% 
  summarize(n_akr_code=n_distinct(akr_code)) %>% 
  print(n=Inf)

#compare with results from just the groups
groups %>% group_by(species_group_code, group_name, group_begin_year, group_end_year) %>% 
  summarize(n_akr_code=n_distinct(akr_code)) %>% 
  print(n=Inf)

#try to get memberships                       
test %>% group_by(species_group_code, group_name, management_area_code, group_begin_year, group_end_year) %>% 
  summarize(akr_codes=unique(akr_code)) %>% 
  print(n=Inf)

#actually just summarizing the group tables might be sufficient
groups %>% group_by(species_group_code, group_name, management_area_code, group_begin_year, group_end_year) %>% 
  summarize(n_akr_code=unique(akr_code)) %>% 
  print(n=Inf)

