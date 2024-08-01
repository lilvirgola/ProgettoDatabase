#!/bin/bash
psql -U postgres -h "0.0.0.0" -p "5432" -d gestionevoli -f creaDB.sql
R -e "source('popolare.r')"