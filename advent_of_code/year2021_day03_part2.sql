WITH RECURSIVE
     oxygen AS (
         SELECT id, value, 1 AS index, (substr(value, 1, 1) = '1') = (sum(substr(value, 1, 1)::int) OVER () >= (count(*) OVER())::FLOAT/2) AS remain
         FROM day03.inputs
         UNION
         SELECT id, value, index+1, (substr(value, index+1, 1) = '1') = (sum(substr(value, index+1, 1)::int) OVER () >= (count(*) OVER())::FLOAT/2)
         FROM oxygen WHERE remain AND char_length(value) > index
     ),
     co2 AS (
         SELECT id, value, 1 AS index, (substr(value, 1, 1) = '0') = (sum(substr(value, 1, 1)::int) OVER () >= (count(*) OVER())::FLOAT/2) AS remain
         FROM day03.inputs
         UNION
         SELECT id, value, index+1, (substr(value, index+1, 1) = '0') = (sum(substr(value, index+1, 1)::int) OVER () >= (count(*) OVER())::FLOAT/2)
         FROM co2 WHERE remain AND char_length(value) > index
     )
SELECT lpad((SELECT value FROM oxygen WHERE remain ORDER BY index DESC, id DESC LIMIT 1), 32, '0')::bit(32)::int *
       lpad((SELECT value FROM co2 WHERE remain ORDER BY index DESC, id DESC LIMIT 1), 32, '0')::bit(32)::int;
