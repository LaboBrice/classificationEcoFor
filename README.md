# classificationEcoFor

> Pipeline pour créer une classification possible des ecosystèmes forestiers québécois.


## Installation

### Option 1

1. cloner ce repertoire,
2. ouvrir R et définissez le répertoire de travail sur le répertoire que vous venez de cloner,
3. installer le package:

```R
install.packages("devtools")
remotes::install_local()
```

Alternativement, plutôt que d'installer le package et vous pouvez travailler avec `load_all()`, voir la section "Comment faire".

### Option 2 

Installer le package directement de GitHub. 

```R
remotes::install_github("LaboBrice/classificationEcoFor")
```


## Comment faire 

### Utiliser le package 

Une fois installé, le package peut être appelé et utilisé comme n'importe lequel:

```R
library("classEcoFor")
```

Il est aussi possible de travailler directement sur le repertoire:

```R
devtools::load_all()
```

### Liste des fonctions disponibles

Les fonctions se trouvent dans le dossier `R`. Notez que toutes les fonctions du package sont documentées. Par exemple, `?boxCoxChord()` ouvrira à la page de documentation.

- `boxCoxChord()`: calcul la transformation Box-Cox Chord 
- `chalumeau()`: fonction qui appelle les fonctions pour reproduire les étapes d'analyses de classification de Chalumeau
    1. `getData()` et `prepareData()` préparer et formatter les données d'espèces et environnementales pour les analyses
    2. `doRDA()` rouler la RDA 
    3. `doKMeans()` faire les groupements k-means sur les axes de la RDA
- `triplot_rda()`: créer un graphique de RDA personnalisé.

Les scripts dans le dossier `inst/extra_scripts` permettent de faire des analyses et figures supplémentaires:

- `poe_kmean_by_dir.R`: ce script permet de faire les étapes d'analyses de la classification, soit la RDA puis les groupements k-means pour `k = 20 à 40` groupes puis de créer des figures dans le dossier `tmp`: 
    - carte des POE et barplot des abondances d'espèces pour chaque groupe
    - triplot de la RDA avec les groupes
    - stacked barplot des proportions des variables qualitatives (types de dépôt, types d'humus, types de pente) par groupe
    - boxplot des variables quantitatives (température, précipitation, épaisseur de la matière organique) par groupe
    - tableau "heatmap" des végétations potentielles par groupe
    - tableau "heatmap" du recouvrement moyen des espèces par groupe
    - `csv` avec les coordonnées des centroïdes des groupes dans la RDA
- `poe_map_veg_pot.R`: ce script permet de produire une carte de la répartition de chacune des végétations potentielles. Ces cartes sont enregistrées dans le dossier `tmp/maps_vegpot`
- `poe_rda_coord.R`: ce script permet d'obtenir les coordonnées des espèces et des sites dans la RDA.
- `poe_kmean_subgroup.R`: ce script permet de faire les étapes d'analyses de la classification, , soit la RDA puis les groupements k-means pour `k = 2 à 40` groupes, sur les POE d'un type de dépôt particulier (ici 2BS) puis de créer les mêmes figures que `poe_kmean_by_dir.R` dans le dossier `tmp/res_2bs`.

### Vignettes

Les vignettes permettent de reproduire toutes les étapes des analyses de classification. `build_vignettes()` permettra de produire un fichier html avec les différentes sorties:

```R
devtools::build_vignettes()
```

### Données disponibles 

La commande suivante liste tous les ensembles de données disponibles dans le package:

```R
data(package = "classEcoFor")
```

Les étapes pour importer et transformer les différents jeux de données nécessaires sont décrites sur `inst/rawdata/formatRawData.R`. Les jeux de données ont été enregistrés sous forme de fichiers (fichiers de données R) `.rda` dans le dossier `data`. Ces étapes n'ont pas besoin d'être roulées à nouveau pour faire les analyses.


⚠️ Les données climatiques historiques sont disponibles en ligne à l'URL suivante: <https://ftp.maps.canada.ca/pub/nrcan_rncan/Climate-archives_Archives-climatologiques/NAM_monthly/monthly_by_year/>.


```R
source("inst/raw_data/formatRawData.R")
```

