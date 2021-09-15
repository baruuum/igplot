#' constructor of igplotdat object
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

#' iplotdat helper
#' @export
igplotdat = function(
    v = data.table(),
    e = data.table(),
    has_layout = TRUE
) {
    
    x = igplot:::.create_igplotdat(v, e, has_layout)
    igplot:::.check_igplotdat(x)
    
}
