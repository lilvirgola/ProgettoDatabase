#!/bin/bash
# Script per generare tutti i grafici delle analisi dai file R
for file in analisi/*.r; do
    echo "Executing $file"
    R -e "source('$file')"
done