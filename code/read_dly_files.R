library(tidyverse)
library(glue)
library(lubridate)

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

quad <- function(x) {
  c(glue("value{x}"), glue("mflag{x}"), glue("qflag{x}"), glue("sflag{x}"))
}

widths <-
  c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))

headers <-
  c("id", "year", "month", "element", quad(seq(1, 31, 1)))

read_fwf("data/ghcnd_concat.gz",
    fwf_widths(widths, headers),
    na = c("NA", "-9999", ""),
    col_types = cols(.default = col_character()),
    col_select = c(id, year, month, element, starts_with("value"))
  )
#|>
  filter(element == "PRCP") |>
  select(-element) |>
  pivot_longer(starts_with("value"), names_to = "day", values_to = "prcp") |>
  mutate(
    day = parse_number(day),
    prcp_cm = as.numeric(prcp) / 100,
    date = ymd(glue("{year}-{month}-{day}"))
  ) |> # prcp now in cm
  select(id, date, prcp_cm) |>
  drop_na() |> # drop dates that do not exist
  write_tsv("data/composite_dly.tsv")
