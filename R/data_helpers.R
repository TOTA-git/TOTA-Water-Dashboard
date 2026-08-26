# Shared helpers used by both data_refresh.R (the scheduled data-refresh
# job) and global.R (the running app, which only ever reads the cache
# that job produces).

CACHE_DIR <- "data/cache"

# --- Atomic writes -----------------------------------------------------
# Write to a temp file in the same directory, then rename over the
# target. A refresh that dies partway through writing never leaves a
# truncated/corrupt cache file behind - readers always see either the
# previous good file or a fully-written new one.
atomic_write_csv <- function(df, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(path, ".tmp")
  readr::write_csv(df, tmp)
  file.rename(tmp, path)
}

atomic_write_rds <- function(obj, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(path, ".tmp")
  saveRDS(obj, tmp)
  file.rename(tmp, path)
}

# --- Cache reads (used by global.R) -------------------------------------
# Error clearly instead of silently starting the app with no data, so a
# missing/empty cache is obvious rather than surfacing as a confusing
# downstream plotting error.
read_cache_csv <- function(name, ...) {
  path <- file.path(CACHE_DIR, paste0(name, ".csv"))
  if (!file.exists(path)) {
    stop(
      "Cache file '", path, "' not found. Run data_refresh.R at least ",
      "once before starting the app."
    )
  }
  readr::read_csv(path, show_col_types = FALSE, ...)
}

read_cache_rds <- function(name) {
  path <- file.path(CACHE_DIR, paste0(name, ".rds"))
  if (!file.exists(path)) {
    stop(
      "Cache file '", path, "' not found. Run data_refresh.R at least ",
      "once before starting the app."
    )
  }
  readRDS(path)
}

# --- Refresh logging ------------------------------------------------------
# Appends one row per dataset per refresh attempt, so refresh_log.csv
# builds a history of what succeeded/failed and when.
log_refresh <- function(name, status, message = NA_character_, n_rows = NA_integer_) {
  dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
  log_path <- file.path(CACHE_DIR, "refresh_log.csv")
  entry <- data.frame(
    dataset = name,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S", tz = "UTC"),
    status = status,
    n_rows = n_rows,
    message = message,
    stringsAsFactors = FALSE
  )
  readr::write_csv(entry, log_path, append = file.exists(log_path))
}

# --- Groundwater well export helpers -------------------------------------
# Shared by data_refresh.R (batch pull for the map, across all
# wells) and server.R (on-demand single-well pull for the trend chart,
# triggered live by clicking a well - intentionally left live since it's
# a small, per-click request rather than part of the daily bulk refresh).
build_url <- function(wells) {
  base_url <- paste0(
    "https://bcmoe-prod.aquaticinformatics.net/Export/BulkExport?",
    "DateRange=Days7",
    "&TimeZone=0",
    "&Calendar=CALENDARYEAR",
    "&Interval=Daily",
    "&Step=1",
    "&ExportFormat=csv",
    "&TimeAligned=True",
    "&RoundData=True",
    "&IncludeGradeCodes=False",
    "&IncludeApprovalLevels=True",
    "&IncludeQualifiers=True",
    "&IncludeInterpolationTypes=False",
    "&IncludeNotes=undefined"
  )
  
  dataset_string <- paste(
    sapply(seq_along(wells), function(i) {
      paste0(
        "&Datasets[", i - 1, "].DatasetName=SGWL.Working%40", wells[i],
        "&Datasets[", i - 1, "].Calculation=Aggregate",
        "&Datasets[", i - 1, "].UnitId=306"
      )
    }),
    collapse = ""
  )
  paste0(base_url, dataset_string)
}

import_one_batch <- function(url) {
  well_ids <- read.csv(
    url,
    skip = 2,
    nrows = 1,
    header = FALSE,
    stringsAsFactors = FALSE
  )
  well_names <- as.character(well_ids[1, 3:ncol(well_ids)])
  
  df_wells <- read.csv(url, skip = 5)
  names(df_wells) <- c("Start", "End", well_names)
  
  tidyr::pivot_longer(
    df_wells,
    cols = -c(Start, End),
    names_to = "Well",
    values_to = "Average_m"
  )
}

import_wells <- function(well_ids) {
  groups <- split(well_ids, ceiling(seq_along(well_ids) / 20))
  urls <- lapply(groups, build_url)
  all_wells <- lapply(urls, import_one_batch)
  do.call(rbind, all_wells)
}