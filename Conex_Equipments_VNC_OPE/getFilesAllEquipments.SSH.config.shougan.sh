#!/bin/bash

set -e
set -u
mkdir -p ~/.ssh/config.d/
echo "" > ~/.ssh/config.d/config.shougan.equipments

PSQL=$(which psql)

echo "$PSQL"

DB_USER=controlsys
DB_HOST=172.16.7.20
DB_NAME=ControlSenseDB
DB_PORT=5432
# FOLDER=/opt/minesense/ping

$PSQL \
    -v \
    -X \
    -p $DB_PORT \
    -h $DB_HOST \
    -U $DB_USER \
    -c "SELECT e.nombre, ' \"' || e.ipmesh || '\" ', e.ipequipo, e.id_equipo, e.id_equipo,row_number() over (order by e.id_equipo) orderid
        FROM ts_equipos e
                INNER JOIN ts_equipos fs ON fs.id_equipo = e.id_flota
                INNER JOIN ts_equipos fp ON fs.id_flota = fp.id_equipo
        WHERE e.tiem_elimin ISNULL
        and e.ipequipo not like '0.0.0.0'
        and e.ipequipo not like '1.1.1.1'
        and e.ipequipo not like ''
        and e.ipequipo notnull
        ORDER BY fp.id, fs.id, e.id;" \
    --single-transaction \
    --set AUTOCOMMIT=off \
    --set ON_ERROR_STOP=on \
    --no-align \
    -t \
    --field-separator ' ' \
    --quiet \
    $DB_NAME | while read -a Record; do

    # echo "${Record[@]}"
    EQ_NAME=${Record[0]}
    ipmesh=${Record[1]}
    ipequipo=${Record[2]}
    id_eq=${Record[3]}
    orderid=${Record[4]}
    port_vnc=$((11600 + $orderid))
    FULL_NAME="SH_"$EQ_NAME"_"$id_eq
    echo "$EQ_NAME:$port_vnc   ip  ---> $FULL_NAME"

    echo "Host $FULL_NAME
    User root 
    HostName $ipequipo
    Port 22
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    ProxyJump shapp01
    UserKnownHostsFile=/dev/null
    LocalForward    $port_vnc $ipequipo:5901
    LocalCommand    /Applications/vncviewer.sh $port_vnc
    #IP MESH: $ipmesh
    " >> ~/.ssh/config.d/config.shougan.equipments
done
