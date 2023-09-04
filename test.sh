#!/bin/bash
# backup-postgresql-without-huge-tables.sh
# by MS4M

# psql -h 127.0.0.1 -p 5437 -U postgres -d ControlSenseDB -c "COPY (SELECT id, id_cargadescarga, id_equipo, id_trabajador FROM tp_cargadescarga ORDER BY id DESC LIMIT 10) TO STDOUT WITH CSV" | gzip -1 > tp_cargadescarga.csv.gz


# (echo "id,id_cargadescarga,id_equipo,id_trabajador"; psql -h 127.0.0.1 -p 5437 -U postgres -d ControlSenseDB -t -c "COPY 
#         (   SELECT id, id_cargadescarga, id_equipo, id_trabajador 
#                 FROM tp_cargadescarga ORDER BY id DESC LIMIT 10
#         ) 
#     TO STDOUT WITH CSV DELIMITER ','"
#     ) | gzip -1 > tp_cargadescarga.csv.gz

(echo "id, id_cargadescarga, id_equipo, id_trabajador, id_palas, id_palanext, id_trabajadordescarga, tiem_llegada, tiem_cuadra, tiem_cuadrado, tiem_carga, tiem_acarreo, tiem_cola, tiem_retro, tiem_descarga, tiem_viajando, tonelaje, tonelajevims, id_descarga, id_mezcla, yn_estado, yn_operador, id_viajevacio, id_viajecargado, id_crewcarga, id_crewdescarga, ids_resumen, id_factor, efhcargado, efhvacio, distinclinadacargado, distinclinadavacia, disthorizontalcargado, disthorizontalvacia, distrealcargado, distrealvacio, coorxdesc, coorydesc, coorzdesc, idzonaseccarga, idzonasecdescarga, tipodescargaidentifier, tonelajevvanterior, tonelajevvposterior, aactualtemp, dumpreal, loadreal, tiem_creac, tiem_update, tiem_elimin, velocidadvimscargado, velocidadvimsvacio, velocidadgpscargado, velocidadgpsvacio, tonelajevimsretain, nivelcombuscargado, nivelcombusdescargado, llegadareal, cuadrareal, cuadradoreal, acarreoreal, colareal, retroreal, viajandoreal, volumen, aplicafactor_vol, tiem_listo, listoreal, coorzniveldescarga, id_turnocarga, id_turnodescarga, tiem_esperando, esperandoreal, user_create, user_edit, user_eliminate, is_report, is_fixed, ticket, guia, origen_tracking, efh_factor_loaded, efh_factor_empty"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_cargadescarga, id_equipo, id_trabajador, id_palas, id_palanext, id_trabajadordescarga, tiem_llegada, tiem_cuadra, tiem_cuadrado, tiem_carga, tiem_acarreo, tiem_cola, tiem_retro, tiem_descarga, tiem_viajando, tonelaje, tonelajevims, id_descarga, id_mezcla, yn_estado, yn_operador, id_viajevacio, id_viajecargado, id_crewcarga, id_crewdescarga, ids_resumen, id_factor, efhcargado, efhvacio, distinclinadacargado, distinclinadavacia, disthorizontalcargado, disthorizontalvacia, distrealcargado, distrealvacio, coorxdesc, coorydesc, coorzdesc, idzonaseccarga, idzonasecdescarga, tipodescargaidentifier, tonelajevvanterior, tonelajevvposterior, aactualtemp, dumpreal, loadreal, tiem_creac, tiem_update, tiem_elimin, velocidadvimscargado, velocidadvimsvacio, velocidadgpscargado, velocidadgpsvacio, tonelajevimsretain, nivelcombuscargado, nivelcombusdescargado, llegadareal, cuadrareal, cuadradoreal, acarreoreal, colareal, retroreal, viajandoreal, volumen, aplicafactor_vol, tiem_listo, listoreal, coorzniveldescarga, id_turnocarga, id_turnodescarga, tiem_esperando, esperandoreal, user_create, user_edit, user_eliminate, is_report, is_fixed, ticket, guia, origen_tracking, efh_factor_loaded, efh_factor_empty 
            from tp_cargadescarga
            where id in (
                select idcargadescarga
                from camionesarregloop
            )
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > tp_cargadescarga.csv.gz


(echo "id, id_palas, id_equipo, id_trabajador, id_crew, id_locacion, id_poligono, id_tandem, id_locacionnext, id_poligononext, id_descarganext, id_tandemnext, tiem_cargado, isspot, tiem_esperando, bool_estado, bool_equipo_next, cola, tiem_creac, tiem_update, tiem_elimin"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_palas, id_equipo, id_trabajador, id_crew, id_locacion, id_poligono, id_tandem, id_locacionnext, id_poligononext, id_descarganext, id_tandemnext, tiem_cargado, isspot, tiem_esperando, bool_estado, bool_equipo_next, cola, tiem_creac, tiem_update, tiem_elimin
            from tp_palas
            where id in (
                select idtablatppalas
                from camionesarregloop
            )
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > tp_palas.csv.gz

(echo "id, id_estados, id_equipo, id_detal_estado, id_trabajador, tiempo_inicio, tiempo_estimado, idnodo, idenestado, comentario, ids_resumen, tiem_creac, tiem_update, tiem_elimin, id_detal_estado2, idubicacionsupervisor, tipoubicacionsupervisor, end_time, id_main_status, is_processed, duration, start_horometer, end_horometer, id_tp_estado_next, id_approved, id_request_trabajador, id_request_usuario, id_change_user"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_estados, id_equipo, id_detal_estado, id_trabajador, tiempo_inicio, tiempo_estimado, idnodo, idenestado, comentario, ids_resumen, tiem_creac, tiem_update, tiem_elimin, id_detal_estado2, idubicacionsupervisor, tipoubicacionsupervisor, end_time, id_main_status, is_processed, duration, start_horometer, end_horometer, id_tp_estado_next, id_approved, id_request_trabajador, id_request_usuario, id_change_user
            from tp_estados where  id in  (
                select tp.id
                from ts_equipos e
                        left join tp_estados tp on tp.id = (
                    select ee.id
                    from tp_estados ee
                    where ee.tiem_elimin is null
                    and ee.id_equipo = e.id_equipo
                    order by ee.tiempo_inicio desc
                    limit 1
                )
            where e.isflota = false
            and e.tiem_elimin is null)
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > tp_estados.csv.gz

