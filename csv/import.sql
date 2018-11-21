CREATE FUNCTION pg_temp.import_csv(filename TEXT) RETURNS VOID AS $$
    DECLARE
        tablename TEXT;
    BEGIN
        SELECT n INTO tablename FROM regexp_split_to_table(filename, '\.|/') WITH ORDINALITY AS t(n, i) ORDER BY i DESC OFFSET 1 LIMIT 1;
        EXECUTE format('DROP TABLE IF EXISTS %I', tablename);
        CREATE TEMP TABLE csv_header (header TEXT);
        EXECUTE format('COPY csv_header FROM PROGRAM ''head -n 1 %I''', filename);
        EXECUTE (SELECT format('CREATE TABLE %I (', tablename) || string_agg(format('%I TEXT', col), ', ' ORDER BY i ASC) || ')'
            FROM csv_header
            CROSS JOIN regexp_split_to_table(header, ',') WITH ORDINALITY AS t(col, i));
        EXECUTE format('COPY %I FROM %L WITH (FORMAT csv, HEADER TRUE)', tablename, filename);
    END
$$ LANGUAGE plpgsql;

SELECT pg_temp.import_csv(:'csvfile');
