ui = function() {
  TITLE = paste0("ICCAT SCRS catalogue / T2CE / ", META$LAST_UPDATE)
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
                style = "margin-top: 5px !important",
                img(src = "iccat-logo.jpg", height = "48px"),
                span(TITLE)
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
              ),
              fluidRow(
                column(
                  width = 12,
                  h5(strong("Download current dataset:"))
                )
              ),
              fluidRow(
                column(
                  width = 4,
                  downloadButton("downloadData", "Filtered", style = "width: 100px")
                ),
                column(
                  width = 4,
                  span("as ", style = "vertical-align: -5px",
                       code(".csv.gz")
                  )
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  hr(),
                  span("Data last updated on:"),
                  strong(META$LAST_UPDATE)
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
