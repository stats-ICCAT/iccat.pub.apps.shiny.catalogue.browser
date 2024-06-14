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
                  UI_select_input("species", "Species", ALL_SPECIES, auto_select_first = TRUE)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  UI_select_input("stocks", "Stock(s)", ALL_STOCK_AREAS)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  UI_select_input("flags", "Flag(s)", ALL_FLAGS)
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  UI_select_input("gearGroups", "Gear group(s)", ALL_GEAR_GROUPS)
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
