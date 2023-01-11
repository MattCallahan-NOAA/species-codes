--species code problem children

select* from akr.species_group where lower(name) like '%salmon%';

select* from akr.species_group where lower(name) like '%rockfish%';

--which names have multiple codes
select name, agency, count(distinct(code)) from akr.agency_specie
group by name, agency
order by count(distinct(code)) desc
;
--beligerent sculpin race code an error?
select * from akr.agency_specie where name = 'great sculpin';
select * from akr.agency_specie where name = 'belligerent sculpin';

select* from afsc.race_racespeciescodes
where common_name = 'great sculpin';

select* from afsc.race_racespeciescodes
where species_code = 21376;

select * from akr.agency_specie where name = 'Rockfish, Dusky';

--which codes have multiple names?
select code, agency, count(distinct(name)) from akr.agency_specie
group by code, agency
order by count(distinct(name)) desc
;

--AKR
--eels & Pacific sandfish
--sandfish an error?
select * from akr.agency_specie 
where code = '210'
and agency = 'AKR';
select * from akr.agency_specie where name = 'Pacific Sandfish';
select * from akr.agency_specie where lower(name) like '%sandfish%';
--smelt 510 sic
--ATF 121
--172 sharpchin/Northern then dusky rockfish
--139 other and unidentified rockfish
--213 grenadiers sic
--173 Other red and dark rockfish
--141 POP and POP complex
--100 unidentified flatfish and other species
--160 sculpins and other small sculpins
--206 Pacific sandfish sic
--OBS
--330 light dusky rockfish, dusky rockfish (non overlapping)
--345 Dark dusky rockfish, dark rockfish
--ADFG 
--210 Eels and Pacific sandfish
--141 POP and POP complex
--160 sculpins as AKR
--510 smelt sic

select * from akr.agency_specie 
where code = '510'
and agency = 'ADFG';

--What does RACE do with ATF/KF
select* from afsc.race_racespeciescodes
where common_name like '%rockfish%';


--Are akr and adfg species codes the same?
--mostly... but see red and dark rockfish for example...
select* from akr.agency_specie
where agency in ('AKR', 'ADFG')
order by code, agency;