#!/bin/bash
psql -U postgres -d gestionevoli -f 0_creaDB.sql
R -e "source('popolare.r')"