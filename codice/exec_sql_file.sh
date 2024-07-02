#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <file.sql>"
    exit 1
fi
psql -U postgres -d gestionevoli -f $1