#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(showtext)
library(glue)

font_add_google("Secular One", family = "secular-one")
font_add_google("Cormorant Garamond", family = "c-garamond")

showtext_auto()

prcp_data <- read_tsv("data/ghcnd_tidy.tsv.gz")

station_data <- read_tsv("data/ghcnd_regions_years.tsv")

# anti_join(prcp_data, station_data, by = "id")
# anti_join(station_data, prcp_data, by = "id")

lat_long_prcp <- inner_join(prcp_data, station_data, by = "id") |>
  filter((year != first_year & year != last_year) | year == 2022) |>
  group_by(lat, lon, year) |>
  summarize(mean_prcp = mean(prcp), .groups = "drop")

end <- today() - 5
start <- today() - 35

end_all <- case_when(
  month(start) != month(end) ~ format(end, "%B %-d, %Y"),
  month(start) == month(end) ~ format(end, "%-d, %Y"),
  TRUE ~ NA_character_)

start_all <- case_when(
  year(start) != year(end) ~ format(start, "%B %-d, %Y"),
  year(start) == year(end) ~ format(start, "%B %-d"),
  TRUE ~ NA_character_
)

date_range <- glue::glue("{start_all} to {end_all}")

# TODO fix ordinal suffix to dates

world_map <- map_data("world") |> 
  filter(region != "Antarctica")

lat_long_prcp |>
  group_by(lat, lon) |>
  mutate(
    z_score = (mean_prcp - mean(mean_prcp)) / sd(mean_prcp),
    n = n()
  ) |>
  ungroup() |>
  filter(n >= 50 & year == 2022) |>
  select(-n, -mean_prcp, -year) |>
  mutate(z_score = case_when(
    z_score > 2 ~ 2,
    z_score < -2 ~ -2,
    TRUE ~ z_score
  )) |>
  ggplot(aes(lon, lat, fill = z_score)) +
  geom_map(data = world_map, aes(map_id = region), map = world_map,
           fill = NA, color ="#909090", size = .05, inherit.aes = FALSE) +
  expand_limits(x = world_map$long, y = world_map$lat) +
  geom_tile() +
  coord_fixed() +
  scale_fill_gradient2(
    low = "brown", mid = "#f5f5f5", high = "#5ab4ac",
    breaks = seq(-2, 2, 1),
    labels = c("< -2", "-1", "0", "1", "> 2")
  ) +
  labs(fill = "Z score",
       title = glue::glue("Amount of prcp from {date_range}"),
       subtitle = "Standardized z-scores for at least the past 50 years",
       caption = "Precipitation data from GHCND daily data at NOAA") +
  theme_void() +
  theme(
    plot.title = element_text(hjust = .5, size = 20, family = "secular-one"),
    plot.subtitle = element_text(hjust = .5, size = 16, family = "c-garamond"),
    plot.caption = element_text(hjust = .9, size = 12, family = "c-garamond"),
    plot.background = element_rect(fill = "#202020", color = NA),
    panel.background = element_rect(fill = "#202020", color = NA),
    legend.text = element_text(color = "#909090", size = 6, family = "c-garamond"),
    legend.title = element_blank(),
    legend.position = c(.15, .05),
    legend.direction = "horizontal",
    legend.key.height = unit(.2, "cm"),
    text = element_text(color = "#909090")
  )

ggsave("visuals/heatmap_world_drought.png", 
       height = 4, width = 8, 
       device = grDevices::png, 
       dpi = 300)
