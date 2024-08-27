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

  observeEvent(input$resetFilters, { session$reload() })

  catalogue_data = reactive({
    DEBUG("CD")

    INFO("== Filtering data - START ==")

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

      first_year = input$years[1]
      last_year  = input$years[2]

      CA = CA[Year >= first_year & Year <= last_year]

      start = Sys.time()

      # Updates the fishery ranks...

      FR = CA[DSet == "1-t1", .(Qty = sum(Qty, na.rm = TRUE)), keyby = .(DSet, Species, FlagName, Status, Stock, GearGrp)]
      FR = FR[, avgQty := Qty / (last_year - first_year + 1)]
      FR = FR[, FisheryRank := frank(-avgQty, ties.method = "min")][order(FisheryRank)]

      FR[, avgQtyRatio    := avgQty / sum(avgQty)]
      FR[, avgQtyRatioCum := cumsum(avgQtyRatio)]

      INFO(paste0("Filtered FR rows: ", nrow(FR)))
      INFO("Preparing catalogue...")

      CA$Year =
        factor(
          CA$Year,
          labels = first_year:last_year,
          levels = first_year:last_year,
          ordered = TRUE
        )

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

    INFO("== Filtering data - END ==")

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
      INFO("== Producing output - START ==")

      validate(need(!is.null(input$species), "Please select at least one species!"))

      filtered_catalogue = filtered_catalogue_data()

      validate(
        need(!is.null(filtered_catalogue) & nrow(filtered_catalogue) > 0, "Current filtering criteria do not identify any record!")
      )

      future_promise(packages = "flextable", {
        INFO("Catalogue (flex)table preparation...")

        start = Sys.time()

        catalogue_table =
          catalogue.viz.table(filtered_catalogue, truncate_years = FALSE,
                              flag_separator_width = 2,
                              default_font_size = 8,
                              default_h_padding = 2, values_h_padding = 5) %>%
          padding(part = "header", padding.top = 5, padding.bottom = 5) %>%
          font(part = "all", fontname = "Arial")


        end = Sys.time()

        INFO(paste0("Catalogue (flex)table preparation: ", end - start))

        INFO("== Producing output - END ==")

        return(htmltools_value(catalogue_table, ft.align = "left"))
      })
    })

  output$downloadData = downloadHandler(
    filename = function() {
      components = c(paste0(input$species,    collapse = "+"),
                     paste0(input$stocks,     collapse = "+"),
                     paste0(input$flags,      collapse = "+"),
                     paste0(input$gearGroups, collapse = "+"),
                     paste0(input$years,      collapse = "-"))

      components = components[which(components != "")]

      paste0("ICCAT_SCRS_", str_replace_all(META$LAST_UPDATE, "\\-", ""), "_catalogue_", paste0(components, collapse = "_"), ".csv.gz")
    },
    content = function(file) {
      write.csv(filtered_catalogue_data(), gzfile(file), row.names = FALSE, na = "")
    }
  )
}
