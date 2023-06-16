#' Compute the Box-Cox.chord transformation on quantitative community
#' composition data for any exponent. Usual exponents are larger than or equal 
#' to 0.
#'
#' @param mat Matrix or data.frame of quantitative non-negative community
#'    composition data (frequencies, biomasses, energy measures, etc.)
#' @param bc.exp Box-Cox exponent to the data before chord transformation.
#'    Usual exponent values are {1, 0.5, 0.25, 0}, where
#'    bc.exp=1: no transformation;
#'    bc.exp=0.5: square-root transformation;
#'    bc.exp=0.25: fourth-root (or double square-root) transformation;
#'    bc.exp=0: log(y+1) transformation (default value).
#'    Default value: bc.exp=0 (log(y+1) transformation).
#'
#' @return
#' A Box-Cox+chord transformed matrix of the same size as the original data matrix.
#'
#' @details
#' This code is a minor rewrite of Pierre Legendre's code provided in its
#' lecture (Appendix 4)
#'
#' @references
#' - <https://en.wikipedia.org/wiki/Power_transform>
#' - <https://onlinestatbook.com/2/transformations/box-cox.html>
#'
#' @examples
#' boxCoxChord(matrix(runif(100), 10, 10))
#' @export
boxCoxChord <- function(mat, bc.exp = 0) {
    #
    chck <- apply(mat, 1, sum)
    if (any(chck == 0)) {
        stop("Rows", which(chck == 0), " of the data matrix sum to 0")
    }
    # Apply the user-selected Box-Cox exponent (bc.exp) to the frequency data
    if (bc.exp == 0) {
        tmp <- log(mat + 1)
    } else {
        tmp <- mat^bc.exp
    }
    # Divide by the norm 
    sweep(tmp, 1, apply(tmp, 1, vNorm), "/")
}


vNorm <- \(x) sqrt(sum(x^2))