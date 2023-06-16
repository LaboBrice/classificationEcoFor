#' Reproduce Chalumeau analysis
#'
#' @param bc.exp Box-Cox exponent (see [boxCoxChord()]).
#'
#' @export
chalumeau <- function(bc.exp = 1) {
    cli_progress_step("Prepare data")
    dat <- prepareData() |>
        filter(!PERTURB)
    #
    nms <- names(classEcoFor::species_var)
    nmy <- nms[!nms %in% c("CLE_ECOcar")]
    nmx <- names(dat)[!names(dat) %in% nmy]
    trs <- c("ALTITUDE", "FORCPENT", "PENTARRI", "HUMEPAI", "TMA", "PMA")
    spc <- dat[nmy]
    env <- dat[nmx] |>
        select(
            -c(
                "CLE_ECOnum", "CLE_ECOcar", "LONGITUDE", "LATITUDE",
                "PERTURB", "REG_ECOL"
            )
        ) |>
        mutate(across(all_of(trs), scale))
    maty <- spc |> boxCoxChord(bc.exp = bc.exp)

    cli_progress_step("Perform RDA")

    return(list(
        data = list(full = dat, env = env, maty = maty),
        rda = rda(maty, env)
    ))
}

prepareData <- function() {
    dat <- classEcoFor::environ_var |>
        # see lines 80 in the original file
        mutate(DR = dr1 + 2 * dr2 + 3 * dr3 + 4 * dr4 + 5 * dr5 + 6 * dr6) |>
        select(-c(dr1, dr2, dr3, dr4, dr5, dr6)) |>
        # see lines 115 in the original file
        mutate(PERTURB = O_BR | O_CT | O_ES | O_FR | O_HT | O_P) |>
        select(-c(O_BR, O_CT, O_ES, O_FR, O_HT, O_P)) |>
        left_join(
            classEcoFor::plot_location |> sf::st_drop_geometry(),
            by = join_by(CLE_ECOcar == CLE_ECO)
        ) |>
        # convert to integer to join
        mutate(CLE_ECOcar = as.integer(CLE_ECOcar)) |>
        # see line 161 in the original file
        left_join(
            classEcoFor::climatic_var,
            by = join_by(CLE_ECOcar == CLE_ECO)
        ) |>
        left_join(classEcoFor::species_var, by = join_by(CLE_ECOcar))
    # checking data
    idalt <- which(dat$ALTI != dat$ALTITUDE)
    idlat <- which(dat$LONGITUDE.x != dat$LONGITUDE.y)
    idlon <- which(dat$LATITUDE.x != dat$LATITUDE.y)
    idall <- unique(c(idlat, idlon, idalt))
    if (length(idall)) {
        cli_alert_warning(
            col_yellow("Removing {length(idall)} problematic entr{?y/ies}")
        )
        cli_alert_warning("Altitude:  {dat$CLE_ECOcar[idalt]}")
        cli_alert_warning("Latitude:  {dat$CLE_ECOcar[idlat]}")
        cli_alert_warning("Longitude: {dat$CLE_ECOcar[idlon]}")
        dat <- dat[-idall]
    }
    dat <- dat |>
        select(-c("ALTI", "LONGITUDE.y", "LATITUDE.y")) |>
        rename("LONGITUDE" = "LONGITUDE.x", "LATITUDE" = "LATITUDE.x")

    return(dat)
}


# notes/todo
## - CLE_ECOnum & CLE_ECOcar identical but the type (num vs int)
## - line 131: rm perturbated plots
## - lines 169: selection of columns?
## - line 217-265 not needed, should be re-leveled in the analysis directly
## if needed, use `tidyr::pivot_wider(names_from = EXPOSITION, values_from = EXPOSITION, values_fill = 0, names_prefix = "exp_", values_fn = \(x) ifelse(x != 0, 1, 0))`
