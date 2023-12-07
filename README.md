# classificationEcoFor

> Data pipeline to generate a potential classification of forest ecosystems in Quebec.

> Pipeline pour créer une classification possible des ecosystèmes forestiers québécois.


## Installation

### Option 1

1. clone this repository,
2. open R and set the working directory to the directory you've just cloned,

```R
install.packages("devtools")
remotes::install_local("")
```

Alternatively, you may not install the package and work with `load_all()` see section "How to"


### Option 2 

Install the package directly from GitHub. 

```R
remotes::install_github("LaboBrice/classificationEcoFor")
```




## How to 

### Use the package 

Once installed, the package can be used as any other: 

```R
library("classificationEcoFor")
```

If you rather work with the repository, you should rather use:

```R
devtools::load_all()
```

### Function list

Note that all exported functions are documented, e.g. `?boxCoxChord()` will return the documentation page:

- `boxCoxChord()`: compute the Box-Cox.chord transformation
- `chalumeau()`: 
    - format data, see `getData()`
    - perform RDA, see `doRDA()` and `doKMeans()`
    - perform Kmeans, see `doKmeans`
- `triplot_rda()`: create a custom rda triplot

### Vignettes

Vignettes include the analysis to be reproduced.

```R
devtools::build_vignettes()
```

### Use data 

The following command list all datasets available in the package.

```R
data(package = "classEcoFor")
```

Data were imported (some data sets have been transformed) and then saved as `rda` files (R Data files), see `inst/rawdata/formatRawData.R`.

⚠️ Historical data are available online at the following URL: <https://ftp.maps.canada.ca/pub/nrcan_rncan/Climate-archives_Archives-climatologiques/NAM_monthly/monthly_by_year/>.


```R
source("inst/raw_data/formatRawData.R")
```

