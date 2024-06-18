#!/bin/bash
#copia tutto il progetto sul container database
podman cp $(pwd) database:/home