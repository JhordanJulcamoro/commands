#!/bin/bash
# backup-postgresql-without-huge-tables.sh
# by MS4M

YMD=$(date "+%Y-%m-%d")

echo "Inicio de copia de seguridad - tablas `date`"

(echo "id, id_cargadescarga, id_equipo, id_trabajador, id_palas, id_palanext, id_trabajadordescarga, tiem_llegada, tiem_cuadra, tiem_cuadrado, tiem_carga, tiem_acarreo, tiem_cola, tiem_retro, tiem_descarga, tiem_viajando, tonelaje, tonelajevims, id_descarga, id_mezcla, yn_estado, yn_operador, id_viajevacio, id_viajecargado, id_crewcarga, id_crewdescarga, ids_resumen, id_factor, efhcargado, efhvacio, distinclinadacargado, distinclinadavacia, disthorizontalcargado, disthorizontalvacia, distrealcargado, distrealvacio, coorxdesc, coorydesc, coorzdesc, idzonaseccarga, idzonasecdescarga, tipodescargaidentifier, tonelajevvanterior, tonelajevvposterior, aactualtemp, dumpreal, loadreal, tiem_creac, tiem_update, tiem_elimin, velocidadvimscargado, velocidadvimsvacio, velocidadgpscargado, velocidadgpsvacio, tonelajevimsretain, nivelcombuscargado, nivelcombusdescargado, llegadareal, cuadrareal, cuadradoreal, acarreoreal, colareal, retroreal, viajandoreal, volumen, aplicafactor_vol, tiem_listo, listoreal, coorzniveldescarga, id_turnocarga, id_turnodescarga, tiem_esperando, esperandoreal, user_create, user_edit, user_eliminate, is_report, is_fixed, ticket, guia, origen_tracking, efh_factor_loaded, efh_factor_empty"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_cargadescarga, id_equipo, id_trabajador, id_palas, id_palanext, id_trabajadordescarga, tiem_llegada, tiem_cuadra, tiem_cuadrado, tiem_carga, tiem_acarreo, tiem_cola, tiem_retro, tiem_descarga, tiem_viajando, tonelaje, tonelajevims, id_descarga, id_mezcla, yn_estado, yn_operador, id_viajevacio, id_viajecargado, id_crewcarga, id_crewdescarga, ids_resumen, id_factor, efhcargado, efhvacio, distinclinadacargado, distinclinadavacia, disthorizontalcargado, disthorizontalvacia, distrealcargado, distrealvacio, coorxdesc, coorydesc, coorzdesc, idzonaseccarga, idzonasecdescarga, tipodescargaidentifier, tonelajevvanterior, tonelajevvposterior, aactualtemp, dumpreal, loadreal, tiem_creac, tiem_update, tiem_elimin, velocidadvimscargado, velocidadvimsvacio, velocidadgpscargado, velocidadgpsvacio, tonelajevimsretain, nivelcombuscargado, nivelcombusdescargado, llegadareal, cuadrareal, cuadradoreal, acarreoreal, colareal, retroreal, viajandoreal, volumen, aplicafactor_vol, tiem_listo, listoreal, coorzniveldescarga, id_turnocarga, id_turnodescarga, tiem_esperando, esperandoreal, user_create, user_edit, user_eliminate, is_report, is_fixed, ticket, guia, origen_tracking, efh_factor_loaded, efh_factor_empty 
            from tp_cargadescarga
            where tiem_llegada > (now() - INTERVAL '4 months')
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > tp_cargadescarga.csv.gz


(echo "id, id_palas, id_equipo, id_trabajador, id_crew, id_locacion, id_poligono, id_tandem, id_locacionnext, id_poligononext, id_descarganext, id_tandemnext, tiem_cargado, isspot, tiem_esperando, bool_estado, bool_equipo_next, cola, tiem_creac, tiem_update, tiem_elimin"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_palas, id_equipo, id_trabajador, id_crew, id_locacion, id_poligono, id_tandem, id_locacionnext, id_poligononext, id_descarganext, id_tandemnext, tiem_cargado, isspot, tiem_esperando, bool_estado, bool_equipo_next, cola, tiem_creac, tiem_update, tiem_elimin
            from tp_palas
            where tiem_cargado > (now() - INTERVAL '4 months')
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

echo "Fin de copia de seguridad - tablas `date`"

# CREATE SCRIPT FOR RESTORE
echo "#! /bin/bash
#RUN SCRIPT WITH USER POSTGRES
The restore started at \$(date)
#restore all users
gunzip -c globals.gz  | psql -h 127.0.0.1 -U $user_remote -w 
#restore all database 
createdb \"ControlSenseDB\" -h 127.0.0.1 -U $user_remote
gunzip -c ControlSenseDB.schema.gz  | psql -h 127.0.0.1 -U $user_remote -w -d ControlSenseDB
"> $DIR/restore.database.ControlSenseDB.sh

for file in $(ls -l $DIR_TABLES | awk '{print $9}');
do
filename=$(echo $file | cut -d" " -f2)
# CREATE SCRIPT FOR RESTORE
echo "echo \" Restore table $filename\"
gunzip -c  tables/$filename | psql -h 127.0.0.1 -U $user_remote -w -d $database">> $DIR/restore.database.$database.sh
done;


echo "echo \" Restore table tpcd\"
gunzip  ./tp_cargadescarga.csv.gz
psql -U postgres -d ControlSenseDB -t -c \"copy tp_cargadescarga(id, id_cargadescarga, id_equipo, id_trabajador, id_palas, id_palanext, id_trabajadordescarga, tiem_llegada, tiem_cuadra, tiem_cuadrado, tiem_carga, tiem_acarreo, tiem_cola, tiem_retro, tiem_descarga, tiem_viajando, tonelaje, tonelajevims, id_descarga, id_mezcla, yn_estado, yn_operador, id_viajevacio, id_viajecargado, id_crewcarga, id_crewdescarga, ids_resumen, id_factor, efhcargado, efhvacio, distinclinadacargado, distinclinadavacia, disthorizontalcargado, disthorizontalvacia, distrealcargado, distrealvacio, coorxdesc, coorydesc, coorzdesc, idzonaseccarga, idzonasecdescarga, tipodescargaidentifier, tonelajevvanterior, tonelajevvposterior, aactualtemp, dumpreal, loadreal, tiem_creac, tiem_update, tiem_elimin, velocidadvimscargado, velocidadvimsvacio, velocidadgpscargado, velocidadgpsvacio, tonelajevimsretain, nivelcombuscargado, nivelcombusdescargado, llegadareal, cuadrareal, cuadradoreal, acarreoreal, colareal, retroreal, viajandoreal, volumen, aplicafactor_vol, tiem_listo, listoreal, coorzniveldescarga, id_turnocarga, id_turnodescarga, tiem_esperando, esperandoreal, user_create, user_edit, user_eliminate, is_report, is_fixed, ticket, guia, origen_tracking, efh_factor_loaded, efh_factor_empty)  from '\$(pwd)/tp_cargadescarga.csv' DELIMITER ',' CSV HEADER;\"
">> $DIR/restore.database.$database.sh

echo "echo \" Restore table tpp\"
gunzip  ./tp_palas.csv.gz
psql -U postgres -d ControlSenseDB -t -c \"copy tp_palas(id, id_palas, id_equipo, id_trabajador, id_crew, id_locacion, id_poligono, id_tandem, id_locacionnext, id_poligononext, id_descarganext, id_tandemnext, tiem_cargado, isspot, tiem_esperando, bool_estado, bool_equipo_next, cola, tiem_creac, tiem_update, tiem_elimin)  from '\$(pwd)/tp_palas.csv' DELIMITER ',' CSV HEADER;\"
">> $DIR/restore.database.$database.sh

echo "echo \" Restore table tp\"
gunzip  ./tp_estados.csv.gz
psql -U postgres -d ControlSenseDB -t -c \"copy tp_estados(id, id_estados, id_equipo, id_detal_estado, id_trabajador, tiempo_inicio, tiempo_estimado, idnodo, idenestado, comentario, ids_resumen, tiem_creac, tiem_update, tiem_elimin, id_detal_estado2, idubicacionsupervisor, tipoubicacionsupervisor, end_time, id_main_status, is_processed, duration, start_horometer, end_horometer, id_tp_estado_next, id_approved, id_request_trabajador, id_request_usuario, id_change_user)  from '\$(pwd)/tp_estados.csv' DELIMITER ',' CSV HEADER;\"
">> $DIR/restore.database.$database.sh

echo "echo \"The restoration has been completed at \$(date)\" " >> $DIR/restore.database.$database.sh


chmod 755 $DIR/restore.database.$database.sh 





# --------
(echo "id, id_datacarga, id_palas, coord_x, coord_y, coord_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, tiem_creac, tiem_elimin, id_cargadescarga, arregloleyes, arregloidbloques, id_material_predominante, tiem_registro, id_equipment_load, id_equipment_hauling, has_block, isproc, tiem_update, idpolygons, presiciongps, polygonid, id_palas_dup, target_x, target_y, target_z, tiempo_suceso, arreglo_caracteristica"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_datacarga, id_palas, coord_x, coord_y, coord_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, tiem_creac, tiem_elimin, id_cargadescarga, arregloleyes, arregloidbloques, id_material_predominante, tiem_registro, id_equipment_load, id_equipment_hauling, has_block, isproc, tiem_update, idpolygons, presiciongps, polygonid, id_palas_dup, target_x, target_y, target_z, tiempo_suceso, arreglo_caracteristica
            from ta_datacarga
            where tiem_creac > (now() - INTERVAL '4 months')
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > ta_datacarga.csv.gz

echo " Restore table ta_datacarga"
gunzip  ./ta_datacarga.csv.gz
psql -U postgres -p 5448 -d ControlSenseDB -t -c "copy ta_datacarga(id, id_datacarga, id_palas, coord_x, coord_y, coord_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, tiem_creac, tiem_elimin, id_cargadescarga, arregloleyes, arregloidbloques, id_material_predominante, tiem_registro, id_equipment_load, id_equipment_hauling, has_block, isproc, tiem_update, idpolygons, presiciongps, polygonid, id_palas_dup, target_x, target_y, target_z, tiempo_suceso, arreglo_caracteristica)  from '$(pwd)/ta_datacarga.csv' DELIMITER ',' CSV HEADER;"



(echo "id, id_datacarga_sensores, id_palas, id_cargadescarga, coord_x, coord_y, coord_z, target_x, target_y, target_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, arregloleyes, arregloidbloques, id_material_predominante, id_equipment_load, id_equipment_hauling, has_block, polygonid, idpolygons, presiciongps, tiempo_carga, tiempo_descarga, tiem_creac, tiem_update, tiem_elimin, error_description, id_planminado"; 
    psql -h 127.0.0.1 -p 5432 -U postgres -d ControlSenseDB -t -c "COPY 
        (   
            select id, id_datacarga_sensores, id_palas, id_cargadescarga, coord_x, coord_y, coord_z, target_x, target_y, target_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, arregloleyes, arregloidbloques, id_material_predominante, id_equipment_load, id_equipment_hauling, has_block, polygonid, idpolygons, presiciongps, tiempo_carga, tiempo_descarga, tiem_creac, tiem_update, tiem_elimin, error_description, id_planminado
            from ta_datacarga_sensores
            where tiem_creac > (now() - INTERVAL '4 months')
        ) 
    TO STDOUT WITH CSV DELIMITER ','"
    ) | gzip -1 > ta_datacarga_sensores.csv.gz

echo " Restore table ta_datacarga_sensores"
gunzip  ./ta_datacarga_sensores.csv.gz
psql -U postgres -p 5448 -d ControlSenseDB -t -c "copy ta_datacarga_sensores(id, id_datacarga_sensores, id_palas, id_cargadescarga, coord_x, coord_y, coord_z, target_x, target_y, target_z, issuperior, angulo_giro, tonelaje, duracion_excavacion, angulo_giro_promedio, arregloleyes, arregloidbloques, id_material_predominante, id_equipment_load, id_equipment_hauling, has_block, polygonid, idpolygons, presiciongps, tiempo_carga, tiempo_descarga, tiem_creac, tiem_update, tiem_elimin, error_description, id_planminado)  from '$(pwd)/ta_datacarga_sensores.csv' DELIMITER ',' CSV HEADER;"




