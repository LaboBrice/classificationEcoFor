devtools::load_all()
library(dplyr)
fld <- "tmp/res_rda_coords"
dir.create(fld, recursive = TRUE, showWarnings = FALSE)

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

ls_exc <- list(
    c("humus_type", "mo_thickness", "deposit_group"),
    c("deposit_group"),
    "all_good"
)

for (i in seq(ls_exc)) {
    var_nm2 <- var_nm[!var_nm %in% ls_exc[[i]]]
    print(var_nm2)
    res_rda <- doRDA(poe[var_nm2], poe[spc_nm])
    sc_sp <- scores(res_rda, display = "species", choices = c(1, 2))
    write.csv(sc_sp,
        file = sprintf("%s/fichier%da.csv", fld, i),
        row.names = TRUE
    )
    sc_bp <- scores(res_rda, display = "bp", choices = c(1, 2))
    write.csv(sc_bp,
        file = sprintf("%s/fichier%db.csv", fld, i),
        row.names = TRUE
    )
}
