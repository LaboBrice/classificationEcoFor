# See vignette
devtools::load_all()
library(dplyr)

spc_nm <- names(poe_species |> dplyr::select(-id_poe))
# Remove "FEU_R" "FEU_H" "RES_S" "FEU_S" "CLA_S"
spc_nm <- spc_nm[nchar(spc_nm) == 3]
var_nm <- names(poe_env)[!names(poe_env) %in% c("id_poe", "geom", "deposit_type", "potential_vegetation")]
poe <- inner_join(poe_env, poe_species) |>
  sf::st_drop_geometry() |>
  as.data.frame() |>
  na.omit() |>
  mutate(slope_type = as.factor(slope_type)) |>
  mutate(humus_type = as.factor(humus_type)) |>
  mutate(deposit_group = as.factor(deposit_group))

res_rda3 <- doRDA(poe[var_nm], poe[spc_nm])
# triplot_rda(res_rda3)
res_kmean <- doKMeans(res_rda3,
  max_grp = 30, km_method = "cascade", iter = 50, criterion = "calinski"
)
poe_env_groups <- cbind(poe, res_kmean$partition |> as.data.frame())

for (j in 2:30) {
  fld <- sprintf("tmp/kmean%02d", j)
  dir.create(fld, recursive = TRUE, showWarnings = FALSE)
  vr_gp <- paste0(j, " groups")
  tmp <- poe_env_groups[c("id_poe", vr_gp)] |>
    dplyr::rename(grp = vr_gp)
  geom_grp <- dplyr::inner_join(poe_env, tmp)

  for (i in seq(1, j)) {
    png(file.path(fld, sprintf("group_%02d.png", i)),
      units = "in",
      height = 8, width = 20, res = 300
    )
    layout(matrix(c(1, 2, 3), nrow = 1), widths = c(0.3, 0.3, 0.4))
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
    plot(compo[1:15],
      type = "h", lwd = 5, axes = FALSE, lend = 1,
      ylab = "Recouvrement moyen", xlab = ""
    )
    mtext(paste0("groupe ", i, "/", j), 3, line = -2, cex = 2)
    axis(2, las = 2)
    axis(1, at = 1:15, labels = names(compo[1:15]), las = 2)
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

    table(poe_env_groups$potential_vegetation, poe_env_groups[, vr_gp]) |> corrplot(
      is.corr = FALSE,
      mar = c(2, 1, 2, 1), 
      number.cex = 0.75, 
      cl.cex = 1.1, 
      cl.ratio = 2.4/(j),
      addCoef.col = "black",
      cl.align.text = "l",
      title = "Groupe de k-mean vs végétation potentielles"
    )
    
    dev.off()
  }
}