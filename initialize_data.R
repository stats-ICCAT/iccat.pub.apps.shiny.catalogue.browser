library(iccat.dev.data)

META = list(LAST_UPDATE = as.Date(Sys.Date(), format = "%Y-%M-%d"))
save(list = "META", file = "./shiny/META.RData")

CA_ALL = catalogue.fn_genT1NC_CatalSCRS(species_codes    = NULL,
                                        stock_area_codes = NULL,
                                        year_from        = 1950,
                                        year_to          = NA,
                                        db_connection    = DB_STAT())

save(list = "CA_ALL", file = "./shiny/CA_all.RData")
