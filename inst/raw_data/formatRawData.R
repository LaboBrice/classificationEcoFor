# Placette
plot_location <- sf::read_sf("inst/raw_data/placette_localisation_select_sept2019_wgs84_bon_clim1.shp") |>
    # see line 172 in the original file
    dplyr::select(-TMA) |>
    dplyr::rename(TMA = wc20bio30s0, PMA = wc20bio30s1)
save(plot_location, file = "data/placette_localisation.rda")

# Environmemt
environ_var <- foreign::read.dbf("inst/raw_data/env.dbf") 
save(environ_var, file = "data/environ_var.rda")

# Species
## - CLE_ECOnum & CLE_ECOcar are identical but have different type (num vs int)
## only the latter is used in the code for joins so I convert the latter and
## drop the former.
species_var <- foreign::read.dbf("inst/raw_data/esp.dbf", as.is = TRUE) |>
    dplyr::mutate(CLE_ECOcar = as.numeric(CLE_ECOcar)) |>
    dplyr::select(-c("CLE_ECOnum"))

save(species_var, file = "data/species_var.rda")

species_codes <- read.csv("inst/raw_data/species_codes.csv")
save(species_codes, file = "data/species_codes.rda")


# Climatic variables (var_Mathieu)
## NB: redundant variables  (see environ vars) are removed
climatic_var <- read.csv("inst/raw_data/var_clim.csv") |>
    dplyr::select(-c("FORCE_PENT", "PENT_ARRI", "HUMUS_EPAI"))
save(climatic_var, file = "data/climatic_var.rda")