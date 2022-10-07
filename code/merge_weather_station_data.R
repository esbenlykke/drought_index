#!/usr/bin/env Rscript

library(tidyverse)

prcp_data <- read_tsv("data/ghcnd_tidy.tsv.gz")
station_data <- read_tsv("data/ghcnd_regions_years.tsv")

lat_lon_prpcp <- 
    inner_join(prcp_data, station_data, by = "id") |> 
    filter((year != first_year & year != last_year) | year == 2022) |> 
    group_by(lat, lon, year) |> 
    sumarise(mean_prcp = mean(prcp)) 