library(terra)
library(glue)
library(parallel)

data_dir <- file.path("~/out/collated/")

files <- list.files(data_dir, full.names = TRUE)

check_files <- function(file) {
    r <- rast(file)

    if (length(names(r)) < 365) {
        return(glue("File incorrect length: {f}"))
    } else {
        return(1)
    }
}

mclapply(files, check_files, mc.cores = 6)
