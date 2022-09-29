#!/usr/bin/env bash

tar Oxvzf data/ghcnd_all.tar.gz | grep "PRCP" | gzip -f > data/ghcnd_concat.gz 