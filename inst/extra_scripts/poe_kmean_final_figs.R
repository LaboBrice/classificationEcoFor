# See vignette
devtools::load_all()
library(dplyr)
library(corrplot)
library(ggplot2)

# initialiser le générateur de nombres aléatoires avec une valeur spécifique
# permettra d'obtenir toujours les mêmes résultats du kmeans
set.seed(123)

dir.create("res_final", showWarnings = FALSE, recursive = TRUE)

# define k min and max
mink <- 20
maxk <- 24

# Prep data
spc_nm <- names(poe_species |> dplyr::select(-id_poe))
## Remove "FEU_R" "FEU_H" "RES_S" "FEU_S" "CLA_S"
spc_nm <- spc_nm[nchar(spc_nm) == 3]
var_nm <- names(poe_env)[!names(poe_env) %in% c("id_poe", "geom", "deposit_type", "potential_vegetation")]
poe <- inner_join(poe_env, poe_species) |>
  sf::st_drop_geometry() |>
  as.data.frame() |>
  na.omit() |>
  mutate(slope_type = as.factor(slope_type)) |>
  mutate(humus_type = as.factor(humus_type)) |>
  mutate(deposit_group = as.factor(deposit_group))

# Perform RDA
res_rda3 <- doRDA(poe[var_nm], poe[spc_nm])

# Save RDA scores
dir.create("res_final/RDA_scores", recursive = TRUE, showWarnings = FALSE)
sc_sp <- scores(res_rda3, display = "species", choices = c(1, 2))
write.csv(sc_sp,
  file = "res_final/RDA_scores/species_RDA_scores.csv",
  row.names = TRUE
)
sc_bp <- scores(res_rda3, display = "bp", choices = c(1, 2))
write.csv(sc_bp,
  file = "res_final/RDA_scores/var_RDA_scores.csv",
  row.names = TRUE
)
sc_si <- scores(res_rda3, display = "sites", choices = c(1, 2))
write.csv(sc_bp,
  file = "res_final/RDA_scores/var_RDA_scores.csv",
  row.names = TRUE
)

# Perform cascade K-means k = mink to maxk
res_kmean <- doKMeans(res_rda3,
  min_grp = mink,
  max_grp = maxk,
  km_method = "cascade",
  iter = 100,
  criterion = "calinski"
)
saveRDS(res_kmean, file = "res_final/res_kmean.rds")


# Generate RDA plots
for (j in mink:maxk) {
  cli::cli_alert_info("j = {j}")
  fld <- sprintf("res_final/kmean%02d", j)
  dir.create(fld, recursive = TRUE, showWarnings = FALSE)

  sc <- scores(res_rda3,
    choices = seq_len(10), scaling = 1, display = c("lc")
  )
  vr_gp <- paste0(j, " groups")
  # compute centroid coordinates (mean of POE coordinates in each group)
  tmp <- cbind(
    sc,
    res_kmean$partition |> as.data.frame() |> select(!!sym(vr_gp))
  ) |>
    as.data.frame() |>
    group_by(!!sym(vr_gp)) |>
    summarise_all(mean)
  # write centroids coordinates
  write.csv(
    tmp,
    sprintf("res_final/RDA_scores/kmean_centroids%02d.csv", j),
    row.names = FALSE
  )
  png(file.path(fld, sprintf("plot_rda_group%02d.png", j)),
    units = "in",
    height = 18, width = 15, res = 300
  )
  triplot_rda(res_rda3, sites = FALSE)
  text(tmp$RDA1 * 25, tmp$RDA2 * 25, seq_len(j), cex = 1.6, col = "#81bc1a", pch = 17)
  dev.off()
}


#
poe_env_groups <- cbind(poe, res_kmean$partition |> as.data.frame())
# save id_poe x kmeans_group
cbind(poe[1], res_kmean$partition) |>
  as.data.frame() |>
  write.csv("res_final/id_poe_kmeans_groups.csv")


# Fifty first species
cov_spc <- poe_species |>
  select(-id_poe) |>
  apply(2, mean) |>
  sort() |>
  rev()
spc_nm_50 <- names(cov_spc)[nchar(names(cov_spc)) == 3][1:50]


for (j in mink:maxk) {
  cat("----------------> group ", j)
  fld <- sprintf("res_final/kmean%02d", j)
  dir.create(fld, recursive = TRUE, showWarnings = FALSE)
  vr_gp <- paste0(j, " groups")
  tmp <- poe_env_groups[c("id_poe", vr_gp)] |>
    dplyr::rename(grp = vr_gp)
  geom_grp <- dplyr::inner_join(poe_env, tmp)

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
    title = "Groupe de k-mean vs végétation potentielle"
  )
  dev.off()


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
      title = "Groupe de k-means vs couverture des espèces"
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

  var_qlt <- c("slope_type", "humus_type", "deposit_group")
  titl <- c("Type de pente", "Type d'Humus", "Type de dépôt surfacique")
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

dir.create("res_final/maps_vegpot", recursive = TRUE)
for (j in unique(poe_env$potential_vegetation)) {
    fl <- sprintf("res_final/maps_vegpot/map_%s.png", j)
    png(fl,
        units = "in",
        height = 7, width = 8, res = 300
    )
    par(mar = c(0, 0, 1, 0))
    plot(domain_bio |> sf::st_geometry())
    plot(
        poe_env |>
            dplyr::filter(potential_vegetation == j) |>
            sf::st_geometry(),
        add = TRUE,
        pch = 19,
        col = "steelblue",
        cex = 0.7
    )
    mtext(j, 3, line = -1, cex = 2)
    dev.off()
}
