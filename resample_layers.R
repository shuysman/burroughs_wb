library(tidyverse)
library(terra)

data_dir <- file.path("./data")

reference <- rast(file.path(data_dir, "burroughs_creek_USGS1m_clipped_nad83.tif"))

dayl <- rast(file.path(data_dir, "1980_dayl_na.nc4"))
dayl2 <- project(dayl, reference, method = "near")
dayl2 <- resample(dayl2, reference, method = "near")
dayl2 <- crop(dayl2, reference)

writeCDF(dayl2, file.path(data_dir, "1980_dayl_gye.nc4"), compression = 9)

t50 <- rast(file.path(data_dir, "merged_jennings2.tif"))
t50 <- project(subset(t50, 1), reference, method = "near")
t50 <- resample(t50, reference, method = "near")
t50 <- crop(t50, reference)

writeRaster(t50, file.path(data_dir, "jennings_t50_coefficients.tif"))
