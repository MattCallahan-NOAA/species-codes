# species-codes
The goal of this project is to develop an easy process to look up species and species group codes.

DISCLAIMER: This project is still in draft status and products have not been QA/QC'd yet. 

Table_v2.R generates a species code lookup table using the following process:
1) Pulls AKR codes from the AKR species_translation table. 
2) Limits codes to ~100 preselected subset of codes that translate to species of interest to stock assessors and other stakeholders
3) Joins ADFG, OBS, and RACE codes from the species translation table.
4) Joins itis TSN from the taxize.R file (see below)
5) Adds IPHC codes from a lookup table provided by AFSC.
akfin_species.RDS is the draft product from this script.

species_group.R connects species group codes with species codes. 
I tried a couple of formats here and am not sure what the most useful is. 

Taxize.R uses the taxize package to link ADFG codes to ITIS TSNs using scientific name.

The next step is to go about QAing all of the squirrely rockfish and flatfish.
