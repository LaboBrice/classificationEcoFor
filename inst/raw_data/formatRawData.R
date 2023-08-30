# Initial data clean (use raw data and include data directly in the package)
# Note CLE_ECO will be the key use and will be of type integer
# Plots
plot_location <- sf::read_sf(
    "inst/raw_data/placette_localisation_select_sept2019_wgs84_bon_clim1.shp",
    stringsAsFactors = FALSE
) |>
    # see line 172 in the original file
    dplyr::select(-TMA) |>
    dplyr::mutate(CLE_ECO = as.integer(CLE_ECO)) |>
    dplyr::rename(TMA = wc20bio30s0, PMA = wc20bio30s1)
save(plot_location, file = "data/placette_localisation.rda")

# Environmemt
environ_var <- foreign::read.dbf("inst/raw_data/env.dbf") |>
    dplyr::mutate(CLE_ECOcar = as.character(CLE_ECOcar)) |>
    dplyr::mutate(CLE_ECO = as.integer(CLE_ECOcar))
save(environ_var, file = "data/environ_var.rda")

# Species
## - CLE_ECOnum & CLE_ECOcar are identical but have different type (num vs int)
## only the latter is used in the code for joins so I convert the latter and
## drop the former.
species_var <- foreign::read.dbf("inst/raw_data/esp.dbf", as.is = TRUE) |>
    dplyr::mutate(CLE_ECOcar = as.character(CLE_ECOcar)) |>
    dplyr::mutate(CLE_ECO = as.integer(CLE_ECOcar)) |>
    dplyr::select(-c("CLE_ECOnum", "CLE_ECOcar"))

save(species_var, file = "data/species_var.rda")

species_codes <- read.csv("inst/raw_data/species_codes.csv")
save(species_codes, file = "data/species_codes.rda")


# Climatic variables (var_Mathieu)
## NB: redundant variables  (see environ vars) are removed
climatic_var <- read.csv("inst/raw_data/var_clim.csv") |>
    dplyr::select(-c("FORCE_PENT", "PENT_ARRI", "HUMUS_EPAI")) |>
    dplyr::mutate(CLE_ECO = as.integer(CLE_ECO))
save(climatic_var, file = "data/climatic_var.rda")


# Conversion table for deposits
## grouping by Pierre Grondin
deposits <- read.csv("inst/raw_data/depot_surface_groupes.csv")
names(deposits) <- c("code", "group", "frequency")
save(deposits, file = "data/deposits.rda", compress = "xz")


# POE data including only the variables needed + temperature + precipitation
sf::st_layers("inst/raw_data/POE_PROV.gpkg")

topo <- sf::st_read("inst/raw_data/POE_PROV.gpkg",
    layer = "vue_pe_topographie"
) |>
    dplyr::select(id_poe, altitude, situapente)

humu <- sf::st_read(
    "inst/raw_data/POE_PROV.gpkg",
    layer = "vue_pe_sol_caract"
) |>
    dplyr::select(id_poe, typehumus, epmatorg) |>
    sf::st_drop_geometry() |>
    as.data.frame()

depot <- sf::st_read(
    "inst/raw_data/POE_PROV.gpkg",
    layer = "vue_pe_depot_drainage"
) |>
    dplyr::select(id_poe, dep_sur) |>
    sf::st_drop_geometry() |>
    as.data.frame() |>
    dplyr::inner_join(
        deposits |> dplyr::select(code, group),
        by = dplyr::join_by(dep_sur == code)
    )

# vue_pe_classi_eco
classif <- sf::st_read("inst/raw_data/POE_PROV.gpkg",
    layer = "type_ecologique"
) |>
    dplyr::select(id_poe, veg_pot) |>
    sf::st_drop_geometry() |>
    as.data.frame()

poe <- dplyr::inner_join(topo, humu) |>
    dplyr::inner_join(depot) |>
    dplyr::inner_join(classif)

## Add temperature and precipitation data
can <- geodata::gadm(country = "CAN", level = 1, path = "inst/raw_data")
qc <- can[can$NAME_1 == "Québec", ]
##
## For the meanings of bio data see https://cfs.nrcan.gc.ca/projects/3/8
temp_an_can <- terra::rast(
    sprintf("inst/raw_data/mly60arcsecond_1990to1999/199%d/bio60_01.tif", 1:9)
) |>
    terra::app(mean)
temp_an_qc <- temp_an_can |>
    terra::crop(terra::project(qc, temp_an_can))
##
pcp_an_can <- terra::rast(
    sprintf("inst/raw_data/mly60arcsecond_1990to1999/199%d/bio60_12.tif", 1:9)
) |>
    terra::app(mean)
pcp_an_qc <- pcp_an_can |>
    terra::crop(terra::project(qc, pcp_an_can))

poe$mean_pcp <- terra::extract(pcp_an_qc, terra::project(terra::vect(poe), pcp_an_qc))$mean
poe$mean_temp <- terra::extract(temp_an_qc, terra::project(terra::vect(poe), temp_an_qc))$mean

poe_env <- poe |>
    dplyr::mutate(elevation = as.numeric(altitude)) |>
    dplyr::select(-altitude) |>
    dplyr::rename(slope_type = situapente) |>
    dplyr::rename(humus_type = typehumus) |>
    dplyr::rename(mo_thickness = epmatorg) |>
    dplyr::rename(deposit_type = dep_sur) |>
    dplyr::rename(deposit_group = group) |>
    dplyr::rename(potential_vegetation = veg_pot)

save(poe_env, file = "data/poe_env.rda", compress = "xz")


poe_species <- sf::st_read("inst/raw_data/POE_PROV.gpkg",
    layer = "vue_pe_espece_tot"
) |>
    tidyr::pivot_wider(
        names_from = "espece", values_from = "rec", values_fill = 0
    ) |>
    dplyr::select(-c(
        "no_prj", "no_viree", "no_poe", "id_viree", "chainage",
        "feuillet", "latitude", "longitude", "date_sond"
    )) |>
    sf::st_drop_geometry() |>
    as.data.frame()
save(poe_species, file = "data/poe_species", compress = "xz")
