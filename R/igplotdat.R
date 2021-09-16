#' iplotdat helper
#' 
#' @param v vertex data (\code{data.table})
#' @param e edge data (\code{data.table})
#' @param has_layout boolean; \code{TRUE} if layout information are included and zero otherwise
#' @export
igplotdat = function(
    v = data.table(),
    e = data.table(),
    has_layout = TRUE
) {
    
    x = .create_igplotdat(v, e, has_layout)
    .check_igplotdat(x)
    
}

#' print method for `igplotdat` object
#' 
#' @param x an `igplotdat` object
#' @param ... further arguments passed to print
#' @export
print.igplotdat = function(x, ...) {
    
    cat("Vertices : \n")
    print(head(x$vertices))
    cat("\nEdges :\n")
    print(head(x$edges))
    cat(
        paste0(
            "\n`iplotdat` object", 
            ifelse(isTRUE(attr(x, "has_layout")), " with ", " without "),
            "layout information")
    )
    
}

#' check method
#' 
#' @param x arbitrary R object
#' @returns returns \code{TRUE} if \code{x} is a `igplotdat` object and zero otherwise.
#' @export
is.igplotdat = function(x) {
    
    "igplotdat" %in% class(x)
    
}
