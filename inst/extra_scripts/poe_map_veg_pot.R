# See vignette
devtools::load_all()
library(dplyr)
library(sf)

dir.create("tmp/maps_vegpot", recursive = TRUE)
for (j in unique(poe_env$potential_vegetation)) {
    fl <- sprintf("tmp/maps_vegpot/map_%s.png", j)
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