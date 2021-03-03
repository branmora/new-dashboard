library(dplyr)
library(shiny)
library(tidyr)
library(highcharter)
library(data.table)
library(tidyquant)
library(formattable)
library(jsonlite)

# Colors
customGreen0 = "#DeF7E9"
customGreen = "#71CA97"
customRed = "#ff7f7f"



shinyUI(fixedPage(
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    titlePanel(title=div(img(src="logo.png", style="width: 500px"), align = "center")),
    h2("Coronavirus en Cusco: Análisis situacional", align = "center"),
    p(class = "first-p", "Actualizado Febrero 26, 2021, 12:50 ", align = "center"),
    br(),
    tabPanel("Gráfico",highchartOutput("highchart1")),
    br(),
    formattableOutput("table"),
    br(),
    h5("15 nuevos fallecimientos covid y 200 casos nuevos fueron reportados en el Cusco el 25 de febrero. En la anterior semana, ha habido un promedio de 300 casos por dia, una reducción de 30 por ciento del promedio de dos semanas anteriores. Hasta el día viernes, mas de 30000 personas han sido infactadas con el coronavirus según la información oficial de GERESA."),
    br(),
    tabPanel("Mapa",highchartOutput("map_total_positivo")),
    br(),
    h3("El estado del Virus"),
    h5("Actualizado al xx de febrero"),
    br(),
    h5("El Cusco tiene un promedio de")
))
