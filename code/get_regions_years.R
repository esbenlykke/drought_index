#!/usr/bin/env Rscript

library(tidyverse)

# https://www.ncei.noaa.gov/pub/data/ghcn/daily/readme.txt

# ------------------------------
#   Variable   Columns   Type
# ------------------------------
#   ID            1-11   Character
# LATITUDE     13-20   Real
# LONGITUDE    22-30   Real
# ELEMENT      32-35   Character
# FIRSTYEAR    37-40   Integer
# LASTYEAR     42-45   Integer
# ------------------------------

read_fwf("data/ghcnd-inventory.txt",
  col_positions = fwf_cols(
    id = c(1, 11),
    lat = c(13, 20),
    lon = c(22, 30),
    element = c(32, 35),
    first_year = c(37, 40),
    last_year = c(42, 45)
  )
) |>
  filter(element == "PRCP") |> 
  mutate(
    lat = round(lat, 0),
    lon = round(lon, 0)
  ) |>
  group_by(lon, lat) |>
  mutate(
    region = cur_group_id(),
    .before = lat
  ) |> 
  select(- element) |> 
  write_tsv("data/ghcnd_regions_years.tsv")
