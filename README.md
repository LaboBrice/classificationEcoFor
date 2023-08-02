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

Files were imported as data frames and then saved as `rda` files (R Data files), see `inst/rawdata/formatRawData.R`.

- `classEcoFor::environ_var`: environment variables
- `classEcoFor::plot_location`: sf object with all plot details
- `classEcoFor::climatic_var`: climatic variables
- `classEcoFor::species_var`: species variables

