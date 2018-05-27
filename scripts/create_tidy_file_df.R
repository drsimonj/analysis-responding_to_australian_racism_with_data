#'
#' Data is stored in messy excel files. This script will get the file names and
#' proper date labels in a tidy data frame, saved for future use
#' 

# Packages ----------------------------------------------------------------

library(tidyverse)

# Tidy data ---------------------------------------------------------------

# Get file list into tidy & ordered data frame
dss_files <- tibble(xlsx_path = file.path("data/dss_demographics", list.files("data/dss_demographics"))) %>% 
  separate(xlsx_path, int = c("month_name", "year", "extension"), remove = FALSE, sep = "[-\\.]") %>% 
  transmute(year = as.integer(year),
                   month = map_int(month_name, stringr::str_which, tolower(month.name)),
                   xlsx_path) %>% 
  arrange(year, month)

#' Remember that it's easy to convert month integers to names with these
#' built-in objects:
#'
#' `month.abb`
#' `month.name`
#' 

write_rds(dss_files, "data/dss_files.rds")
