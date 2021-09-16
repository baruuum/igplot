#' Procrustes-transform layout
#' 
#' @param x layout to be transformed. Either a \code{data.table} object or a \code{matrix}
#' @param y target layout.Either a \code{data.table} object or a \code{matrix}
#' @return transforms \code{y} to be as close as possible without changing the shape of the graph.
#' @export
procrustes = function(x, y) {
    
    # helper functions
    check_args_procrustes = function(z) {
        
        if (is.igplotdat(z)) {
            
            z = as.matrix(z$vertices[, c("dim1", "dim2")])
            
        } else if (is.data.frame(z)) {
            
            stopifnot(NCOL(z) == 2)
            z = as.matrix(z)
            
        } else {
            
            if (!is.array(z)) 
                stop("input has to be either a matrix, data.frame, or igplotdat object")
            
        }
        
        z
        
    }
    
    # get layouts
    x_layout = check_args_procrustes(x)
    y_layout = check_args_procrustes(y)
    
    # check dimensions
    stopifnot(all(dim(x) == dim(y)))
    
    res = igplot:::.transform_procrustes(x_layout, y_layout, translation = TRUE, scale = TRUE)
    
    if (!is.igplotdat(x)) 
        return(res$Xstar)
    
    x$vertices[, c("dim1", "dim2") := list(res$Xstar[, 1L], res$Xstar[, 2L])]
    x$edges = igplot:::merge_layout(
        x$vertices, 
        x$edges[, !grepl("^dim\\d_\\d", names(x$edges)), with = F]
    )
    
    return(x)
    
}