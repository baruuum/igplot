
<!-- README.md is generated from README.Rmd. Please edit that file -->

# igplot

This is just a simple wraper around the `base::plot` function to create
network plots faster than `igraph`.

## Installation

You can install `igplot` with:

``` r
remotes::install_github("baruuum/igplot")
```

## Example

``` r
library(igraph)
#> 
#> Attaching package: 'igraph'
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union
library(igplot)
library(knitr)

# make graph
g = erdos.renyi.game(10, .3)

# make the same plot twice
set.seed(42)
tictoc::tic()
pdf("images/plot1.pdf", width = 6, height = 5)
plot(g, layout = layout_with_fr)
dev.off()
#> quartz_off_screen 
#>                 2
tictoc::toc()
#> 0.07 sec elapsed
set.seed(42)
tictoc::tic()
igplot(
    g, 
    layout = "layout_with_fr", 
    bg = "white", 
    outfile = "images/plot2.pdf",
    width = 6,
    height = 5,
    return_dat = FALSE
)
tictoc::toc()
#> 0.018 sec elapsed
```

![](images/plot1.pdf)

`igplot` should be faster than `plot.igraph` especially for larger
graphs:

``` r
g = erdos.renyi.game(5000, .05)
tictoc::tic()
pdf("images/plot1_large.pdf", width = 6, height = 5)
plot(g, layout = layout_with_fr)
dev.off()
#> quartz_off_screen 
#>                 2
tictoc::toc()
#> 17.895 sec elapsed

tictoc::tic()
igplot(
    g, 
    layout = "layout_with_fr", 
    bg = "white", 
    outfile = "images/plot2_large.pdf",
    width = 6,
    height = 5,
    return_dat = FALSE
)
tictoc::toc()
#> 5.906 sec elapsed
```
