CREATE TABLE day08 (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    line TEXT NOT NULL
);

WITH
    input AS (
        SELECT id, i[1] AS inputs, i[2] AS outputs
        FROM day08 CROSS JOIN regexp_split_to_array(line, ' \| ') AS t(i)
    ),
    counts AS (
        SELECT id, j, count(*) AS count
        FROM input CROSS JOIN regexp_split_to_table(inputs, '') AS t2(j)
        WHERE j <> ' ' GROUP BY id, j
    ),
    find_147 AS (
        SELECT id, jsonb_object_agg(char_length(i), i) AS chars147
        FROM input CROSS JOIN regexp_split_to_table(inputs, ' ') AS t(i)
        WHERE char_length(i) IN (2, 3, 4) GROUP BY id
    ),
    find_a AS (
        SELECT id, jsonb_build_object(chars7, 'a') AS wires FROM find_147
            CROSS JOIN regexp_split_to_table(chars147->>'3', '') AS t(chars7)
            LEFT JOIN regexp_split_to_table(chars147->>'2', '') AS t2(chars1) ON chars7 = chars1
        WHERE chars1 IS NULL
    ),
    find_bef AS (
        SELECT id, jsonb_object_agg(j, CASE count WHEN 4 THEN 'e' WHEN 6 THEN 'b' ELSE 'f' END) AS wires
        FROM counts WHERE count IN (4, 6, 9) GROUP BY id
    ),
    find_dg AS (
        SELECT id, jsonb_object_agg(j, CASE strpos(chars147->>'4', j) WHEN 0 THEN 'g' ELSE 'd' END) AS wires
        FROM counts INNER JOIN find_147 USING (id) WHERE count = 7 GROUP BY id
    ),
    wires AS (
        SELECT id, find_dg.wires || find_bef.wires || find_a.wires AS wires
        FROM find_dg INNER JOIN find_bef USING (id) INNER JOIN find_a USING (id)
    ),
    outputs AS (
        SELECT id, i, jsonb_object_agg(coalesce(wires.wires->>char, 'c'), '') AS d
        FROM input INNER JOIN wires USING(id)
        CROSS JOIN regexp_split_to_table(outputs, ' ') WITH ORDINALITY AS t(n, i)
        CROSS JOIN regexp_split_to_table(n, '') AS t2(char) GROUP BY id, i
    ),
    digits AS (
        SELECT jsonb_object_agg(n, '') AS d, x FROM (VALUES
            ('abcefg', 0), ('cf', 1), ('acdeg', 2), ('acdfg', 3), ('bcdf', 4),
            ('abdfg', 5), ('abdefg', 6), ('acf', 7), ('abcdefg', 8), ('abcdfg', 9)) AS t(w, x)
        CROSS JOIN regexp_split_to_table(w, '') AS t2(n) GROUP BY x
    ),
    xs AS (
        SELECT string_agg(x::TEXT, '' ORDER BY i) AS x FROM outputs INNER JOIN digits USING (d) GROUP BY id
    )
SELECT sum(x::INT) FROM xs;
