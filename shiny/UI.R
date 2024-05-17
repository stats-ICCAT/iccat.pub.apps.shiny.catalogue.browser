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
              width = 2,
              fluidRow(
                column(
                  width = 12,
                  sliderInput("years", "Year range",
                              width = "100%",
                              min = MIN_YEAR, max = MAX_YEAR,
                              value = c(max(MIN_YEAR, MAX_YEAR - 30 + 1), MAX_YEAR),
                              sep = "",
                              step  = 1)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  virtualSelectInput("species", "Species",
                                     width = "100%",
                                     multiple = TRUE,
                                     autoSelectFirstOption = TRUE,
                                     choices = ALL_SPECIES,
                                     search = TRUE,
                                     showValueAsTags = TRUE)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  virtualSelectInput("stocks", "Stock(s)",
                                     width = "100%",
                                     multiple = TRUE,
                                     choices = ALL_STOCK_AREAS,
                                     search = TRUE,
                                     showValueAsTags = TRUE)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  virtualSelectInput("flags", "Flag(s)",
                                     width = "100%",
                                     multiple = TRUE,
                                     choices = ALL_FLAGS,
                                     search = TRUE,
                                     showValueAsTags = TRUE)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  virtualSelectInput("gearGroups", "Gear group(s)",
                                     width = "100%",
                                     multiple = TRUE,
                                     choices = ALL_GEAR_GROUPS,
                                     search = TRUE,
                                     showValueAsTags = TRUE)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  sliderInput("max_perc_cum", "Max. % cumulative catches",
                               width = "100%",
                               min = 0, max = 100, value = 95,
                               step = .5)
                )
              )
            ),
            column(
              width = 10,
              uiOutput("catalogue")
            )
          )
        )
      )
    )
  )
}
