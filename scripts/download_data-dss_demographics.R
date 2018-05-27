
#' This script will download DSS Payments data from `data.gov.au`
#' 
#' https://data.gov.au/dataset/dss-payment-demographic-data
#' 


# Packages ----------------------------------------------------------------

library(tidyverse)
library(glue)
library(stringr)
library(httr)

# Global vars -------------------------------------------------------------

#' Data comes from sources at `https://data.gov.au`, which can be accessed via
#' an API.

#' The root of the API URL
#' Docs are here: http://docs.ckan.org/en/latest/api/
#' Actual root is `https://data.gov.au/api/3`, followed by `action` (as per the
#' docs)
#' 
api_root <- "https://data.gov.au/api/3/action"

#' Into which directory should files be downloaded?
data_dir <- "data/dss_demographics"


# Browse full data set list -----------------------------------------------

# This section browses the full list of packages, serving an exploratory purpose

#' response  <- GET(file.path(api_root, "package_list"))
#' data_sets <- content(response)$result %>% unlist()
#' data_sets
#' 
#' #' Articles containing `demographic`?
#' data_sets[str_detect(data_sets, "demographic")]
#' 
#' #' We got `"dss-payment-demographic-data"`
#' 


# Downloading DSS Payment data --------------------------------------------

#' Get meta-data about the whole package
response <- GET(file.path(api_root, "package_show?id=dss-payment-demographic-data"))
package_datasets <- content(response, "parsed")$result

#' Get names (titles) of the package datasets:
dataset_names <- map_chr(package_datasets$resources, "name")

#' We want datasets described as `"DSS Demographics <Month> <Year>"`
dss_datasets <- package_datasets$resources[str_detect(dataset_names, "^DSS Demographics")]

#' Download all files into a `data` directory
dir.create(data_dir)
for (ds in dss_datasets) {
  
  #' Convert name to `<month>-<year>`
  file_name <- ds$name %>% 
    tolower() %>% 
    str_remove("dss demographics") %>% 
    str_trim() %>%
    str_replace_all(" ", "-")
  
  download.file(url = glue("https://data.gov.au/dataset/{package_datasets$id}/resource/{ds$id}/download/{file_name}.xlsx"),
                destfile = glue("{data_dir}/{file_name}.xlsx"),
                mode = "wb")
}
