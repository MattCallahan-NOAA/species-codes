--script to pull codes for all stocks
/*
1. Manually identify codes we want (start with AKR codes)
2. Define akr codes, names, end date, and start date as subtable
2.1 join ADFG codes
2.2 join OBS codes
2.3 join RACE codes
2.4 sort out dates....
3 join scientific names and tsn from ADFG.SPECIES run through taxize package 
4 join iphc_codes from spreadsheet
5 join species groups with with species group contents 

*/


--vector of codes
(
100, --flatfish unid
110, --pcod
116, --Bering flounder
117, --kamchatka
118, --deepwater flatfish
119, --shallow water flatfish
120, --misc flatfish
121, --atf
122, --flathead
123, --rock
124, --dover
125, --rex
126, --butter
127, --yellowfin
128, --english
129, --starry
130, --lingcod
131, --petrale
132, --sand sole
133, --ak plaice
134, --greenland
135, --greenstriped RF
136, --Northern RF
137, --Bocaccio
138, --Copper
139, --Other rf
141, --pop
142, --black rf
143, --Thornyhead
144, --slope
145, --yelloweye
146, --canary
147, --quillback
148, --tiger
149, --china
150, --rosethorn
151, --rougheye
152, --shortraker
153, --redbanded
154, --dusky
155, --yellowtail
156, --widow
157, --silvergray
158, --redstripe
159, --darkblotched
166, --sharpshin
167, --blue
168, --demersal shelf
169, --pelagic shelf
171, --Shortraker/Rougheye Rockfish
172, --Sharpchin/Northern Rockfish then dusky
173, --dark or other red
175, --yellowmouth
176, --Harlequin Rockfish
177, --Blackgill Rockfish
178, --Chilipepper Rockfish
179, --Pygmy
181, --shortbelly
182, --splitnose
183, --stripetail
184, --vermillion
185, --aurora
193, --atka
200, --halibut
213, --grenadiers
214,
230, --herr
235, --herr
270, --pollock
000, --salmon
410,
420,
430,
440,
450,
690, --shark
691,
692,
689,
700, --skate
701,
702,
703,
704,
705, 
710, --sablefish
870 --octopus
);

-- 
-- 
with akr as
(select code akr_code, name akr_name, begin_date, end_date
(710, --sablefish
270, --pollock
110, --pcod
100, --flatfish unid
117, --kamchatka
118, --deepwater flatfish
119, --shallow water flatfish
120, --misc flatfish
121, --atf
122, --flathead
123, --rock
124, --dover
125, --rex
126, --butter
127, --yellowfin
128, --english
131, --petrale
132, --sand sole
133, --ak plaice
134, --greenland
135, --greenstriped RF
136, --Northern RF
137, --Bocaccio
138, --Copper
139, --Other rf
141, --pop
142, --black rf
143, --Thornyhead
144, --slope
145, --yelloweye
146, --canary
147, --quillback
148, --tiger
149, --china
150, --rosethorn
151, --rougheye
152, --shortraker
153, --redbanded
154, --dusky
155, --yellowtail
156, --widow
157, --silvergray
158, --redstripe
159, --darkblotched
166, --sharpshin
167, --blue
168, --demersal shelf
169, --pelagic shelf
171, --Shortraker/Rougheye Rockfish
172, --Sharpchin/Northern Rockfish then dusky
173, --dark or other red
175, --yellowmouth
176, --Harlequin Rockfish
177, --Blackgill Rockfish
178, --Chilipepper Rockfish
179, --Pygmy
181, --shortbelly
182, --splitnose
183, --stripetail
184, --vermillion
185, --aurora
193, --atka
870, --octopus
230, --herr
235, --herr
200, --halibut
000, --salmon
410,
420,
430,
440,
450,
690, --shark
691,
692,
689,
700, --skate
701,
702,
703,
704,
705, 
213, --grenadiers
214
);


