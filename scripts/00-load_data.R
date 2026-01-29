# libraries
library(tidyverse)
library(here)
library(janitor)

# list files (optional sanity check)
list.files(here("data"))

# load and clean names
arrests <- read_csv(
  here("data", "NYPD_Arrests_Data_(Historic)_20251229.csv"),
  show_col_types = FALSE
) |>
  clean_names()

complaints <- read_csv(
  here("data", "NYPD_Complaint_Data_Historic_20251229.csv"),
  show_col_types = FALSE
) |>
  clean_names() %>%
  filter(!pd_cd %in% c(111,113))


shots_fired <- read_csv(here("data","shots_fired_new.csv")) %>%
  clean_names()

sf2017 <- read_csv(here("data","sf_since_2017.csv")) %>%
  clean_names()


shootings <- read_csv(here("data", "NYPD_Shooting_Incident_Data_(Historic)_20251230.csv")) %>%
  clean_names()
glimpse(shootings)




complaints %>%
  count(ofns_desc)


arrests %>%
  filter(ky_cd %in% c(101,104:107,109,110,344)) %>%
  count(ofns_desc)

arrests %>%
  filter(ky_cd %in% c(106)) %>%
  count(ofns_desc,pd_desc,law_code) %>%
  arrange(desc(n))







complaints %>%
  filter(ky_cd=='344') %>%
  count(pd_cd, pd_desc)


x<- complaints %>%
  filter(ky_cd %in% c(101,105:106,344)) %>%
  count(ofns_desc, pd_desc)
print(x, n = 500)




list.files('./data/')
arrests1 <- read_csv(here("data","arrests (13).csv")) %>%
  clean_names()

x <- arrests1 %>%
  count(offense_description1)

serious_crimes <- c('ASSAULT 3 & RELATED OFFENSES', 'BURGLARY', 'FELONY ASSAULT',
                    'GRAND LARCENY', 'GRAND LARCENY OF MOTOR VEHICLE', 
                    'MURDER & NON-NEGL. MANSLAUGHT', 'ROBBERY')

chi_arrests <- arrests1 %>%
  filter(offense_description1 %in% serious_crimes) %>%
  filter(!pd_description %in% c('MENACING,PEACE OFFICER','MENACING,UNCLASSIFIED')) %>%
  distinct(arrest_key, .keep_all = T) %>%
  mutate(law_code_trim = str_sub(law_code, 1, -3))


x <- chi_arrests %>%
  count(offense_description1,law_code_trim) %>%
  arrange(desc(n))

glimpse(chi_arrests)




shootings <- read_csv(here("data", "NYPD_Shooting_Incident_Data_(Historic)_20251230.csv")) %>%
  clean_names()
glimpse(shootings)


# =============================================================================
# 4. SHOTS FIRED DATA
# =============================================================================

message("Loading shots fired data...")

# Older shots fired data (through Sept 2022)
sf2017 <- read_csv(here("data", "sf_since_2017.csv"), show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    date = mdy(cmplnt_fr_dt),
    source = "sf2017"
  ) %>%
  filter(!is.na(date), date <= ymd("2022-09-30"))

# Newer shots fired data (Oct 2022 onward)
shots_fired_new <- read_csv(here("data", "shots_fired_new.csv"), show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    date = mdy(cmplnt_fr_dt),
    source = "shots_fired_new"
  ) %>%
  rename(
    pct = cmplnt_pct_cd,
    x_coord_cd = x_coordinate_code,
    y_coord_cd = y_coordinate_code
  ) %>%
  filter(!is.na(date), date >= ymd("2022-10-01"))

# Combine shots fired datasets
shots_fired <- bind_rows(sf2017, shots_fired_new) %>%
  filter(!is.na(x_coord_cd), !is.na(y_coord_cd)) %>%
  distinct(cmplnt_key, .keep_all = T)


message(sprintf("  Loaded %d shots fired incidents (%s to %s)",
                nrow(shots_fired),
                min(shots_fired$date),
                max(shots_fired$date)))

table(shots_fired$pd_desc)

