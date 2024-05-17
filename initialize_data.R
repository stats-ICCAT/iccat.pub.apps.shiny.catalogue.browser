library(iccat.dev.data)

CA_ALL = catalogue.fn_genT1NC_CatalSCRS(species_codes    = NULL,
                                        stock_area_codes = NULL,
                                        year_from        = NA,
                                        year_to          = NA,
                                        db_connection    = DB_STAT())

save(list = "CA_ALL", file = "./shiny/CA_all.RData")
