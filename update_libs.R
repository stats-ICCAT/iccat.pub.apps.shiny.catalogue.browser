library(devtools)

GITHUB_AUTH_TOKEN = Sys.getenv("GITHUB_AUTH_TOKEN")

devtools::install_github("iccat-r-tests/libs/public/iccat.pub.base", auth_token = GITHUB_AUTH_TOKEN, dependencies = FALSE)
devtools::install_github("iccat-r-tests/libs/public/iccat.pub.data", auth_token = GITHUB_AUTH_TOKEN, dependencies = FALSE)
devtools::install_github("iccat-r-tests/libs/public/iccat.pub.aes",  auth_token = GITHUB_AUTH_TOKEN, dependencies = FALSE)
devtools::install_github("iccat-r-tests/libs/public/iccat.pub.viz",  auth_token = GITHUB_AUTH_TOKEN, dependencies = FALSE)

q(save = "no")
