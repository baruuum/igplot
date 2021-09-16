#' Function to plot network
#' 
#' @param g an \code{igraph} object, a \code{matrix} or \code{data.table} object with two columns containing the edgelist, or a \code{igplotdat} object
#' @param layout either a string that is equal to the \code{igraph} function that creates the layout (e.g., "layout_with_fr") or a two-dimensional matrix of the coordinates of the vertices
#' @param directed boolean; if \code{g} is not an \code{igraph} object, indicates whether the edgelist is directed or not
#' @param bg_col background color
#' @param plot_opts a named list containing plotting options (see details)
#' @param outfile path to file
#' @param width width of the pdf file (in inches)
#' @param height height of the pdf file (in inches)
#' @param return_data whether to return the data
#' @param plot whether to create the plot
#' @param corp boolean; if \code{TRUE} corps the image to the positions of nodes
#' @details Currently, the following options are supported for the \code{plot_opts} list:
#' \enumerate{
#'     \item \code{v_frame}, vertex frame color
#'     \item \code{v_lwd}, vertex frame thickness
#'     \item \code{v_fill}, vertex fill color
#'     \item \code{v_cex}, vertex size
#'     \item \code{v_pch}, vertex pch
#'     \item \code{e_col}, edge color
#'     \item \code{e_lwd}, edge linewidth
#'     \item \code{e_length}, length of the arrow when \code{directed} is \code{TRUE}
#'     \item \code{e_angle}, angle of the arrow when \code{directed} is \code{TRUE}
#' }
#' @export
igplot = function(
    g,
    layout      = NULL,
    directed    = FALSE,
    bg_col      = "white",
    plot_opts   = list(),
    outfile     = NULL,
    width       = 7,
    height      = 7,
    return_data = FALSE,
    plot        = TRUE,
    corp        = FALSE
) {
    
    # default plotting options
    p_opts = list(
        v_frame     = "white",
        v_fill      = "blue",
        v_lwd       = .1, 
        v_pch       = 21,
        v_cex       = .6, 
        e_col       = "darkgrey",
        e_lwd       = .3,
        e_length    = .25,
        e_angle     = 30
    )
    
    # override with provided options
    if (length(plot_opts) > 0) {
        
        ch_opts = intersect(names(p_opts), names(plot_opts))
        p_opts[ch_opts] = plot_opts[ch_opts]
        
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
        if (!is.null(layout)) {
            
            if (class(layout) == "character") {
                
                layout = utils::getFromNamespace(layout, "igraph")(g)
                
            } else {
                
                stopifnot(
                    NCOL(layout) == 2,
                    NROW(layout) == nV
                )
                
            }
            
        } else {
            
            layout = utils::getFromNamespace("layout.auto", "igraph")(g)
            
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
        
        # add layout to edges
        e = igplot:::merge_layout(v, e)
        
        # add vertex attributes
        v[, `:=`(
            v_pch   = p_opts$v_pch,
            v_frame = p_opts$v_frame,
            v_fill  = p_opts$v_fill,
            v_lwd   = p_opts$v_lwd,
            v_cex   = p_opts$v_cex
        )]
        
        # add edge attributes
        e[, `:=`(
            e_col  = p_opts$e_col,
            e_lwd  = p_opts$e_lwd
        )]
        
    } else {
        
        # create layout if not presented
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
            g$edges = igplot:::merge_layout(g$vertices, g$edges)
            
        }
        
        v = g$vertices
        e = g$edges
        
        # by default use plotting attributes in provided object
        mis_opts = setdiff(names(p_opts), c(names(v), names(e)))
        
        # fill in options that are missing by default values
        if (length(mis_opts) > 0) {
            
            e_opts = grep("^e_", mis_opts, value = TRUE)
            if (length(e_opts) > 0)
                e[, (e_opts) := p_opts[e_opts]]
            
            v_opts = grep("^v_", mis_opts, value = TRUE)
            if (length(v_opts) > 0)
                v[, (v_opts) := p_opts[v_opts]]
            
        }
            
        
    }
    
    
    if (plot) {
        
        old_oma = par()$oma
        old_mar = par()$mar
        
        if (!is.null(outfile))
            pdf(outfile, width = width, height = height)
        
        par(oma = rep(0, 4), mar = c(0, 0, 0, 0))
        if (corp) {
            
            plot(
                NA, 
                type = "n",
                xlab = NA,
                ylab = NA,
                xlim = c(min(v$dim1), max(v$dim1)),
                ylim = c(min(v$dim2), max(v$dim2)),
                axes = F)
            
        } else {
            
            plot(
                NA, 
                type = "n",
                xlab = NA,
                ylab = NA,
                xlim = c(
                    min(e[, min(dim1_1, dim1_2)], min(v$dim1)),
                    max(e[, max(dim1_1, dim1_2)], max(v$dim1))
                ),
                ylim = c(
                    min(e[, min(dim2_1, dim2_2)], min(v$dim2)),
                    max(e[, max(dim2_1, dim2_2)], max(v$dim2))
                ),
                axes = F)
            
        }
        rect(
            par("usr")[1],
            par("usr")[3],
            par("usr")[2],
            par("usr")[4],
            col = bg_col,
            border = NA
        )
        if (directed) {
            
            e[, `:=`(e_length = p_opts$e_length, e_angle = p_opts$e_angle)]
            
            arrows(
                x0 = e$dim1_1, 
                y0 = e$dim2_1,
                x = e$dim1_2, 
                y = e$dim2_2,
                col = e$e_col,
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
                col = e$e_col,
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
        
        # switch back to old pars
        par(oma = old_oma, mar = old_mar)
        
    }
    
    if (return_data)
        return(igplotdat(v, e, has_layout = TRUE))
    
}
