ui = function() {
  TITLE = "ICCAT interactive species catalogue v1.0"
  return(
    fluidPage(
      title = TITLE,
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
      tags$div(
        class = "main-container",
        conditionalPanel(
          condition = "$('html').hasClass('shiny-busy')",
          tags$div(id = "glasspane",
                   tags$div(class = "loading", "Filtering data and preparing output...")
          )
        ),
        tags$div(
          fluidRow(
            column(
              width = 8,
              h2(
                img(src = "iccat-logo.jpg", height = "96px"),
                span(TITLE),
                downloadButton("downloadData", "Download")
              )
            )
          ),
          fluidRow(
            column(
              width = 12,
              fluidRow(
                column(
                  width = 3,
                  selectInput("species", "Species",
                              width = "100%",
                              choices = ALL_SPECIES,
                              selected = "BFT",
                              multiple = TRUE)
                ),
                column(
                  width = 2,
                  selectInput("stocks", "Stock(s)",
                              width = "100%",
                              choices = ALL_STOCK_AREAS,
                              multiple = TRUE)
                ),
                column(
                  width = 1,
                  numericInput("num_years", "No. years",
                               width = "100%",
                               min = 10,
                               value = 30,
                               step = 1)
                ),
                column(
                  width = 1,
                  numericInput("max_perc_cum", "Max. % cum.",
                               width = "100%",
                               min   =  10,
                               max   = 100,
                               value =  90,
                               step  =    .5)
                ),
                column(
                  width = 2,
                  selectInput("flags", "Flag(s)",
                              width = "100%",
                              choices = ALL_FLAGS,
                              multiple = TRUE)
                ),
                column(
                  width = 2,
                  selectInput("gearGroups", "Gear group(s)",
                              width = "100%",
                              choices = ALL_GEAR_GROUPS,
                              multiple = TRUE)
                )
              )
            )
          ),
          fluidRow(
            column(
              width = 12,
              uiOutput("catalogue")
            )
          )
        )
      )
    )
  )
}
