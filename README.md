# TOTA Water Dashboard

An interactive **R Shiny dashboard hosted by Posit Connect Cloud** that brings together publicly available water and environmental data for the Thompson Okanagan region.

https://tota-water-dashboard.share.connect.posit.cloud/

The dashboard was developed by the **Thompson Okanagan Tourism Association (TOTA)** to support water management reporting for the **UN Tourism International Network of Sustainable Tourism Observatories (INSTO)**. The Okanagan watershed is currently used as a pilot area for developing repeatable methods to collect, organize, monitor, and communicate regional water data.

This repository is intended to serve as both the source code for the dashboard and a technical handover document for future TOTA staff responsible for maintaining or expanding the project.

---

## Table of Contents

* [How the Application Works](#how-the-application-works)
* [How the Data Refresh System Works](#how-the-data-refresh-system-works)
* [Data Sources](#data-sources)
* [Running the Dashboard Locally](#running-the-dashboard-locally)
* [Secrets and variables for Sensitive URLs](#secrets-and-variables-for-sensitive-urls)
* [How to Update the Dashboard](#how-to-update-the-dashboard)
* [Adding New Data Sources](#adding-new-data-sources)
* [Troubleshooting](#troubleshooting)
* [Important Maintenance Notes](#important-maintenance-notes)
* [Recommended Handover Checklist](#recommended-handover-checklist)
* [Key Files at a Glance](#key-files-at-a-glance)
* [Maintainer Notes](#maintainer-notes)

---

# How the Application Works

The data is refreshed daily using a Github Action Workflow (refresh_data.yml). When the data is refresh it is pushed/committed to this repo, this triggers the Posit Connect Cloud to republish the dashboard with the new refreshed data. 

*Everytime a commit is made in the repo, the dashbaord is republished.*

The dashboard is structured using standard R Shiny files.

## `app.R`

This is the main application entry point.

It loads the primary application components:

```r
source("global.R")
source("ui.R")
source("server.R")
source("R/data_helpers.R")

shinyApp(ui, server)
```

When running the application, `app.R` should normally be the starting point.

---

## `global.R`

`global.R` loads:

* Required R packages
* Helper functions
* Cached datasets
* Static datasets
* Pre-processing required before the dashboard starts

> **The live Shiny application does not directly call external APIs or scrape websites when the dashboard starts.**

Instead, `global.R` reads previously downloaded data from:

```text
data/cache/
```

This improves reliability and performance.

If a data refresh fails, the dashboard can continue running using the most recent successful cache.

---

## `ui.R`

`ui.R` defines the visual layout of the dashboard.

This includes:

* Sidebar navigation
* Dashboard tabs
* Text and explanations
* Plot locations
* Maps
* Boxes and information panels
* Images
* Footer
* Styling and responsive design

## `server.R`

`server.R` contains the dashboard logic.

This includes:

* Plot creation
* Interactive filters
* Maps
* Data transformations used during the user session
* Navigation between sections
* Dynamic dashboard content

Use `server.R` when changing how the dashboard behaves or how visualizations are calculated.

---

## `data_refresh.R`

`data_refresh.R` is responsible for downloading and updating external datasets.

The script:

1. Connects to each external data source.
2. Downloads or scrapes the data.
3. Processes the data.
4. Writes the result into `data/cache/`.
5. Records whether the refresh was successful or unsuccessful in refresh_log.csv.

Each dataset is refreshed independently.

This is intentional. If one data source fails, the remaining datasets can still refresh.

The previous cached version of the failed dataset is retained.

This means the dashboard can continue using the **last successful version** of each dataset.

---

## `R/data_helpers.R`

This file contains reusable helper functions.

Examples include functions used for:

* Reading cached data
* Writing cached data safely
* Logging refresh attempts
* Importing well data

If adding repeated data-processing logic, consider placing the logic in this file rather than duplicating it across multiple scripts.

---

# How the Data Refresh System Works

The project uses a cached data architecture.

The general workflow is:

```text
External Data Source
        ↓
data_refresh.R
        ↓
Data Processing/Cleaning
        ↓
data/cache/
        ↓
global.R
        ↓
Shiny Dashboard

```

The dashboard itself reads from the cache rather than directly from external websites.

This is important because:

* External websites may temporarily fail.
* APIs may have rate limits.
* Scraping can be slow.
* Data sources may change unexpectedly.
* The dashboard should still work if refresh fails.

---

## Refreshing Data Manually

To manually run the refresh process:

select "Actions" -> "Scheduled Data Refresh" -> "Run workflow"

Refresh usually takes 2-4 minutes

---

## Scheduled Refreshes

The repository includes a GitHub Actions workflow that can be used to run the data refresh automatically.

The scheduled workflow is located in:

```text
.github/workflows/
```

Future staff should check the workflow if data stops refreshing.

Possible issues include:

* Expired or missing GitHub Secrets
* Changes to external APIs
* Changes to website HTML
* R package installation failures
* GitHub Actions environment changes

---

# Data Sources

The current dashboard combines several external and internally maintained datasets.
Two sources are Google Sheets **Do not change the URL of the Google Sheets**

## Net Inflow

Source:

* Okanagan Water Supply
* Okanagan Basin Water Board
* Water Survey of Canada data

The data refresh process uses a browser automation approach because the required table is generated dynamically by a Shiny application.

### Important maintenance note

The scraper does **not** rely only on a fixed HTML tab ID.

It searches for the tab using the text:

```text
Data table
```

This was implemented because dynamically generated IDs can change when the source website is updated.

If the net inflow refresh stops working:

1. Visit the source website https://www.okanaganwatersupply.com/
2. Confirm that the data table still exists.
3. Check whether the text or structure of the tab has changed.
4. Review the scraper in `data_refresh.R`.

---

## Water Consumption

Source:

* TOTA-maintained Google Sheet (Do not change the URL of this sheet)

The Google Sheet contains water consumption information maintained by TOTA.

The sheet URL is intentionally stored outside the public code repository as an environment variable.

The refresh script uses:

```text
GOOGLE_SHEET_CONSUMPTION_URL
```

See the [Environment Variables and Sensitive URLs](#environment-variables-and-sensitive-urls) section for more information.

### Updating Water Consumption Data

When updating the source spreadsheet:

1. Add or update the data in the approved Google Sheet.
2. Maintain the expected column names.
3. Ensure volume values are numeric.
4. Trigger or wait for the scheduled refresh.
5. Confirm that the cache updates successfully.
6. Check the dashboard after the refresh.

---

## Okanagan Lake Daily Mean Level

Source:

* Environment and Climate Change Canada
* MSC GeoMet API

The dashboard currently uses hydrometric station:

```text
08NM083
```

The refresh script retrieves data from 1990 onward.

The API is paginated, meaning the script retrieves multiple batches if necessary.

If the dataset changes:

* Confirm the station number.
* Confirm the API field names.
* Check whether pagination is still required.

---

## Groundwater Wells

Source:

* BC Ministry of Environment groundwater information

The project uses a static reference file containing well locations:

```text
data/well locations.csv
```

The refresh script uses the well IDs from this file to download groundwater information.

### Important maintenance note

The static file controls which wells are included in the dashboard.

To add a new well:

1. Add the well identifier.
2. Add latitude and longitude.
3. Add status and any required metadata.
4. Run the refresh process.
5. Confirm that the well appears on the map.

---

## Current Drought Conditions

Source:

* British Columbia drought information
* ArcGIS FeatureServer

The dashboard requests current drought information for selected basins.

The current list includes:

* Okanagan
* South Thompson
* North Thompson
* Lower Thompson
* Kettle River
* Nicola
* Similkameen

The current drought URL is defined directly in `data_refresh.R`.

### Important maintenance note

If the drought layer changes:

1. Check the BC drought portal.
2. Find the updated ArcGIS FeatureServer.
3. Confirm that the field names are still correct.
4. Update the URL in `data_refresh.R`.

---

## Historical Drought Conditions

Source:

* TOTA-maintained Google Sheet (Do not change the URL of this sheet)

The historical drought data uses:

```text
GOOGLE_SHEET_DROUGHT_URL
```

The refresh script expects:

```text
BasinName
Start_Date
DroughtLevel
```

The script also converts:

```text
Not updated outside of core drought season
```

to:

```text
6
```

Future maintainers should be aware of this transformation when updating the source data.

---

## Stream Temperature

Source:

* Okanagan Basin Water Board stream temperature dataset

The refresh process downloads a ZIP file containing the latest stream temperature information.

The script extracts:

```text
stream_temperature_daily.csv
```

### Important maintenance note

If this source changes:

1. Confirm that the ZIP file still downloads.
2. Confirm the expected CSV filename.
3. Check the column names.
4. Update the script if necessary.

---

# Running the Dashboard Locally

## Requirements

Install:

* R
* RStudio (recommended)
* Git

Clone the repository:

```bash
git clone https://github.com/TOTA-git/TOTA-Water-Dashboard.git
```

Open the project in RStudio.

---

## Required R Packages

The project uses packages including:

```r
shiny
shinydashboard
ggplot2
readr
plotly
tidyr
httr
dplyr
lubridate
jsonlite
leaflet
ggtext
bslib
geojsonsf
googlesheets4
sf
fresh
rvest
chromote
```

Install any missing packages before running the application.

For example:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "readr",
  "plotly",
  "tidyr",
  "httr",
  "dplyr",
  "lubridate",
  "jsonlite",
  "leaflet",
  "ggtext",
  "bslib",
  "geojsonsf",
  "googlesheets4",
  "sf",
  "fresh",
  "rvest",
  "chromote"
))
```

---

## Start the Application

Run:

```r
shiny::runApp()
```

Or open:

```text
app.R
```

and run the application from RStudio.

---

# Secrets and variables for Sensitive URLs

This repository is public.

For that reason, confidential or private data URLs should **not** be written directly into the code.

The dashboard currently expects the following environment variables:

```text
GOOGLE_SHEET_CONSUMPTION_URL
GOOGLE_SHEET_DROUGHT_URL
```
*If a Google Sheet URL changes the "Secrets and variables -> Actions" in settings will have to be updated and have "format=csv" in the replaced url

These variables should be stored as secrets in the environment where the scheduled refresh runs.

---

## Local Development

For local testing, environment variables can be set temporarily.

For example:

```r
Sys.setenv(
  GOOGLE_SHEET_CONSUMPTION_URL = "your-private-url"
)

Sys.setenv(
  GOOGLE_SHEET_DROUGHT_URL = "your-private-url"
)
```

Do not commit these values.

A future improvement would be to maintain a local `.Renviron` file for development and add it to `.gitignore`.

Example:

```text
GOOGLE_SHEET_CONSUMPTION_URL=private_url_here
GOOGLE_SHEET_DROUGHT_URL=private_url_here
```

---

# How to Update the Dashboard

## Updating Dashboard Text

Edit:

```text
ui.R
```

Most public-facing text is written directly in the user interface.

After editing:

1. Run the dashboard locally.
2. Check the layout on desktop.
3. Check the layout on smaller screens/mobile.
4. Confirm that links work.

---

## Updating Visualizations

Most visualization logic is located in:

```text
server.R
```

Data preparation that must occur before the dashboard starts is generally located in:

```text
global.R
```

When updating a chart:

1. Identify the data object used by the chart.
2. Identify where that data object is created.
3. Update the chart code.
4. Run the application locally.
5. Test different filter and selection options.

---

## Updating Data Sources

For automatically refreshed datasets, edit:

```text
data_refresh.R
```

A new data source should generally follow this pattern:

```r
refresh_dataset(
  "dataset_name",
  function() {
    # Fetch and process data
  },
  function(df) {
    # Save data to cache
  }
)
```

Then load the cached file in:

```text
global.R
```

This keeps the application architecture consistent.

---

# Adding New Data Sources

When adding a new dataset, follow these steps.

## Step 1: Identify the source

Document:

* Organization providing the data
* URL
* API or download method
* Update frequency
* License or usage restrictions
* Important field names

---

## Step 2: Add the refresh logic

Add the download or API process to:

```text
data_refresh.R
```

Use the existing `refresh_dataset()` structure when possible.

---

## Step 3: Save to the cache

Save the processed dataset into:

```text
data/cache/
```

Use the existing helper functions when possible.

---

## Step 4: Load the dataset

Add the cached dataset to:

```text
global.R
```

Example:

```r
df_new_data <- read_cache_csv("df_new_data")
```

---

## Step 5: Create the visualization

Add:

* UI components to `ui.R`
* Server logic to `server.R`

---

## Step 6: Test failure scenarios

Before relying on a new data source, test what happens when:

* The source is unavailable.
* The API returns an error.
* The dataset contains no rows.
* Column names change.

The dashboard should ideally continue working with the previous successful dataset.

---

# Troubleshooting

## The Dashboard Starts but Data Looks Old

Check:

```text
data/cache/refresh_log.csv
```

Look for recent failures.

Then:

1. Run `data_refresh.R` manually.
2. Check which dataset failed.
3. Visit the original data source.
4. Check for API or website changes.

---

## The Dashboard Will Not Start

Check:

* Missing R packages
* Missing environment variables
* Missing cached files
* Incorrect file paths
* Changes to required data columns

Run the application from RStudio and review the console error.

---

## The Net Inflow Scraper Fails

The net inflow data is scraped from a dynamic Shiny website.

Check:

* Whether the website is available.
* Whether the `Data table` tab still exists.
* Whether the table structure has changed.
* Whether Chrome is available for `chromote`.

---

# Important Maintenance Notes

## Do Not Remove Cached Data Without a Backup

The cache allows the dashboard to continue functioning when live data sources fail.

Before clearing:

```text
data/cache/
```

create a backup.

---

## Keep Static and Dynamic Data Separate

Static reference data should remain in:

```text
data/
```

Automatically refreshed data should remain in:

```text
data/cache/
```

This separation is important for maintaining the project.

---

## Do Not Put Sensitive URLs in Public Code

Use:

* Environment variables
* GitHub Secrets
* Configuration files excluded through `.gitignore`

Never commit private spreadsheet URLs or credentials.

---

# Recommended Handover Checklist

When responsibility for this project is transferred to a new staff member, they should be provided with access to:

* [ ] The GitHub repository
* [ ] Posit Connect Cloud
* [ ] Google Sheets used for water consumption data
* [ ] Google Sheets used for historical drought data
* [ ] The insto dashboard group email
* [ ] Current dashboard URL https://tota-water-dashboard.share.connect.posit.cloud/
* [ ] Documentation for TOTA's INSTO reporting requirements


---

# Key Files at a Glance

| File                 | Purpose                                            |
| -------------------- | -------------------------------------------------- |
| `app.R`              | Starts the Shiny application                       |
| `global.R`           | Loads packages and datasets before the app starts  |
| `ui.R`               | Defines dashboard layout and public-facing content |
| `server.R`           | Contains interactive dashboard logic               |
| `data_refresh.R`     | Downloads and updates external datasets            |
| `R/data_helpers.R`   | Reusable data and cache helper functions           |
| `data/cache/`        | Automatically refreshed datasets                   |
| `data/`              | Static reference data                              |
| `www/`               | Images and other web assets                        |
| `.github/workflows/` | Automated scheduled refresh workflow               |

---

# Maintainer Notes

Avoid adding live API calls directly into `global.R`, `server.R`, or the user interface unless there is a strong reason to do so.

The goal is for the dashboard to remain reliable even when external data sources are temporarily unavailable.

---

