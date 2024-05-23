library(terra)
library(glue)
library(hash)
library(reticulate)
library(tidyverse)
library(parallel)

terraOptions(verbose = TRUE)

### Output from start_wb_v_1_5.py script is a bunch of npz files,
### one for each day/year/model/scenario.  Import python numpy library
### to read in these files as arrays then work with r spatial libraries
### to georeference and collate them into netCDFs.
np <- import("numpy")

script_data_dir <- file.path("./data/")
input_data_dir <- file.path("~/out/wb/")
output_data_dir <- file.path("~/out/collated/")
reference <- rast(file.path(script_data_dir, "1980_dayl_gye.nc4"))

years <- 1979:2022 ## 2023 data is incomplete
var_units <- hash('soil_water' = "mm * 10",
                  'PET' = "mm * 10",
                  'AET' = "mm * 10",
                  'Deficit' = "mm * 10",
                  'runoff' = "mm * 10",
                  'agdd' = "GDD",
                  'accumswe' = "mm * 10",
                  'rain' = "mm * 10")
## year <- 1995
## var <- "Deficit"

models <- c(
    "bcc-csm1-1-m",
    "bcc-csm1-1",
    "BNU-ESM",
    "CanESM2",
    "CNRM-CM5",
    "CSIRO-Mk3-6-0",
    "GFDL-ESM2G",
    "GFDL-ESM2M",
    "HadGEM2-CC365",
    "HadGEM2-ES365",
    "inmcm4",
    "IPSL-CM5A-LR",
    "IPSL-CM5A-MR",
    "IPSL-CM5B-LR",
    "MIROC5",
    "MIROC-ESM-CHEM",
    "MIROC-ESM",
    "MRI-CGCM3",
    "NorESM1-M"
)
scenarios <- c('rcp85', 'rcp45')

## models <- c("historical")
## scenarios <- c("gridmet")

make_spatraster <- function(f, var, year) {
    ### Takes a filename f for a npz file generated from start_wb_v_1_5.py and
    ### creates a SpatRaster with crs and extent set from the reference
    ### and date properly set
    yday <- str_split_i(f, pattern = "_", i = 2) %>% as.numeric() + 1
    date <- as_date(glue("{year}-{yday}"), format = "%Y-%j")
    
    npz <- np$load(f)
    
    new_rast <- rast(npz$f[['param']],
                     crs = crs(reference),
                     extent = ext(reference))
    time(new_rast) <- date
    names(new_rast) <- var
    units(new_rast) <- var_units[[var]]

    return(new_rast)
}


make_collation <- function(options) {
    var <- options[1]
    year <- options[2]
    model <- options[3]
    scenario <- options[4]
    
    out_file = file.path(output_data_dir, glue("{var}_{year}_historical_gridmet_burroughs.nc"))
    print(out_file)
    
    output_rast <- rast(nrows = nrow(reference),
                        ncols = ncol(reference),
                        ## xmin = xmin(reference),
                        ## xmax = xmax(reference),
                        ## ymin = ymin(reference),
                        ## ymax = ymax(reference),
                        crs = crs(reference),
                        extent = ext(reference),
                        resolution = res(reference),
                        )

    ##writeCDF(output_rast, filename = out_file, overwrite = TRUE)

    wb_files <- list.files(input_data_dir, pattern = glue("{year}_.*_{var}.npz"), full.names = TRUE) |> str_sort(numeric = TRUE)

    for (f in wb_files) {
        print(f)
        new_rast <- make_spatraster(f, var, year)
        add(output_rast) <-  new_rast
        file.remove(f)
    }

    writeCDF(output_rast, filename = out_file, overwrite = TRUE, compression = 3)

    ##rm(output_rast)
    return(1)
}


options <- expand.grid(var = keys(var_units), year = years, model = models, scenario = scenarios) %>%
    t() %>%
    data.frame()

mclapply(options,
         FUN = make_collation,
         mc.cores = 8) ## Seems like I only have enough RAM to run 1 of these at a time, the writeCDF stage takes up ~80G

## for (option in options) {
##     make_collation(option)
## }
