# Introducci�n

## Proceso de Limpieza y Preparaci�n de los datos

### Preparaci�n del entorno y Obtenci�n de los datos

# Cargamos las librer�as necesarias
library(knitr)
library (reshape)
library(readr)
library(dplyr)

# Creamos el directorio para almacenar los datos
if (!file.exists("./messydata")) {
  dir.create("./messydata")
}

messydata_dir <- "./messydata"

# Descargamos y descomprimimos el dataset
fileURL <- "https://www.kaggle.com/gmadevs/atp-matches-dataset/downloads/atp-matches-dataset.zip"
download.file(fileURL,destfile="./messydata/atp-matches-dataset.zip",method="auto") 
unzip("./messydata/atp-matches-dataset.zip", exdir="./messydata") 

fechaDescarga <- date() 
listaf = list.files("./messydata", "*.csv", full.names = FALSE)
listaf


### Preparaci�n del dataframe con todos los datos

# Extraemos los nombres de los atributos (columnas)
atp_matches_names <- read.table(file="./messydata/atp_matches_2017.csv",nrow=1,stringsAsFactors = FALSE, sep=",")

# Extraemos los datos de todos los ficheros (sin la cabecera). Usamos la funci�n paste para conformar la ruta con todos los ficheros ".csv"
atp_matches_data <- lapply(listaf, function(x) read.csv(paste(messydata_dir,x, sep='/'), na.strings = "NA", stringsAsFactors = FALSE, skip=1, header=FALSE, sep=",", fill=TRUE)[,1:49])

# Juntamos todos los objetos con los datos en nuestro dataframe
atp_matches_df <- do.call(rbind,atp_matches_data)[,1:49] #alternativa a rbind(atp_matches_data)
names(atp_matches_df) <- atp_matches_names
kable(head(atp_matches_df)[,1:10])
write.csv(atp_matches_df, file = './messydata/atp_matches_messy.csv')


### An�lisis previo de los datos

#N�mero de datos recogidos
nrow(atp_matches_df)

#Informaci�n de la estructura de los datos 
str(atp_matches_df)

#Informaci�n estad�stica descriptiva de los diferentes campos que conforman el dataframe 
summary(atp_matches_df)

### Acciones de limpieza y transformaci�n

# Conversi�n a min�sculas de todos los nombres de los atributos
names(atp_matches_df) <- tolower(names(atp_matches_df))

# Conversi�n a fecha del campo tourney_date y a�adimos una nueva columna exclusiva para recoger �nicamente el a�o
atp_matches_df$tourney_date = as.Date.character(atp_matches_df$tourney_date, "%Y%m%d")
atp_matches_df$year <- format(atp_matches_df$tourney_date,'%Y')

# Eliminaci�n de los elementos duplicados (62 elementos duplicados)
atp_matches_df <- unique(atp_matches_df)

# Eliminaci�n de los datos nulos
atp_matches_df <- subset(atp_matches_df, !(atp_matches_df$tourney_id == "NA" | atp_matches_df$tourney_id == ""))

# Eliminaci�n de los campos en los que no se haya llegado a jugar el partido por retirada previa de alg�n jugador
# Para ello eliminamos los registros con los resultados "Walkover", "W/O" e "In Progress"
atp_matches_df <- subset(atp_matches_df, !(atp_matches_df$score %in% c("Walkover", "W/O", "In Progress")))

### Escritura del tidy dataset

# Creamos el directorio para almacenar los datos limpios
if (!file.exists("./tidydata")) {
  dir.create("./tidydata")
}

# Escritura del dataset limpio
write.csv(atp_matches_df, file = './tidydata/atp_matches_clean.csv')