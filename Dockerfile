FROM rocker/shiny:latest

WORKDIR /

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    curl

# See https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-2017&tabs=ubuntu18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline

RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql18 \
    mssql-tools18 \
    unixodbc-dev \
    libgssapi-krb5-2

# Downloads version 1.1.1h of OpenSSL to resolve the issue
# with MS SQL ODBC connector not authenticating properly

# See: https://code.luasoftware.com/tutorials/linux/upgrade-openssl-on-ubuntu-20/

RUN wget https://www.openssl.org/source/openssl-1.1.1h.tar.gz && \
    tar -zxf openssl-1.1.1h.tar.gz

WORKDIR openssl-1.1.1h

RUN bash ./config && \
    make && \
    make install && \
    mv /usr/bin/openssl /usr/bin/openssl-1.1.1f && \
    ln -s /usr/local/bin/openssl /usr/bin/openssl && \
    ldconfig

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
    DT \
    devtools

# Sets the working directory to the shiny-server root folder

WORKDIR /srv/shiny-server

# Empties the shiny-server folder

RUN rm -rf *

# Copies the odbc initialization files into /etc

COPY ./build/etc/odbc.ini /etc
COPY ./build/etc/odbcinst.ini /etc

# Copies the provided default shiny-server configuration under /etc/shiny-server

COPY ./build/shiny/shiny-server.conf /etc/shiny-server

# Copies the local R scripts (necessary to initialize the app) in a folder under /srv/shiny-server

COPY ./update_libs.R .
COPY ./initialize_data.R .

# External argument(s)

ARG GITLAB_AUTH_TOKEN
ARG DOCKER_DB_USERNAME
ARG DOCKER_DB_PASSWORD

# Environment variables

#ENV _R_SHLIB_STRIP_=true
ENV GITLAB_AUTH_TOKEN=$GITLAB_AUTH_TOKEN
ENV DB_USERNAME=$DOCKER_DB_USERNAME
ENV DB_PASSWORD=$DOCKER_DB_PASSWORD

# Copies the entire structure of the Shiny app under a dedicated folder
COPY ./shiny interactive_catalogue

# Updates the R libs
RUN Rscript update_libs.R

# Initializes the catalogue data

#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN Rscript initialize_data.R

# Copies the catalogue data under the Shiny server app folder

COPY *.RData interactive_catalogue

# Sets the Shiny log level to 'TRACE', stores the environment variable in .Renviron and copies that file under the 'shiny' user folder

RUN echo SHINY_LOG_LEVEL = TRACE >> /home/shiny/.Renviron && chown shiny.shiny /home/shiny/.Renviron

# Removes an unnecessary directory and files under the Shiny app folder

RUN rm -rf *.R

# Continues configuring Shiny

RUN echo "shiny:pass" | chpasswd
RUN adduser shiny sudo

# See: https://stackoverflow.com/questions/61125475/application-logs-to-stdout-with-shiny-server-and-docker

ENV SHINY_LOG_STDERR=1
ENV SHINY_LOG_LEVEL=DEBUG

# User running the Shiny server

USER shiny

# TCP/IP Port

EXPOSE 3838

# Starts Shiny

CMD ["/usr/bin/shiny-server"]
