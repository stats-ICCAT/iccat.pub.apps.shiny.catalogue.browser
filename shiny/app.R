library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(data.table)
library(DT)

source("./server.R")
source("./UI.R")

shinyApp(ui, server)