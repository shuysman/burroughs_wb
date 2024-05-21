library(terra)
library(glue)
library(reticulate)
library(tidyverse)
library(tidyterra)

np <- import("numpy")

input_data_dir <- file.path("/home/steve/OneDrive/nps-wb/data/")

year <- 1979
var <- "soil_water"

reference <- rast(file.path(input_data_dir, "1980_dayl_gye.nc4"))

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

output_rast <- writeCDF(output_rast, filename = "/tmp/test.nc", overwrite = TRUE)

wb_files <- list.files("/home/steve/out/wb/", pattern = glue("{year}_.*_{var}.npz"), full.names = TRUE) |> str_sort(numeric = TRUE)

for (f in wb_files[100:150]) {
    print(f)
    npz <- np$load(f)

    new_rast <- rast(npz$f[['param']],
                     crs = crs(reference),
                     extent = ext(reference))

    output_rast <- c(output_rast, new_rast)
}

##time(output_rast) <- time(reference)

##test_ext <- c(606336, 607500, 4839876, 4840600)


shade <- rast("/home/steve/OneDrive/burroughs_wb/data/burroughs_creek_USGS1m_clipped_hillshade_nad83.tif")

autoplot(shade)

pal_greys <- hcl.colors(1000, "Grays")

ggplot() +
    geom_spatraster(data = shade) +
##    geom_spatraster(data = subset(tmmn$daily_minimum_temperature, 1)) +
    scale_fill_gradientn(colors = pal_greys, na.value = NA)

r <- output_rast %>%
    subset(1,9999) %>%
    ##crop(test_ext) %>%
    clamp(lower = 0, values = FALSE) %>%
    mean()

ggplot() +
    geom_spatraster(data = shade) +
##    geom_spatraster(data = subset(tmmn$daily_minimum_temperature, 1)) +
    scale_fill_gradientn(colors = pal_greys, na.value = NA) +
    ggnewscale::new_scale_fill() +
    geom_spatraster(data = r, alpha = 0.5) +
    scale_fill_viridis_c(option = "A")
