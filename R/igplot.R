
#' Function to plot network
#' 
#' @param g an \code{igraph} object, a \code{matrix} or \code{data.table} object with two columns containing the edgelist, or a \code{igplotdat} object
#' @param layout either a string that is equal to the \code{igraph} function that creates the layout (e.g., "layout_with_fr") or a two-dimensional matrix of the coordinates of the vertices
#' @param directed boolean; if \code{g} is not an \code{igraph} object, indicates whether the edgelist is directed or not
#' @param bg_col background color
#' @param v_frame vertex frame color
#' @param v_lwd vertex frame thickness
#' @param v_fill vertex fill color
#' @param v_cex vertex size
#' @param v_pch vertex pch
#' @param e_color edge color
#' @param e_lwd edge linewidth
#' @param width width of the pdf file (in inches)
#' @param height height of the pdf file (in inches)
#' @param outfile name of the output file
#' @param return_dat whether to return the data
#' @export
igplot = function(
    g,
    layout     = NULL,
    directed   = FALSE,
    bg_col     = "white",
    v_frame    = "white",
    v_fill     = "blue",
    v_lwd      = .1, 
    v_pch      = 21,
    v_cex      = .6, 
    e_color    = "grey",
    e_lwd      = .3,
    e_length   = .25,
    e_angle    = 30,
    outfile    = NULL,
    width      = 7,
    height     = 7,
    return_dat = FALSE
) {
    
    # helper function
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
    
    # check input
    if (class(g) != "igplotdat") {
        
        if (class(g) != "igraph") {
            
            message("Treating g as edgelist")
            
            if(NCOL(g) != 2)
                stop("g must be either an igraph object or matrix/data.table of two columns")
            
            g = igraph::graph_from_edgelist(g, directed = directed)
            
        }
    
        # number of vertices
        nV = igraph::vcount(g)
    
        # check layout 
        if (class(layout) == "character") {
            
            layout = utils::getFromNamespace(layout, "igraph")(g)
            
        } else {
            
            stopifnot(
                NCOL(layout) == 2,
                NROW(layout) == nV
            )
            
        }
        
        # get vertices
        v_names = igraph::vertex_attr(g, "name")
        if (length(v_names) == 0) {
            
            igraph::vertex_attr(g, "name") = seq_len(nV)
            v_names = seq_len(nV)
            
        }
        
        # add attributes and layout dims
        v = data.table(
            name    = v_names,
            dim1    = layout[, 1L], 
            dim2    = layout[, 2L]
        )
        
        # get edges
        e = data.table(igraph::as_edgelist(g, names = TRUE))
        setnames(e, c("name1", "name2"))
        
        e = merge_layout(v, e)
        
    } else {
        
        if (!isTRUE(attr(g, "has_layout"))) {
            
            if (is.null(layout)) {
            
                net = igraph::graph_from_data_frame(
                    g$edges[, c("name1", "name2")], 
                    directed = directed,
                    vertices = g$vertices[, c("name")]
                )
                
                layout = utils::getFromNamespace(layout, "igraph")(net)
                colnames(layout) = c("dim1", "dim2")
                
            }
            
            g$vertices = cbind(g$vertices, layout)
            g$edges = merge_layout(g$vertices, g$edges)
            
        }
        
        v = g$vertices
        e = g$edges
        
    }
    
    # add vertex attributes
    v[, `:=`(
        v_pch   = v_pch,
        v_frame = v_frame,
        v_fill  = v_fill,
        v_lwd   = v_lwd,
        v_cex   = v_cex
    )]

   
    
    # add attributes
    e[, `:=`(
        e_color  = e_color,
        e_lwd    = e_lwd
    )]
    
    if (!is.null(outfile))
        pdf(outfile, width = width, height = height)
    
    par(oma = rep(0, 4), mar = c(0, 0, 0, 0))
    plot(
        v$dim1, 
        v$dim2, 
        type = "n",
        xlab = NA,
        ylab = NA,
        axes = F)
    rect(
        par("usr")[1],
        par("usr")[3],
        par("usr")[2],
        par("usr")[4],
        col = bg_col,
        border = NA
    )
    if (directed) {
        
        e[, `:=`(e_length = e_length, e_angle = e_angle)]
        
        arrows(
            x0 = e$dim1_1, 
            y0 = e$dim2_1,
            x = e$dim1_2, 
            y = e$dim2_2,
            col = e$e_color,
            lwd = e$e_lwd,
            length = e_length,
            angle = e_angle
        )
        
    } else {
        
        segments(
            x0 = e$dim1_1, 
            y0 = e$dim2_1,
            x = e$dim1_2, 
            y = e$dim2_2,
            col = e$e_color,
            lwd = e$e_lwd
        )
        
    }    
    points(
        v$dim1, 
        v$dim2, 
        col = v$v_frame,
        bg  = v$v_fill,
        lwd = v$v_lwd,
        cex = v$v_cex, 
        pch = v$v_pch
    )
    
    if (!is.null(outfile))
        dev.off()
    
    if (return_dat)
        return(igplotdat(v, e, has_layout = TRUE))
    
}
