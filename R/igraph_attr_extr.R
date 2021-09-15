#' Extract attributes from graph and combine with layout
#' 
#' @param g an \code{igraph} object
#' @param v_attr the vertex attributes to extract
#' @param e_attr the edge attributes to extract
#' @param what what to return
#' @return returns at most two \code{data.tables} in a list: one table has attributes of the nodes and the other attributes of edges
#' @export
.igraph_attr_extr = function(
    g, 
    v_attr = NULL, 
    e_attr = NULL, 
    what = c("both", "vertex", "edge")
) {
    
    # what to extract
    what = match.arg(what, several.ok = FALSE)
    
    # arg checks (directed graphs not supported yet)
    stopifnot(
        class(g) == "igraph",
        !is.directed(g)
    )
    
    if (!is.null(v_attr))
        stopifnot(
            is.character(v_attr),
            all(v_attr %in% names(vertex_attr(g)))
        )
    
    if (!is.null(e_attr))
        stopifnot(
            is.character(e_attr),
            all(e_attr %in% names(edge_attr(g)))
        )
    
    # add "name" attribute to vertices
    v_attr = if ("name" %in% v_attr) {
        v_attr 
    } else {
        
        vertex_attr(g, "name") = seq_len(vcount(g))
        c("name", v_attr)
        
    }
    
    v = setDT(vertex_attr(g)[v_attr])
    
    e_attr_mat = if (!is.null(e_attr)) {
        do.call("cbind", edge_attr(g)[e_attr])
    } else NULL
    
    e = as.data.table(
        cbind(
            as_edgelist(g, names = TRUE), 
            e_attr_mat
        )
    )
    setnames(e, c("name1", "name2", e_attr))
    
    if (what == "both") {
        
        return(list(v_dat = v, e_dat = e))
        
    } else if (what == "vertex") {
        
        return(v)
        
    } else {
        
        return(e)
        
    }
    
}
