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
#' * ``TMA`: Temperature annuelle moyenne
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

#' POE 
#' 
#' Point d'observation \u00e9cologique.
#'
#' @format A sf object with 28398 points and 43 columns.
#' @references
#' * <https://www.donneesquebec.ca/recherche/dataset/points-observation-ecologique/resource/f21dfb59-cf61-4c59-a051-b16435c58c15>, we used the layer `vue_pe_type_eco`.
"poe_type_eco"