#' igplot: fast(er) plotting of igraph objects
#' 
#' This function uses the base::plot function to plot igraph objects.
#' 
#' @docType package
#' @name igplot
#' @useDynLib igplot, .registration = TRUE
#' @importFrom utils getFromNamespace head
#' @importFrom Rcpp sourceCpp
#' @importFrom grDevices dev.off pdf
#' @importFrom graphics arrows par points rect segments
NULL
