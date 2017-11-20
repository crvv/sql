WITH RECURSIVE
    input(i) AS (SELECT 'hello'),
    data(x) AS (SELECT '{}'::SMALLINT[]),
    program(p) AS (SELECT '++++++++[>++++++++<-]>[<++++>-]
+<[>-<
    Not zero so multiply by 256 again to get 65536
    [>++++<-]>[<++++++++>-]<[>++++++++<-]
    +>[>
        # Print "32"
        ++++++++++[>+++++<-]>+.-.[-]<
    <[-]<->] <[>>
        # Print "16"
        +++++++[>+++++++<-]>.+++++.[-]<
<<-]] >[>
    # Print "8"
    ++++++++[>+++++++<-]>.[-]<
<-]<
# Print " bit cells\n"
+++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
>>.++.+++++++..<-.>>-
Clean up used cells.
[[-]<]'),
    instructions(i, char) AS (SELECT (row_number() OVER())::INT AS i, char FROM program CROSS JOIN regexp_split_to_table(program.p, '') AS t(char)),
    walk_list(i, char, pair, stack) AS (
        SELECT 0, '', 0, '{}'::INT[]
        UNION
        SELECT
            list.i, list.char,
            stack[array_length(stack, 1)],
            CASE list.char
            WHEN '[' THEN stack || list.i
                WHEN ']' THEN stack[:array_length(stack, 1)-1]
            ELSE stack END
        FROM walk_list AS walk INNER JOIN instructions AS list ON list.i = walk.i +1
    ),
    jump_table(src, dst) AS (
        SELECT i, pair FROM walk_list WHERE char = ']'
        UNION SELECT pair, i FROM walk_list WHERE char = ']'),
    run(pc, dp, data, input, output) AS (
        SELECT 1 AS pc, 1 AS dp,
            data.x AS cells, input.i, '' AS output FROM data CROSS JOIN input
        UNION
        SELECT
            CASE instruction
                WHEN '[' THEN (CASE coalesce(data[dp], 0) WHEN 0 THEN (SELECT dst+1 FROM jump_table WHERE src = pc) ELSE pc+1 END)
                WHEN ']' THEN (CASE coalesce(data[dp], 0) WHEN 0 THEN pc+1 ELSE (SELECT dst+1 FROM jump_table WHERE src = pc) END)
                ELSE pc+1 END,
            CASE instruction WHEN '>' THEN dp + 1 WHEN '<' THEN dp - 1 ELSE dp END,
            data[:dp-1] || (CASE instruction
                            WHEN '+' THEN CASE data[dp] WHEN 255 THEN 0 ELSE coalesce(data[dp], 0) + 1 END
                            WHEN '-' THEN CASE coalesce(data[dp], 0) WHEN 0 THEN 255 ELSE data[dp] - 1 END
                            WHEN ',' THEN ascii(substring(input FROM 1 FOR 1))
                            ELSE data[dp] END)::SMALLINT
            || data[dp+1:],
            CASE instruction WHEN ',' THEN substring(input FROM 2) ELSE input END,
            CASE instruction WHEN '.' THEN output || CASE data[dp] WHEN 0 THEN '\0' ELSE chr(data[dp]) END ELSE output END
        FROM run CROSS JOIN LATERAL (SELECT substring(p FROM pc FOR 1) FROM program) AS p(instruction)
        WHERE instruction <> ''
    )
SELECT * FROM run ORDER BY pc DESC LIMIT 1;
