##
## Load and prepare data for small areas: various Output Areas and Wards
##
library(tidyverse)
library(readxl)
library(httr)
library(sf)

# ---- Output Areas ----
# - Boundaries -
# Output Areas (December 2011) Population Weighted Centroids
# Source: https://geoportal.statistics.gov.uk/datasets/output-areas-december-2011-population-weighted-centroids-1
oa_centroids <- read_sf("https://opendata.arcgis.com/datasets/b0c86eaafc5a4f339eb36785628da904_0.geojson")
write_rds(oa_centroids, "data/boundaries/oa_centroids.rds")

# Output Areas (December 2011) Boundaries EW BGC
# Source: https://geoportal.statistics.gov.uk/datasets/output-areas-december-2011-boundaries-ew-bgc-1
oa_bounds <- read_sf("https://opendata.arcgis.com/datasets/a76b2f87057b43d989d8f01733104d62_0.geojson")
write_rds(oa_bounds, "data/boundaries/oa_bounds.rds")

# - Population estimates -
# Currently using mid-2019 estimates
# Source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datalist?sortBy=release_date&query=output%20area&filter=datasets&fromDateDay=&fromDateMonth=&fromDateYear=&toDateDay=&toDateMonth=&toDateYear=&size=10
# ONS publishes output area population estimates in separate files for each region
pop_urls <- c(
  # East Midlands
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesintheeastmidlandsregionofengland%2fmid2019sape22dt10f/sape22dt10fmid2019eastmidlands.zip",
  
  # North West
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthenorthwestregionofengland%2fmid2019sape22dt10b/sape22dt10bmid2019northwest.zip",
  
  # South East
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthesoutheastregionofengland%2fmid2019sape22dt10i/sape22dt10imid2019southeast.zip",
  
  # East
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesintheeastregionofengland%2fmid2019sape22dt10h/sape22dt10hmid2019east.zip",
  
  # West Midlands
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthewestmidlandsregionofengland%2fmid2019sape22dt10e/sape22dt10emid2019westmidlands.zip",
  
  # Wales
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinwales%2fmid2019sape22dt10j/sape22dt10jmid2019wales.zip",
  
  # North East
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthenortheastregionofengland%2fmid2019sape22dt10d/sape22dt10dmid2019northeast.zip",
  
  # South West
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthesouthwestregionofengland%2fmid2019sape22dt10g/sape22dt10gmid2019southwest.zip",
  
  # Yorkshire and The Humber
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesintheyorkshireandthehumberregionofengland%2fmid2019sape22dt10c/sape22dt10cmid2019yorkshireandthehumber.zip",
  
  # London
  "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fcensusoutputareaestimatesinthelondonregionofengland%2fmid2019sape22dt10a/sape22dt10amid2019london.zip"
)

# Download and upzip population estimates for each region
for (url in pop_urls) {
  GET(url, write_disk(tf <- tempfile(fileext = ".zip")))
  unzip(tf, exdir = "data/population/output areas")
  unlink(tf)
}

pop_files <- list.files("data/population/output areas", full.names = T)

# Load population estimates
for (file in pop_files) {
  
  # if the merged dataset doesn't exist, create it
  if (!exists("oa_pop")){
    oa_pop <- read_excel(file, sheet = "Mid-2019 Persons", skip = 4) %>% 
      select(OA11CD, LSOA11CD, `All Ages`)
    
  } else {
    # if the merged dataset does exist, append to it
    temp_dataset <- read_excel(file, sheet = "Mid-2019 Persons", skip = 4) %>% 
      select(OA11CD, LSOA11CD, `All Ages`)
    
    oa_pop <- rbind(oa_pop, temp_dataset)
    rm(temp_dataset)
  }
}

oa_pop %>% 
  rename(n = `All Ages`) %>% 
  write_rds("data/population/oa_pop.rds")

# ---- Lower Layer Super Output Areas ----
# - Boundaries -
# Lower Layer Super Output Areas (December 2011) EW BGC V2
# Source: https://geoportal.statistics.gov.uk/datasets/lower-layer-super-output-areas-december-2011-ew-bgc-v2/data
lsoa_bounds <- read_sf("https://opendata.arcgis.com/datasets/42f3aa4ca58742e8a55064a213fb27c9_0.geojson")

write_rds(lsoa_bounds, "data/boundaries/lsoa_bounds.rds")

# - Population estimates -
# Source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates
GET("https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2flowersuperoutputareamidyearpopulationestimates%2fmid2019sape22dt2/sape22dt2mid2019lsoasyoaestimatesunformatted.zip",
    write_disk(tf <- tempfile(fileext = ".zip")))

unzip(tf, exdir = "data/population")
unlink(tf); rm(tf)

lsoa_pop <- read_excel("data/population/SAPE22DT2-mid-2019-lsoa-syoa-estimates-unformatted.xlsx", sheet = "Mid-2019 Persons", skip = 4)

lsoa_pop %>% 
  select(LSOA11CD = `LSOA Code`, n = `All Ages`) %>% 
  write_rds("data/population/lsoa_pop.rds")

# ---- Middle Layer Super Output Areas ----
# - Boundaries -
# Middle Layer Super Output Areas (December 2011) EW BSC V2
# Source: https://geoportal.statistics.gov.uk/datasets/middle-layer-super-output-areas-december-2011-ew-bsc-v2
msoa_bounds <- read_sf("https://opendata.arcgis.com/datasets/23cdb60ee47e4fef8d72e4ee202accb0_0.geojson")
write_rds(msoa_bounds, "data/boundaries/msoa_bounds.rds")

# - Population estimates -
## source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/middlesuperoutputareamidyearpopulationestimates
##
GET("https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fmiddlesuperoutputareamidyearpopulationestimates%2fmid2018sape21dt3a/sape21dt3amid2018msoaon2019lasyoaestimatesformatted.zip",
    write_disk(tf <- tempfile(fileext = ".zip")))

unzip(tf, exdir = "data/population")
unlink(tf); rm(tf)

msoa_pop <- read_excel("data/population/SAPE21DT3a-mid-2018-msoa-on-2019-LA-syoa-estimates-formatted.xlsx", sheet = "Mid-2018 Persons", skip = 4)

msoa_pop %>% 
  filter(!is.na(MSOA)) %>%  # drop Local Authorities
  select(MSOA11CD = `Area Codes`, n = `All Ages`) %>% 
  write_rds("data/population/msoa_pop.rds")
