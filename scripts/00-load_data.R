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


shootings <- read_csv(here("data", "NYPD_Shooting_Incident_Data_(Historic)_20251230.csv")) %>%
  clean_names()
glimpse(shootings)
