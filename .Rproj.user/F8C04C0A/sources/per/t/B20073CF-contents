FROM rocker/shiny:latest

# Environment variables

ENV _R_SHLIB_STRIP_=true

WORKDIR /

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    unixodbc \
    fonts-dejavu

# Empties the shiny-server folder
RUN rm -rf /srv/shiny-server/*

# Copies the provided default shiny-server configuration under /etc/shiny-server
COPY ./shiny/conf/shiny-server.conf /etc/shiny-server

# Copies the locally available R libs in a folder under /srv/shiny-server
COPY ./libs /srv/shiny-server

# Installs all required R packages (and their dependencies) starting from those hat are available on the remote repo
# and then from the locally available libs (for the time being)

RUN install2.r --error --skipinstalled \
    stringr \
    openxlsx \
    data.table \
    flextable \
    officer \
    odbc \
    shiny \
    shinyjs \
    shinyWidgets \
    shinycssloaders \
    DT


RUN R -e "install.packages('/srv/shiny-server/iccat.pub.base_0.1.0.tar.gz', repos = NULL, type='source')"
RUN R -e "install.packages('/srv/shiny-server/iccat.pub.data_0.1.0.tar.gz', repos = NULL, type='source')"
RUN R -e "install.packages('/srv/shiny-server/iccat.dev.base_0.1.0.tar.gz', repos = NULL, type='source')"
RUN R -e "install.packages('/srv/shiny-server/iccat.dev.data_0.1.0.tar.gz', repos = NULL, type='source')"

# Copies the entire structure of the Shiny app under a dedicated folder
COPY ./shiny /srv/shiny-server/interactive_catalogue

# Sets the Shiny log level to 'TRACE', stores the environment variable in .Renviron and copies that file under the 'shiny' user folder
RUN echo SHINY_LOG_LEVEL=TRACE >> /home/shiny/.Renviron && chown shiny.shiny /home/shiny/.Renviron

# Removes an unnecessary directory under the Shiny app folder
RUN rm -rf /srv/shiny-server/interactive_catalogue/conf
RUN rm -rf /srv/shiny-server/interactive_catalogue/libs

# Continues configuring Shiny
RUN echo "shiny:pass" | chpasswd
RUN adduser shiny sudo

# See: https://stackoverflow.com/questions/61125475/application-logs-to-stdout-with-shiny-server-and-docker
ENV SHINY_LOG_STDERR = 1
ENV SHINY_LOG_LEVEL = DEBUG

# User running the Shiny server
USER shiny

# TCP/IP Port
EXPOSE 3838

# Starts Shiny
CMD ["/usr/bin/shiny-server"]
