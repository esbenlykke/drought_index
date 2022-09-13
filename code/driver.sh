#!/usr/bin/env bash

# get all daily data from weather stations and generate list of stations
code/get_ghcnd_data.sh ghcnd_all.tar.gz 
code/get_ghcnd_all_filenames.sh

# get listing of types of data found at each weather station
code/get_ghcnd_data.sh ghcnd-inventory.txt

# get metadata for each weather station
code/get_ghcnd_data.sh ghcnd-stations.txt 

