#' igplot: fast(er) plotting of igraph objects
#' 
#' This package simlifies the plot.igraph function for faster plotting of igraph objects
#' 
#' @docType package
#' @name igplot
#' @useDynLib igplot, .registration = TRUE
#' @importFrom utils getFromNamespace head
#' @importFrom Rcpp sourceCpp
#' @importFrom grDevices dev.off pdf
#' @importFrom graphics arrows par points rect segments
#' @importFrom data.table data.table setnames melt dcast `:=` setDT setcolorder merge.data.table
NULL
