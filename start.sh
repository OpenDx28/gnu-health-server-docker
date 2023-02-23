#!/usr/bin/env bash
# "postgres" below is the name of the container running PostgreSQL
createdb -h postgres health
cdexe
python3 ./trytond-admin --all --database=health
cd /home/gnuhealth
./start_gnuhealth.sh
