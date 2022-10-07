#!/usr/bin/env Rscript

library(tidyverse)
library(glue)
library(lubridate)
# library(furrr)

# ------------------------------
# Variable   Columns   Type
# ------------------------------
# ID            1-11   Character
# YEAR         12-15   Integer
# MONTH        16-17   Integer
# ELEMENT      18-21   Character
# VALUE1       22-26   Integer
# MFLAG1       27-27   Character
# QFLAG1       28-28   Character
# SFLAG1       29-29   Character
# VALUE2       30-34   Integer
# MFLAG2       35-35   Character
# QFLAG2       36-36   Character
# SFLAG2       37-37   Character
#   .           .          .
#   .           .          .
#   .           .          .
# VALUE31    262-266   Integer
# MFLAG31    267-267   Character
# QFLAG31    268-268   Character
# SFLAG31    269-269   Character
# ------------------------------

window <- 30

quad <- function(x) {
  c(glue("value{x}"), glue("mflag{x}"), glue("qflag{x}"), glue("sflag{x}"))
}

widths <-
  c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))

headers <-
  c("id", "year", "month", "element", quad(seq(1, 31, 1)))

process_xfiles <- function(x) {
  print(x)

  read_fwf(x,
    fwf_widths(widths, headers),
    na = c("NA", "-9999", ""),
    col_types = cols(.default = col_character()),
    col_select = c(id, year, month, starts_with("value"))
  ) |>
    pivot_longer(starts_with("value"), names_to = "day", values_to = "prcp") |>
    mutate(
      day = parse_number(day),
      prcp = as.numeric(prcp) / 100,
      date = ymd(glue("{year}-{month}-{day}"), quiet = TRUE),
      prcp = replace_na(prcp, 0)
    ) |> # prcp now in cm
    drop_na(date)|> 
    select(id, date, prcp) |>
    mutate(
      julian_day = yday(date),
      diff_day = yday(today()) - julian_day,
      is_in_window = case_when(
        diff_day < window & diff_day > 0 ~ TRUE,
        diff_day > window ~ FALSE,
        yday(today()) < window & diff_day + 365 < window ~ TRUE,
        diff_day < window ~ FALSE
      ),
      year = year(date),
      year = if_else(diff_day < 0 & is_in_window, year + 1, year)
    ) |>
    filter(is_in_window) |>
    group_by(id, year) |>
    summarise(
      prcp = sum(prcp),
      .groups = "drop"
    )
}

xfiles <-
  list.files("data/temp/", ".gz", full.names = TRUE)

# plan("multisession", workers = 5)

xfiles |>
  map_dfr(process_xfiles) |>
  group_by(id, year) |>
  summarise(
    prcp = sum(prcp),
    .groups = "drop"
  ) |>
  write_tsv("data/ghcnd_tidy.tsv.gz")
