CREATE FUNCTION pg_temp.create_csv_table(tablename TEXT) RETURNS VOID AS $$
    BEGIN
        EXECUTE format('DROP TABLE IF EXISTS %I', tablename);
        EXECUTE (SELECT format('CREATE TABLE %I (', tablename) || string_agg(format('%I TEXT', col), ', ' ORDER BY i ASC) || ')'
            FROM csv_header
            CROSS JOIN regexp_split_to_table(header, ',') WITH ORDINALITY AS t(col, i));
    END
$$ LANGUAGE plpgsql;

SELECT pg_temp.create_csv_table(:'table');
