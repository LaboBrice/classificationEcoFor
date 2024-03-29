# Same as poe_kmean_by_dir but for a subgourp (a filter)
devtools::load_all()
library(dplyr)
library(corrplot)
library(ggplot2)


analyse_sub_group <- function(subgroup = "2Bs", isDepositType = FALSE) {
  fld0 <- file.path("tmp", sprintf("res_%s", tolower(subgroup)))
  dir.create(fld0, recursive = TRUE, showWarnings = FALSE)

  spc_nm <- names(poe_species |> dplyr::select(-id_poe))
  # Remove "FEU_R" "FEU_H" "RES_S" "FEU_S" "CLA_S"
  spc_nm <- spc_nm[nchar(spc_nm) == 3]
  var_nm <- names(poe_env)[!names(poe_env) %in% c("id_poe", "geom", "deposit_type", "deposit_group", "potential_vegetation")]

  poe <- inner_join(poe_env, poe_species) |>
    sf::st_drop_geometry() |>
    as.data.frame() |>
    na.omit() |>
    mutate(slope_type = as.factor(slope_type)) |>
    mutate(humus_type = as.factor(humus_type))
  if (isDepositType) {
    poe <- poe |>
      filter(deposit_type == subgroup)
  } else {
    poe <- poe |>
      filter(deposit_group == subgroup)
  }


  res_rda3 <- doRDA(poe[var_nm], poe[spc_nm])
  png(file.path(fld0, "rda_triplot.png"),
    units = "in", height = 8,
    width = 8, res = 300
  )
  triplot_rda(res_rda3, xlim = c(-1, 1), ylim = c(-1, 1))
  dev.off()

  res_kmean <- doKMeans(res_rda3,
    max_grp = 40, km_method = "cascade", iter = 100, criterion = "calinski"
  )
  saveRDS(res_kmean, file = file.path(fld0, "res_kmean_sub.rds"))

  poe_env_groups <- cbind(poe, res_kmean$partition |> as.data.frame())

  # Fifty first species
  cov_spc <- poe_species |>
    select(-id_poe) |>
    apply(2, mean) |>
    sort() |>
    rev()
  spc_nm_50 <- names(cov_spc)[nchar(names(cov_spc)) == 3][1:50]


  for (j in 2:30) {
    cat("----------------> group ", j, "\n")

    fld <- file.path(fld0, sprintf("kmean%02d", j))
    dir.create(fld, recursive = TRUE, showWarnings = FALSE)

    vr_gp <- paste0(j, " groups")
    tmp <- poe_env_groups[c("id_poe", vr_gp)] |>
      dplyr::rename(grp = vr_gp)
    geom_grp <- dplyr::inner_join(poe_env, tmp)

    # K-mean groups vs végétation potentielle
    png(file.path(fld, sprintf("plot_%02dgroups_vs_vegpot.png", j)),
      units = "in",
      height = 10, width = 15, res = 300
    )
    table(poe_env_groups$potential_vegetation, poe_env_groups[, vr_gp]) |> corrplot(
      is.corr = FALSE,
      mar = c(2, 1, 2, 1),
      number.cex = 0.75,
      cl.cex = 1.1,
      cl.ratio = 2.4 / (j),
      addCoef.col = "black",
      cl.align.text = "l",
      title = "Groupe de k-mean vs couverture des espèce"
    )
    dev.off()

    # K-mean groups vs végétation potentielle
    png(file.path(fld, sprintf("plot_%02dgroups_vs_couverture50.png", j)),
      units = "in",
      height = 18, width = 15, res = 300
    )
    poe_env_groups |>
      dplyr::select(c(all_of(spc_nm_50), vr_gp)) |>
      group_by(!!sym(vr_gp)) |>
      summarise_at(all_of(spc_nm_50), \(x) round(mean(x), 2)) |>
      dplyr::select(-all_of(vr_gp)) |>
      t() |>
      corrplot(
        is.corr = FALSE,
        mar = c(2, 1, 2, 1),
        number.cex = 0.75,
        cl.cex = 1.1,
        cl.ratio = 2.4 / (j),
        addCoef.col = "black",
        cl.align.text = "l",
        title = "Groupe de k-mean vs couverture des espèces"
      )
    dev.off()

    # var env plots
    var_qtt <- c("mo_thickness", "mean_pcp", "mean_temp", "elevation")
    titl <- c(
      "Épaisseur de matière organique",
      "Précipitaions moyennes annuelles",
      "Température moyenne annuelle",
      "Altitude"
    )
    dat <- poe_env_groups |>
      dplyr::select(all_of(var_qtt), vr_gp)
    for (i in seq(var_qtt)) {
      ggplot(dat, aes(x = !!sym(vr_gp), y = !!sym(var_qtt[i]), group = !!sym(vr_gp))) +
        geom_boxplot(aes(fill = !!sym(vr_gp))) +
        ylab(titl[i]) +
        xlab("Groupes")
      ggsave(file.path(fld, sprintf("plotenv_group%02d_%s.png", j, var_qtt[i])))
    }

    var_qlt <- c("slope_type", "deposit_group")
    titl <- c("Type de pente", "Type de dépôt surfacique")
    dat <- poe_env_groups |>
      dplyr::select(all_of(var_qlt), vr_gp)
    for (i in seq(var_qlt)) {
      dat |>
        group_by(!!sym(vr_gp), !!sym(var_qlt[i])) |>
        summarize(count = n()) |>
        ggplot(aes(x = !!sym(vr_gp), y = count, fill = !!sym(var_qlt[i]))) +
        geom_bar(position = "fill", stat = "identity") +
        ylab(titl[i]) +
        xlab("Groupes")
      ggsave(file.path(fld, sprintf("plotenv_group%02d_%s.png", j, var_qlt[i])))
    }

    for (i in seq(1, j)) {
      png(file.path(fld, sprintf("detail_group_%02d.png", i)),
        units = "in",
        height = 8, width = 16, res = 300
      )
      layout(matrix(c(1, 2), ncol = 2), widths = c(0.45, 0.55))
      par(mar = c(4, 4, 1, 1))
      compo <- poe_env_groups |>
        filter(!!sym(vr_gp) == i) |>
        dplyr::select(c(all_of(spc_nm), vr_gp)) |>
        group_by(!!sym(vr_gp)) |>
        summarise_at(all_of(spc_nm), mean) |>
        dplyr::select(-all_of(vr_gp)) |>
        as.vector() |>
        unlist() |>
        sort() |>
        rev()
      plot(compo[1:20],
        type = "h", lwd = 5, axes = FALSE, lend = 1,
        ylab = "Recouvrement moyen", xlab = ""
      )
      mtext(paste0("groupe ", i, "/", j), 3, line = -2, cex = 2)
      axis(2, las = 2)
      axis(1, at = 1:20, labels = names(compo[1:20]), las = 2)
      box(bty = "l")

      par(mar = c(0, 0, 1, 1))
      plot(domain_bio |> sf::st_geometry())
      plot(
        geom_grp |>
          dplyr::filter(grp == i) |>
          sf::st_geometry(),
        add = TRUE,
        pch = 19,
        col = "steelblue",
        cex = 0.7
      )

      dev.off()
    }
  }
}


analyse_sub_group()
analyse_sub_group("2B", isDepositType = TRUE)