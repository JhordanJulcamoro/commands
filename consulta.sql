COPY (
    SELECT *
    FROM tp_cargadescarga
    WHERE id >= 49078
) TO STDOUT DELIMITER ',' CSV HEADER;
