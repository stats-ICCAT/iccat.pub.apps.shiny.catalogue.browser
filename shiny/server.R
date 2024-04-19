server = function(input, output, session) {
  #observe({
  #  print("ObsF")
  #  updateSelectInput(session, "flag",
  #                    label = "Flag(s)",
  #                    choices  = sort(unique(catalogue_data()$FlagName))
  #  )
  #})

  #observe({
  #  print("ObsG")
  #  updateSelectInput(session, "gearGroup",
  #                    label = "Gear group(s)",
  #                    choices  = sort(unique(catalogue_data()$GearGrp))
  #  )
  #})

  catalogue_data = reactive({
    DEBUG("CD")
    INFO(paste0("Species: ", paste0(input$species, collapse = ", ")))
    INFO(paste0("Stock  : ", paste0(input$stocks, collapse = ", ")))

    start_all = Sys.time()

    catalog = NULL

    tryCatch({
      CA = CA_ALL

      if(!is.null(input$species)) {
        CA = CA[Species %in% input$species]
      }

      if(!is.null(input$stocks)) {
        CA = CA[Stock %in% input$stocks]
      }

      if(!is.null(input$flags)) {
        CA = CA[FlagName %in% input$flags]
      }

      if(!is.null(input$gearGroups)) {
        CA = CA[GearGrp %in% input$gearGroups]
      }

      last_year  = max(CA$Year)
      first_year = last_year - input$num_years + 1

      CA = CA[Year >= first_year]

      start = Sys.time()

      FR = CA[DSet == "1-t1", .(Qty = sum(Qty, na.rm = TRUE)), keyby = .(DSet, Species, FlagName, Status, Stock, GearGrp)]
      FR = FR[, avgQty := Qty / (last_year - first_year + 1)]
      FR = FR[, FisheryRank := frank(-avgQty, ties.method = "min")][order(FisheryRank)]

      FR[, avgQtyRatio    := avgQty / sum(avgQty)]
      FR[, avgQtyRatioCum := cumsum(avgQtyRatio)]

      INFO(paste0("Filtered FR rows: ", nrow(FR)))
      INFO("Preparing catalogue...")

      catalog =
        catalogue.compile(
          FR[avgQtyRatioCum <= input$max_perc_cum / 100.0],
          CA
        )
        #catalog(
        #  input$species,
        #  input$stock,
        #  input$num_years
        #)
      },
      error = function(e) {
        ERROR(e)
      }
    )

    end = Sys.time()

    INFO(paste0("Preparing catalogue: ", end - start))

    INFO(paste0("Catalog size: ", nrow(catalog)))

    end_all = Sys.time()

    INFO(paste0("Completing preparation of catalog data: ", end_all - start_all))

    return(catalog)
  })

  filtered_catalogue_data = reactive({
    DEBUG("FCD")

    start = Sys.time()

    filtered_catalogue = catalogue_data()

    if(is.null(filtered_catalogue)) return(NULL)

    INFO(paste0("Flags: ", paste0(input$flag, collapse = ",")))
    INFO(paste0("Gears: ", paste0(input$gearGroup, collapse = ",")))

    if(length(input$flags) > 0)      filtered_catalogue = filtered_catalogue[FlagName %in% input$flags]
    if(length(input$gearGroups) > 0) filtered_catalogue = filtered_catalogue[GearGrp  %in% input$gearGroups]

    end = Sys.time()

    INFO(paste0("Filter catalog data: ", end - start))

    return(filtered_catalogue)
  })

  output$catalogue =
    renderUI({
      DEBUG("RUI")

      filtered_catalogue = filtered_catalogue_data()

      if(is.null(filtered_catalogue) || nrow(filtered_catalogue) == 0) return("No data available!")

      INFO("Catalogue (flex)table preparation...")

      start = Sys.time()

      catalogue_table =
        catalogue.viz.table(filtered_catalogue) %>%
        fontsize(part = "all", size = 8) %>%
        padding( part = "all", padding = 2)

      end = Sys.time()

      INFO(paste0("Catalogue (flex)table preparation: ", end - start))

      return(htmltools_value(catalogue_table, ft.align = "left"))
    })

  output$downloadData = downloadHandler(
    filename = function() {
      components = c(paste0(input$species,    collapse = "+"),
                     paste0(input$stocks,     collapse = "+"),
                     paste0(input$flags,      collapse = "+"),
                     paste0(input$gearGroups, collapse = "+"),
                     input$num_years)

      components = components[which(components != "")]

      paste0("catalogue_", paste0(components, collapse = "_"), ".csv")
    },
    content = function(file) {
      write.csv(filtered_catalogue_data(), file, row.names = FALSE, na = "")
    }
  )
}
