#' igplot: fast(er) plotting of igraph objects
#' 
#' This function uses the base::plot function to plot igraph objects.
#' 
#' @docType package
#' @name igplot
#' @useDynLib igplot, .registration = TRUE
#' @importFrom utils getFromNamespace
#' @importFrom data.table data.table setnames melt dcast `:=` setDT setcolorder
#' @importFrom Rcpp sourceCpp
#' @importFrom grDevices dev.off pdf
#' @importFrom graphics arrows par points rect segments
#' @importFrom utils head
NULL
