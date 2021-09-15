
#' Prepare extracted attributes from \code{igraph} object for plotting
#' 
#' @param ve_list a \code{list} of two elements: a \code{data.table} of vertex attributes and a \code{data.table} of an edge-list attributes
#' @param layout a two-dimensional \code{array} of node positions
#' @param v_color vertex colors
#' @param e_color edge colors
#' @param v_pch vertex shapes
#' @param v_cex vertex sizes
#' @param vf_cex_add how much to add (in percentages) to the vertex sizes when plotting frames
#' @param vf_color color of frames
#' @param vf_lwd line width of frames
#' @param e_lwd line width of edges
igraph_plot_prep = function(
    ve_list, 
    layout,
    v_frame = "white",
    v_fill = "blue",
    v_lwd  = .1, 
    v_pch = 21,
    v_cex = .6, 
    e_color = "grey",
    e_lwd = .3
){
    
    if (length(ve_list) != 2)
        stop("ve_list has to be a list of length 2")
    
    if (!all(c("v_dat", "e_dat") %in% names(ve_list)))
        stop("names of ve_list have to be v_dat and e_dat")
    
    if (!("matrix" %in% class(layout)))
        stop("layout has to be a two-dimensional matrix")
    
    if (!all(c("v_dat", "e_dat") %in% names(ve_list)))
        stop("names of ve_list have to be v_dat and e_dat")
    
    if (!("name" %in% names(ve_list$v_dat)))
        stop("ve_list$v_dat must have a column named name")
    
    if (!all(c("name1", "name2") %in% names(ve_list$e_dat)))
        stop("ve_list$e_dat must have a columns name1 and name2")

    if (NROW(ve_list$v_dat) != NROW(layout))
        stop("dimension mismatch between ve_list[[[1]]] and layout")
    
    
    v = data.table(name = ve_list$v_dat$name, type = ve_list$v_dat$type)
    e = data.table(name1 = ve_list$e_dat$name1, name2 = ve_list$e_dat$name2)
    
    # add layout for verticees
    v[, `:=`(dim1 = layout[, 1L], dim2 = layout[, 2L])]
    
    # vertex attributes    
    v[
        , `:=`(
            v_pch     = v_pch,
            v_frame   = v_frame,
            v_fill    = v_fill,
            v_lwd     = v_lwd,
            v_cex     = v_cex
        )
    ]
    
    # edge attributes
    e[
        , `:=`(
            e_color = e_color,
            e_lwd   = e_lwd
        )
    ]
    
    # layout for edges
    e = merge(
        e, 
        v[, .(name, dim1, dim2)],
        by.x = "name1",
        by.y = "name",
        all.x = T
    ) %>%
        setnames(
            c("dim1", "dim2"), c("dim1_1", "dim2_1")
        ) %>%
        merge(
            v[, .(name, dim1, dim2)],
            by.x = "name2",
            by.y = "name",
            all.x = T
        ) %>%
        setnames(
            c("dim1", "dim2"), c("dim1_2", "dim2_2")
        ) %>%
        setcolorder(c("name1", "name2"))
    
    return(list(v_dat = v, e_dat = e))
    
}


