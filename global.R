library(shiny)
library(ggplot2)
library(readr)
library(plotly)
library(tidyr)
library(httr)
library(dplyr)
library(lubridate)
library(jsonlite)
library(leaflet)
library(ggtext)
library(shinydashboard)
library(bslib)
library(geojsonsf)
library(googlesheets4)
library(sf)
library(fresh)

source("R/data_helpers.R")

# All externally-sourced data below is read from data/cache/, which is
# populated by data_refresh.R on a schedule. The app itself never
# scrapes or calls an external API directly at startup - if a scheduled
# refresh fails for a dataset, its cache file is left untouched, so the
# app keeps running on the last successful pull (see
# data/cache/refresh_log.csv for a history of refresh attempts).

#OBWB INFLOWS DATA FRAME ----------------------------------------------
df_inflow <- read_cache_csv("df_inflow")
df_inflow$`Week ending` <- as.Date(df_inflow$`Week ending`)

latest <- df_inflow |>
  filter(!is.na(`Current (ac-ft)`)) |>
  slice_max(`Week ending`, n = 1)

current <- latest$`Current (ac-ft)`
average <- latest$`1944-2025 avg (ac-ft)`
diff <- current - average
status <- if (diff >= 0) "higher" else "lower"

#WATER CONSUMPTION DATA FRAME ------------------------------------------------------------------
df_consumption <- read_cache_csv("df_consumption")
#Converting multiple year columns to one single column
df_consumption_long <- df_consumption |>
  pivot_longer(
    cols = ends_with("VOL_m³"),
    names_to = "Year",
    values_to = "Consumption"
  )
df_consumption_long$Year <- gsub("_VOL_m³", "", df_consumption_long$Year)

#DAILY MEAN OF OKANAGAN LAKE LEVEL DATA FRAME 1990-current--------------------------------------
df_daily_mean <- read_cache_csv("df_daily_mean")
df_daily_mean$DATE <- as.Date(df_daily_mean$DATE)

#GROUND WATER MAP DATA FRAME ------------------------------------------------------------------
df_groundwater <- read_cache_csv("df_groundwater")

#Read in well locations.csv (static reference data, not part of the daily refresh)
well_locations <- read_csv(
  "data/well locations.csv",
  show_col_types = FALSE
)

#Add Lat, Long, & Status to df_groundwater
df_groundwater <- left_join(
  df_groundwater,
  select(well_locations, Well, latitude, longitude, status, summary, type),
  by = "Well"
)

#only show latest measurement for each well
second_date <- sort(unique(df_groundwater$Start), decreasing = TRUE)[2]

df_map <- df_groundwater %>%
  filter(Start == second_date)

df_map_sf <- st_as_sf(
  df_map,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

#DROUGHT MAP DATA FRAME  ---------------------------------------------------------
df_drought <- read_cache_rds("df_drought")

#HISTORICAL DROUGHT DATA FRAME ---------------------------------------------------------------------
df_drought_hist <- read_cache_csv("df_drought_hist")

#STREAM THERMAL STATE DATA FRAME --------------------------------------------------
df_stream_temp <- read_cache_csv("df_stream_temp")

#FRASER AND COLUMBIA RIVER BASIN MAP -------------------------------------------------------------------
# Static local shapefile - not part of the scheduled refresh.
df_river <- st_read("data/rivers.shp")
