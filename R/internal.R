#' helper function, merges vertex data to edge data
#' 
#' @param v vertex set
#' @param e edge set
#' @return merges the coordinates in v into e
merge_layout = function(v, e) {
    
    e = merge(
        e, 
        v[, c("name", "dim1", "dim2")],
        by.x = "name1",
        by.y = "name",
        all.x = T
    ) 
    setnames(e, c("dim1", "dim2"), c("dim1_1", "dim2_1")) 
    
    e = merge(
        e, 
        v[, c("name", "dim1", "dim2")],
        by.x = "name2",
        by.y = "name",
        all.x = T
    ) 
    setnames(e, c("dim1", "dim2"), c("dim1_2", "dim2_2"))
    setcolorder(e, c("name1", "name2"))
    
    return(e)
    
}

#' constructor of igplotdat object
#' 
#' @param v vertex data (\code{data.table})
#' @param e edge data (\code{data.table})
#' @param l boolean; \code{TRUE} if layout information are included and zero otherwise
#' @returns a `igplotdat` object
.create_igplotdat = function(v = data.table(), e = data.table(), l = logical()) {
    
    # check attributes
    stopifnot(
        "data.table" %in% class(v),
        "data.table" %in% class(e),
        is.logical(l)
    )
    
    pdat = structure(list(vertices = v, edges = e), class = "igplotdat")
    attr(pdat, "has_layout") = l
    
    pdat
    
}

#' validate igplotdat object
#' 
#' @param x an arbitrary R object
#' @returns checks whether it is a valid `igplotdat` object and if not throws exceptions
.check_igplotdat = function(x) {
    
    rows = vapply(x, NROW, 1L)
    cols = vapply(x, NCOL, 1L)
    if (any(rows == 0))
        stop("all elements of `x` must have at least one row", call. = FALSE)
    
    if (cols[1] == 0)
        stop("`x$vertices` must have at least one column", call. = FALSE)
    
    if (cols[2] < 2)
        stop("x$edges` must have at least two columns", call. = FALSE)
    
    if (!isTRUE(attr(x, "has_layout")))
        stop("`has_layout` attribute is not TRUE")
    
    if (isTRUE(attr(x, "has_layout")) && !all(c("dim1", "dim2") %in% names(x$vertices)))
        stop("if has_layout attribute is TRUE, `x$vertices` data.table must have columns with names `dim1` and `dim2`", call. = FALSE)
    
    if (isTRUE(attr(x, "has_layout")) && !all(c("dim1_1", "dim2_1", "dim1_2", "dim2_2") %in% names(x$edges)))
        stop("if has_layout attribute is TRUE, `x$edges` data.table must have columns with names `dim1_1`, `dim2_1`, `dim1_2`, `dim2_2`", call. = FALSE)
    
    x
    
}
