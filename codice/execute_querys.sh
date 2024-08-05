#!/bin/bash
# Script per eseguire tutte le query e salvare i risultati in file di testo
for file in query/*.sql; do
    echo "Executing $file"
    psql -U postgres -h "0.0.0.0" -p "5432" -d gestionevoli -f $file > query/result_$(basename $file).txt
done