# classificationEcoFor

> Data pipeline to generate a potential classification of forest ecosystems in Quebec.

> Pipeline pour créer une classification possible des ecosystèmes forestiers québécois.



## Installation

1. clone this repository,
2. open R and set the working directory to the directory you've just cloned,
2. use `devtools::load_all()`.


```R
install.packages("devtools")
remotes::install_deps()
devtools::build_vignettes()
```


## Export raw data 


```R
source("inst/raw_data/formatRawData.R")
```


## Notes 

Data were imported (some data sets have been transformed) and then saved as `rda` files (R Data files), see `inst/rawdata/formatRawData.R`. The following command list all datasets available in the package.

```R
data(package = "classEcoFor")
```
