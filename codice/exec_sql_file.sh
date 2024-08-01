#!/bin/bash
# Script per eseguire un file sql
if [ -z "$1" ]; then
    echo "Usage: $0 <file.sql>"
    exit 1
fi
psql -U postgres -h "0.0.0.0" -p "5432" -d gestionevoli -f $1