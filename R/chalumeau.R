prepareData <- function() {
    envar <- classEcoFor::environ_var |>
        mutate(dr = dr1 + 2 * dr2 + 3 * dr3 + 4 * dr4 + 5 * dr5 + 6 * dr6) |>
        mutate(perturb = O_BR | O_CT | O_ES | O_FR | O_HT | O_P) |>
        left_join(
            classEcoFor::plot_location |> sf::st_drop_geometry(),
            by = join_by(CLE_ECOcar == CLE_ECO)
        ) |>
        mutate(CLE_ECOcar = as.integer(CLE_ECOcar)) |>
        left_join(
            classEcoFor::climatic_var,
            by = join_by(CLE_ECOcar == CLE_ECO)
        ) |>
        left_join(
            classEcoFor::species_var,
            by = join_by(CLE_ECOcar)
        )
    return(envar)
}