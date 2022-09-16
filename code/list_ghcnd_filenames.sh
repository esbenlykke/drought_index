#!/usr/bin/env bash

echo "filename" > data/ghcnd_all_filenames.txt
tar tvf data/ghcnd_all.tar.gz | grep ".dly" >> data/ghcnd_all_filenames.txt