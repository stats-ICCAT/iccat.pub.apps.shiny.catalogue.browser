library(iccat.dev.data)

LAST_N_YEARS = 100

CA_ALL = catalogue.fn_genT1NC_CatalSCRS(species_codes    = NULL,
                                        stock_area_codes = NULL,
                                        year_from        = NA,
                                        year_to          = NA,
                                        db_connection    = DB_STAT(username = Sys.getenv("DB_USERNAME"),
                                                                   password = Sys.getenv("DB_PASSWORD")))

save(list = "CA_ALL", file = "./CA_all.RData")

print(getwd())
