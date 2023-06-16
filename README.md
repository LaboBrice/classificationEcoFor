# classificationEcoFor

Pipeline pour créer une classification des ecosystèmes forestiers.


## Installation

1. clone the repo 
2. use `devtools::load_all()`


## Export raw data 

```R
source("inst/raw_data/formatRawData.R")
```


## Notes 

Files where imported as data frames and then saved as `rda` files (R Data files), see `inst/rawdata/formatRawData.R`.

- `classEcoFor::environ_var`: environment variables
- `classEcoFor::plot_location`: sf object with all plot details
- `classEcoFor::climatic_var`: climatic variables
- `classEcoFor::species_var`: species variables

