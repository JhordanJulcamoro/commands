#!/bin/bash
# backup-postgresql-without-huge-tables.sh
# by MS4M

remote_host=127.0.0.1
port_remote=5432
user_remote=postgres

DUMPALL="pg_dumpall"
PGDUMP="pg_dump"
PSQL="psql"
Gzip="gzip -6 BackupControlSense"

BASE_DIR="/var/lib/postgresql/small"
YMD=$(date "+%Y-%m-%d")
DIR="$BASE_DIR/$YMD"
DIR_TABLES="$BASE_DIR/$YMD/tables"
mkdir -p $DIR
mkdir -p $DIR_TABLES
cd $DIR


echo  "Inicio de copia de seguridad  `date`"

echo "Start backaping at $(date) " >> backup_database_daily.log
# Print current size database
psql -h $remote_host -p $port_remote -U $user_remote -w -d ControlSenseDB -c "Copy (SELECT pg_size_pretty(pg_database_size('ControlSenseDB') )as database_size) To STDOUT With CSV HEADER DELIMITER ',';" >> backup_database_daily.log
# Print list of huge tables
psql -h $remote_host -p $port_remote -U $user_remote -w -d ControlSenseDB  -c "COPY (SELECT relname AS table_name, pg_size_pretty(pg_total_relation_size(C.oid)) AS table_size FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema')  ORDER BY pg_total_relation_size(C.oid) DESC LIMIT 5) To STDOUT With CSV HEADER DELIMITER '|';"  >> backup_database_daily.log

# next dump globals (roles and tablespaces) only
echo "$DUMPALL  -h $remote_host -p $port_remote -U $user_remote -w -g | gzip -9 > $DIR/globals.gz"
echo "$DUMPALL  -h $remote_host -p $port_remote -U $user_remote -w -g | gzip -9 > $DIR/globals.gz" >>  backup_database_daily.log
#  pg_dumpall -h 10.240.94.72 -p $port_remote -U $user_remote -w -g | gzip -9 > /var/backups/postgres/test/globals.gz

$DUMPALL -h $remote_host -p $port_remote -U $user_remote -w -g | gzip -9 > "$DIR/globals.gz"

# Now it will be done, a backup of the scheme and the data separately
database=ControlSenseDB
SCHEMA=$DIR/$database.schema.gz
DATA=$DIR/$database.data.gz
# export data from database ControlSenseDB to plain text
echo "$PGDUMP -h $remote_host -p $port_remote -U $user_remote -w  -c -s $database | gzip -9 > $SCHEMA"
echo "$PGDUMP -h $remote_host -p $port_remote -U $user_remote -w  -c -s $database | gzip -9 > $SCHEMA" >> backup_database_daily.log
#  pg_dump -h 10.240.94.72 -p $port_remote -U $user_remote -w -C  -s ControlSenseDB | gzip -9 > /var/backups/postgres/test/ControlSenseDB.schema.gz

$PGDUMP -h $remote_host -p $port_remote -U $user_remote -w -s $database | gzip -9 > $SCHEMA

# dump data


# backup table one by one

query_alltables="    SELECT relname                                       AS name_table,
             pg_size_pretty(pg_total_relation_size(C.oid)) AS pretty_total_size
              ,
             (pg_total_relation_size(C.oid))               AS total_size
      FROM pg_class C
               LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
      WHERE nspname NOT IN ('pg_catalog', 'information_schema')
        AND C.relkind <> 'i'
        AND nspname !~ '^pg_toast'
        AND nspname = 'public'
        AND pg_total_relation_size(C.oid) > 0
        and relname not like '%cycle_info%'
        and relname not like '%equipment_pass_per_hour%'
        and relname not like '%ta_datacamion_historic%'
        and relname not like '%ta_log%'
        and relname not like '%at_collision_alerts%'
        and relname not like '%ta_alertasvims%'
        and relname not like '%ta_datacamion%'
        and relname not like '%ta_datapala_historic%'
        and relname not like '%ta_data_auxiliares%'
        and relname not like '%ta_data_auxiliares_historic%'
        and relname not like '%ta_androidlogs%'
        and relname not like '%tp_systemlogs%'
        and relname not like '%ta_datadigline%'
        and relname not like '%ta_datadiglineacumuladodetalle%'
        and relname not like '%ta_datadiglineacumulado%'
        and relname not like '%pt_reg_temp_parameters_cr%'
        and relname not like '%at_collision_alerts%'
        and relname not like '%ta_datacamion_historic%'
        and relname not like '%ta_data_auxiliares_historic%'
        and relname not like '%ta_alertasvims%'
        and relname not like '%ta_datapala_historic%'
        and relname not like '%ta_datacamion%'
        and relname not like '%ta_datadigline%'
        and relname not like '%tp_systemlogs%'
        and relname not like '%ta_registro_horometro%'
        and relname not like '%ta_datapala%'
        and relname not like '%ta_balanceoptimizador%'
        and relname not like '%ta_datadiglineacumuladodetalle%'
        and relname not like '%pt_reg_temp_coor_cr%'
        and relname not like '%ta_logreasignacarguio%'
        and relname not like '%ta_data_auxiliares%'
        and relname not like '%ta_mensajes_detalle%'
        and relname not like '%ta_checklistdetalle%'
        and relname not like '%cyclessummarywithstates%'
        and relname not like '%cyclessummary%'
        and relname not like '%at_data_floor%'
        and relname not like '%statessummary%'
        and relname not like '%ts_confirmaestado%'
        and relname not like '%statessummarytruck%'
        and relname not like '%ta_controlbateria%'
        and relname not like '%ta_speed_limits_exceeded%'
        and relname not like '%at_data_floor_resume%'
        and relname not like '%ta_wrongcarguiodesc%'
        and relname not like '%auxiliaresarreglo%'
        and relname not like '%camionesarregloop%'
        and relname not like '%statessummaryshovel%'
        and relname not like '%ta_datacamion_historic%'
        and relname not like '%ta_log%'
        and relname not like '%at_collision_alerts%'
        and relname not like '%ta_alertasvims%'
        and relname not like '%ta_datacamion%'
        and relname not like '%ta_datapala_historic%'
        and relname not like '%ta_data_auxiliares%'
        and relname not like '%ta_data_auxiliares_historic%'
        and relname not like '%ta_androidlogs%'
        and relname not like '%tp_systemlogs%'
        and relname not like '%ta_datadigline%'
        and relname not like '%ta_datadiglineacumuladodetalle%'
        and relname not like '%ta_datadiglineacumulado%'
        and relname not like '%pt_reg_temp_parameters_cr%'
        and relname not like '%at_collision_alerts%'
        and relname not like '%ta_datacamion_historic%'
        and relname not like '%ta_data_auxiliares_historic%'
        and relname not like '%ta_alertasvims%'
        and relname not like '%ta_datapala_historic%'
        and relname not like '%ta_datacamion%'
        and relname not like '%ta_datadigline%'
        and relname not like '%tp_systemlogs%'
        and relname not like '%ta_registro_horometro%'
        and relname not like '%ta_datapala%'
        and relname not like '%ta_balanceoptimizador%'
        and relname not like '%ta_datadiglineacumuladodetalle%'
        and relname not like '%pt_reg_temp_coor_cr%'
        and relname not like '%ta_logreasignacarguio%'
        and relname not like '%ta_data_auxiliares%'
        and relname not like '%ta_mensajes_detalle%'
        and relname not like '%ta_checklistdetalle%'
        and relname not like '%cyclessummarywithstates%'
        and relname not like '%cyclessummary%'
        and relname not like '%at_data_floor%'
        and relname not like '%statessummary%'
        and relname not like '%ta_datapala%'
        and relname not like '%ts_confirmaestado%'
        and relname not like '%statessummarytruck%'
        and relname not like '%ta_controlbateria%'
        and relname not like '%ta_speed_limits_exceeded%'
        and relname not like '%at_data_floor_resume%'
        and relname not like '%ta_wrongcarguiodesc%'
        and relname not like '%auxiliaresarreglo%'
        and relname not like '%camionesarregloop%'
        and relname not like '%statessummaryshovel%'
        and relname not like '%ta_tmp_hardware%'
        and relname not like '%ta_onoffhor%'
        and relname not like '%ta_acarreopalafija%'
        and relname not like '%ta_outroutecamion%'
        and relname not like '%at_data_spray%'
        and relname not like '%cyclessummary2%'
        and relname not like '%ta_mensajesopt%'
        and relname not like '%tp_cargadescarga%'
        and relname not like '%tp_palas%'
        and relname not like '%tp_estados%'
        and relname not like '%ta_datacarga%'
        and relname not like '%ta_datacarga_sensores%'
        and relname not like '%ta_datacarga_dig%'
        and relname not like '%datadigline%'
      ORDER BY pg_total_relation_size(C.oid) DESC;";

psql \
-X \
-h $remote_host \
-p $port_remote \
-d ControlSenseDB \
-U $user_remote -w \
-c "$query_alltables" \
--single-transaction \
--set AUTOCOMMIT=off \
--set ON_ERROR_STOP=on \
--no-align \
-t \
-w \
--field-separator ' ' \
--quiet \
$DB_NAME | while read -a Record ; do
        name_table_current=${Record[0]} 

        DATA_TABLE=$DIR_TABLES/$name_table_current.data.gz

        echo "Start backaping table $name_table_current at $(date) " >> backup_database_daily.log

        echo "$PGDUMP -h $remote_host -p $port_remote -U $user_remote -w -a  -d $database -t $name_table_current -v  | gzip -9 > $DATA_TABLE"
        echo "$PGDUMP -h $remote_host -p $port_remote -U $user_remote -w -a -d $database -t $name_table_current -v  | gzip -9 > $DATA_TABLE" >> backup_database_daily.log
        $PGDUMP -h $remote_host -p $port_remote -U $user_remote -w -a -d $database -t $name_table_current   | gzip -9 > $DATA_TABLE

        echo "End backaping table $name_table_current at $(date) " >> backup_database_daily.log

        # sleep 2
done


echo "End backaping from all data tables at $(date) " >> backup_database_daily.log

echo "$(ls -lhs $DIR/) " >> backup_database_daily.log
echo "$(du -hs $DIR_TABLES/) " >> backup_database_daily.log

echo `{ echo " $DIR_TABLES/ -> " ; ls  $DIR_TABLES/ | wc -l; echo " Files.";} | sed ':a;N;s/\n/ /;ba';`"\n"; >> backup_database_daily.log
echo `{ echo " $DIR_TABLES/ -> " ; echo "$(du -hs $DIR_TABLES/) " ; echo  " Size.";} | sed ':a;N;s/\n/ /;ba';`"\n"; >> backup_database_daily.log

echo "End backup at $(date)  " >> backup_database_daily.log

echo "Fin de copia de seguridad `date`"



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