library(SSN2)
library(ggplot2)
library(arm)
library(MASS)
library(AICcmodavg)
library(MuMIn)
library(glmmTMB)
library(DHARMa)
library(ggeffects)
library(bbmle)

library(tidyverse)

#invasive species



data <- read.csv ("./data/OriginalDataFiles/data_20241011.csv", header =
                    T)
View(data)
table(data$infestationname)
dim(data)
data <- data[complete.cases(data[, 4]), ]
dim(data)
data$Year <- as.factor(data$Year)
data$Count <- as.integer((data$Count))
CBCT <- data |>
  filter(infestationname == "Cold Bay Creeping Thistle")
CBOH <- data |>
  filter(infestationname == "Cold Bay Orange Hawkweed")
CBOD <- data |>
  filter(infestationname == "Cold Bay Oxeye Daisy")
UGOH <- data |>
  filter(infestationname == "Ugashik Orange Hawkweed")




# reorder by column name
data <- data[, c("pointname",
                 "Year",
                 "infestationname",
                 "Count",
                 "geometry",
                 "dotcolor",
                 "Notes")] # leave the row index blank to keep all rows


#replace space in pointname wiht underscore
data$pointname <- sub(" ", "_", data$pointname)
data <- unite(data, Site, pointname:Year, remove = FALSE)

data$name <- substr(data$pointname, 1, 4)
data$label <- data$infestationname

data<-data |> 
  rename(longitude=geometry, latitude=dotcolor) 

data$longitude <- substring(data$longitude, 3)
data$latitude <- sub(")", "", data$latitude)
data <- data[, c(
  "Site",
  "name",
  "label",
  "Year",
  "Count",
  "longitude",
  "latitude",
  "Notes"
)]

write.csv(data,
          "./data/FinalDataFiles/data_final_20232024_20250306.csv",
          row.names = F)
# CBCT ----------------------------------------------------------------------


Poisson <-
  glmmTMB(
    Count ~Year,
    family = poisson,
    data = CBCT
  )

NegBin <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = CBCT
  )

ZINB <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = CBCT,
    ziformula = ~ 1
  )

summary(Poisson)
summary(NegBin)
summary(ZINB)


#look at model residuals--Is the model appropriate for the data? yes.

simulationOutput<-simulateResiduals(fittedModel = ZINB, plot = F)
plot(simulationOutput)
plotQQunif(simulationOutput) # 


# CBOH ----------------------------------------------------------------------



Poisson <-
  glmmTMB(
    Count ~Year,
    family = poisson,
    data = CBOH
  )

NegBin <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = CBOH
  )

ZINB <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = CBOH,
    ziformula = ~ 1
  )

summary(Poisson)
summary(NegBin)
summary(ZINB)

#look at model residuals--Is the model appropriate for the data? yes.

simulationOutput<-simulateResiduals(fittedModel = ZINB, plot = F)
plot(simulationOutput)
plotQQunif(simulationOutput) # 


# CBOD ----------------------------------------------------------------------

NegBin <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = CBOD
  )
summary(NegBin)

# UGOH --------------------------------------------------------------------

NegBin <-
  glmmTMB(
    Count ~ Year,
    family = nbinom1,
    data = UGOH
  )
summary(NegBin)
