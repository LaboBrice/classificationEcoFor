#' Climatic variables
#'
#' @format A data frame with 12,732 rows and 20 columns
#'
"climatic_var"

#' Environment variables
#'
#' @format A data frame with 8,581 rows and 19 columns
#'
"environ_var"

#' A dataset containing plot locations.
#'
#' @format A sf object with 12,731 points and 6 fields (columns):
#' * ``CLE_ECO`:
#' * ``LONGITUDE`:
#' * ``LATITUDE`:
#' * ``wc20bio30s0`:
#' * ``wc20bio30s1`:
#' * ``TMA`: Mean annual temperature
#'
"plot_location"

#' Species abundances
#'
#' @format A data frame with 8,581 rows and 252 columns (251 species +
#' CLE_ECOcar).
#'
"species_var"

#' Species codes
#'
#' @format A data frame with 326rows and 4 columns
#' * `code`: species code (3 letters)
#' * `francais`: french name
#' * `latin`: latin name
#' * `strate`
"species_codes"

#' Biological domains
#'
#' @format A sf object with 6 domains and 8 columns.
#' @references
#' <https://www.donneesquebec.ca/recherche/fr/dataset/systeme-hierarchique-de-classification-ecologique-du-territoire>
"domain_bio"

#' Conversion table for deposit groups
#'
#' @format A data frame with 3 and 104 rows
#' * `code`: species code (3 letters)
#' * `group`: group name
#' * `frequency`: frequency in POE data
#' @references
#' <https://www.donneesquebec.ca/recherche/dataset/points-observation-ecologique/resource/f21dfb59-cf61-4c59-a051-b16435c58c15>,
#' groups by Pierre Grondin
"deposits"

#' POE 
#' 
#' Point d'observation \u00e9cologique.
#'
#' @format A sf object with 28398 points and 43 columns.
#' @references
#' * <https://www.donneesquebec.ca/recherche/dataset/points-observation-ecologique/resource/f21dfb59-cf61-4c59-a051-b16435c58c15>, we used the layer `vue_pe_type_eco`.
"poe_type_eco"

#' POE Environment variables
#'
#'
#' @format A sf object with 28398 points and 9 fields:
#' * id_poe: POE identifier
#' * elevation: elevation
#' * slope_type: slope type, one among the following values
#'   + 0: plat
#'   + 2: escarpement
#'   + 3: sommet
#'   + 4: haut_pente
#'   + 5: mi_pente
#'   + 6: replat
#'   + 7: bas_pente
#'   + 8: depression_o
#'   + 9: depression_f
#' * humus_type: humus type, one among the following values
#'   + MR
#'   + SO
#'   + TO
#'   + MD
#'   + MS
#'   + NA
#'   + MU
#'   + AN
#' * mo_thickness: organic matter thickness
#' * deposit_type: deposit type (10)
#' * deposit_group: deposit group
#' * mean_pcp: mean annual precipitation (averaged over 1990-1999)
#' * mean_temp: mean annual temperature (averaged over 1990-1999)
#' * potential_vegetation: potential natural vegetation
#' @references
#' * POE data: <https://www.donneesquebec.ca/recherche/dataset/points-observation-ecologique/resource/f21dfb59-cf61-4c59-a051-b16435c58c15>
#' * Temperature and precipitation data: McKenney, Daniel W., Michael F. Hutchinson, Pia Papadopol, Kevin Lawrence, John Pedlar, Kathy Campbell, Ewa Milewska, Ron F. Hopkinson, David Price, and Tim Owen. “Customized Spatial Climate Models for North America.” Bulletin of the American Meteorological Society 92, no. 12 (December 2011): 1611–22. https://doi.org/10.1175/2011BAMS3132.1.
"poe_env"


#' POE species variables
#'
#' @format A data frame with 28396 rows and 357 columns. The first column is
#' the POE identifier (`id_poe`) and the rest of the columns are the species
#' coverages expressed as a percentage (that can be greater than 100%), the
#' column names are the species three-letters code.
#' 
"poe_species"
