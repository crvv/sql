#!/bin/bash

if [ "$1" = '' ]; then
    echo $0 filename.csv
    exit 1
fi

FILE=$(realpath $1)
TABLE=$(sed 's/\.csv//' <<<$(basename $FILE))

cd $(dirname $0)

psql \
    -v "table=$TABLE" \
    -c 'CREATE TEMP TABLE csv_header (header TEXT) WITH OIDS' \
    -c "\\copy csv_header FROM PROGRAM 'head -n 1 $FILE'" \
    -f table.sql \
    -c "\\copy $TABLE FROM $FILE WITH (FORMAT csv, HEADER TRUE)"
