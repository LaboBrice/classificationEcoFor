#' Custom rda triplot
#'
#' @param res_rda a rda object
#'
#' @references
#' Code borrowed and adapted from:
#' - <https://r.qcbs.ca/workshop10/book-en/redundancy-analysis.html>
#'
#' @export
#'

triplot_rda <- function(res_rda) {
    ## extract % explained by the first 2 axes
    perc <- round(100 * (summary(res_rda)$cont$importance[2, 1:2]), 2)

    ## extract scores - these are coordinates in the RDA space
    sc_si <- scores(res_rda, display = "sites", choices = c(1, 2), scaling = 2)
    sc_sp <- scores(
        res_rda,
        display = "species",
        choices = c(1, 2),
        scaling = 2
    )
    sc_bp <- scores(res_rda, display = "bp", choices = c(1, 2), scaling = 2)

    ## Custom triplot, step by step

    # Set up a blank plot with scaling, axes, and labels
    plot(res_rda,
        scaling = 1, # set scaling type
        type = "none", # this excludes the plotting of any points from the results
        frame = FALSE,
        # set axis limits
        xlim = c(-1, 1),
        ylim = c(-1, 1),
        # label the plot (title, and axes)
        main = paste0(
            "Triplot RDA (scaling: 2, R2-adj: ",
            100 * round(RsquareAdj(res_rda)$adj.r.squared, 4),
            "%)"
        ),
        xlab = paste0("RDA1 (", perc[1], "%)"),
        ylab = paste0("RDA2 (", perc[2], "%)")
    )
    # add points for site scores
    points(sc_si,
        pch = 21, # set shape (here, circle with a fill colour)
        col = "transparent", # outline colour
        bg = "steelblue", # fill colour
        cex = 0.3
    ) # size
    # add points for species scores
    points(sc_sp,
        pch = 22, # set shape (here, square with a fill colour)
        col = "transparent",
        bg = "grey50",
        cex = 1.2
    )
    # add text labels for species abbreviations
    slc <- c(
        rev(order(sqrt(sc_sp[, 1]^2 + sc_sp[, 2]^2)))[1:25]
    ) |>
        unique()
    sc_sp_slc <- sc_sp[slc, ]
    text(sc_sp_slc + cbind(0.015, c(-0.02, 0.02)[1 + (sc_sp_slc[, 2] > 0) * 1]),
        labels = rownames(sc_sp_slc),
        col = "grey30",
        font = 2, # bold
        cex = 1
    )
    # add arrows for effects of the expanatory variables
    arrows(0, 0, # start them from (0,0)
        sc_bp[, 1], sc_bp[, 2], # end them at the score value
        col = "#c9386d",
        lwd = 3
    )
    # add text labels for arrows
    text(
        x = sc_bp[, 1],
        y = sc_bp[, 2] + c(-0.03, 0.03)[1 + (sc_bp[, 2] > 0) * 1],
        labels = rownames(sc_bp),
        col = "#c9386d",
        cex = 1,
        font = 2
    )

    box(lwd = 1.2)
}