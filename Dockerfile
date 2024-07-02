FROM postgres:latest
RUN apt-get update && apt-get install -y r-base libpq-dev
RUN R -e "install.packages('RPostgreSQL')"
WORKDIR /root/codice