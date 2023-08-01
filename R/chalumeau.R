#' Reproduce Chalumeau analysis
#'
#' @param bc.exp Box-Cox exponent (see [boxCoxChord()]).
#' @param fwd.sel A logical. Should a forward selection be performed?
#'
#' @examples
#' res <- chalumeau()
#' ress <- res$rda |> summary()
#'
#' @export
chalumeau <- function(bc.exp = 0.25, fwd.sel = FALSE) {
    inputdata <- getData()
    form <- "matcom ~ ALTITUDE + TMA + PMA + HUMUS + HUMEPAI + FLAT_SLOPE + FORCPENT"
    output01 <- doRDA(inputdata$env, inputdata$spc, form, bc.exp, fwd.sel)
    output02 <- doKMeans(output01,
        max_grp = 30, km_method = "cascade",
        iter = 100, criterion = "ssi"
    )
    output03 <- doKMeans(output01,
        max_grp = 30, km_method = "cascade", iter = 100, criterion = "calinski"
    )
    output04 <- doKMeans(output01, max_grp = 30, km_method = "silhouette")
    return(
        list(
            data = inputdata,
            rda = output01,
            km_ssi = output02,
            km_cal = output03,
            km_sil = output04
        )
    )
}

#' @describeIn chalumeau Perform RDA.
#' @param env Environment data.
#' @param spc Species data.
#' @param rda_formula RDA formula. Default is set to `NULL`, which means that
#' all variables are used in the model.
doRDA <- function(env, spc, rda_formula = NULL, bc.exp = 1, fwd.sel = FALSE) {
    stopifnot(NROW(env) == NROW(spc))
    matcom <- spc |>
        boxCoxChord(bc.exp = bc.exp)

    cli_progress_step("Perform RDA")

    if (!is.null(rda_formula)) {
        res <- rda(as.formula(rda_formula), env)
    } else {
        res <- rda(matcom ~ ., env)
    }

    if (fwd.sel) {
        cli_progress_step("Perform forward selection")
        system.time({
            res <- ordiR2step(
                rda(matcom ~ 1, env),
                scope = formula(res), # upper model limit (the "full" model)
                direction = "forward",
                R2scope = TRUE, # can't surpass the "full" model's R2
                pstep = 100,
                trace = FALSE
            )
        })
    }

    return(res)
}


#' @describeIn chalumeau Perform K means.
#' @param res_rda RDA output.
#' @param naxis Number of axis.
#' @param max_grp maximum number of groups.
#' @param km_method K-means method.
#' @param ... Further argiments forwarded to [vegan::cascadeKM()].
doKMeans <- function(res_rda, naxis = 10, max_grp = 30,
                     km_method = c("cascade", "silhouette", "wss"), ...) {
    cli_progress_step("Perform Kmeans ({km_method})")
    scr <- scores(res_rda,
        choices = seq_len(naxis), scaling = 1,
        display = c("lc")
    )
    km_method <- match.arg(km_method)
    if (km_method == "cascade") {
        cascadeKM(scr, inf.gr = 2, sup.gr = max_grp, ...)
    } else if (km_method == "silhouette") {
        factoextra::fviz_nbclust(
            x = scr, FUNcluster = kmeans, method = "silhouette",
            k.max = max_grp
        )
    } else {
        factoextra::fviz_nbclust(
            x = scr, FUNcluster = kmeans, method = "wss", k.max = max_grp
        )
    }
}


#' @describeIn chalumeau Take raw data and return a list including all the data and the enviroenemtn data (scaled where needed) and the species data.
getData <- function() {
    cli_progress_step("Prepare data")
    on.exit(cli_progress_done())
    dat <- prepareData() |>
        filter(!PERTURB)
    #
    nms <- names(classEcoFor::species_var)
    nmy <- nms[!nms %in% c("CLE_ECO")]
    nmx <- names(dat)[!names(dat) %in% nmy]
    trs <- c("ALTITUDE", "FORCPENT", "PENTARRI", "HUMEPAI", "TMA", "PMA")
    spc <- dat[nmy]
    env <- dat[nmx] |>
        select(
            -c(
                "LONGITUDE", "LATITUDE", "PERTURB", "REG_ECOL", "CLE_ECOnum",
                "CLE_ECOcar", "CLE_ECO"
            )
        ) |>
        mutate(across(all_of(trs), scale))
    return(list(full = dat, env = env, spc = spc))
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
            by = join_by(CLE_ECO)
        ) |>
        # see line 161 in the original file
        left_join(
            classEcoFor::climatic_var,
            by = join_by(CLE_ECO)
        ) |>
        # this is the only situation value used in Chalumeau et al. 
        # we create an adhoc variable instead of including all SITUATION values
        mutate(FLAT_SLOPE = (SITUATION == 0) * 1) |>
        left_join(classEcoFor::species_var, by = join_by(CLE_ECO))
    # checking data
    idalt <- which(dat$ALTI != dat$ALTITUDE)
    idlat <- which(dat$LONGITUDE.x != dat$LONGITUDE.y)
    idlon <- which(dat$LATITUDE.x != dat$LATITUDE.y)
    idall <- unique(c(idlat, idlon, idalt))
    if (length(idall)) {
        cli_alert_warning(
            col_yellow("Removing {length(idall)} problematic entr{?y/ies}")
        )
        cli_alert_warning("Altitude:  {dat$CLE_ECO[idalt]}")
        cli_alert_warning("Latitude:  {dat$CLE_ECO[idlat]}")
        cli_alert_warning("Longitude: {dat$CLE_ECO[idlon]}")
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


# K-means from 12_Analyse_article:ALTI
# scores_sites_till_RDA_2 <- scores(RDA_2, choices = c(1:10),scaling=1, display = c("lc"))
# cascadeKM_till_RDA_2 <- cascadeKM(scores_sites_till_RDA_2, inf.gr = 2, sup.gr = 30, iter = 100, criterion = 'ssi')