#!/bin/bash

if [ "$1" = '' ]; then
    echo $0 filename.csv
    exit 1
fi

CSVFILE=$(realpath "$1")

psql -v "csvfile=$CSVFILE" -f import.sql
