select * from ts_equipos where nombre in ('WA600','WA900') and tiem_elimin is null;

-- #########
SELECT * from ts_equipos where id = 35; --se elimina el id 35 que contiene la flota 11=Auxiliar Loader
UPDATE public.ts_equipos
SET tiem_elimin = '2024-02-18 16:23:57.554000 +00:00'
WHERE id = 35;

-- #########
-- CREACION DE FLOTA WA900 DE PRUEBA
select * from ts_equipos order by id desc limit 1;

-- CREACION DE FLOTA WA600 DE PRUEBA - luego de cambiar los estados! -- la flota a escoger es la 91
select * from ts_equipos order by id desc limit 1;

-- #########
-- ESTADOS EXISTENTES PARA EL WA900 / ID_FLOTA=27 -- CONTEO GENERAL 71 ESTADOS?? -- PARA EL TIPO 5 (OUTOFPLAN) EXISTEN 5
SELECT
--     count(*)
de1.id as id1 , de2.id  as id2 , de3.id as id3, de3.nombre, de2.nombre, de1.nombre, te.nombre, de1.equipmentshow, de2.equipmentshow, de3.equipmentshow
                                          FROM ts_detal_estado de1
                                          LEFT JOIN ts_detal_estado de2 ON de1.id_tipo_estad = de2.id
                                          LEFT JOIN ts_detal_estado de3 ON de2.id_tipo_estad = de3.id
                                          LEFT JOIN ts_equipos te ON de1.id_flota = te.ID
                                          WHERE de1.isestado = 't' AND de1.id_flota =   27 -- FLOTA = WA900
--                                            AND de3.id = 5
                                          ORDER BY 1 ASC; LIMIT 1;

-- CAMBIAMOS LOS ESTADOS DESDE EL MISMO C4M!
-- ESTADOS EXISTENTES PARA EL WA600 / ID_FLOTA=91

-- SETEAMOS TIEMPO NOW() A TODOS LOS ESTADOS QUE EXISTEN PARA LA FLOTA 91
select * from ts_detal_estado where id_flota = 91;

-- MODIFICAMOS LA FUNCION Y ADICIONAMOS EL TIEM_ELIMIN IS NULL EN LA PARTE DE ABAJO
select agrega_estados_a_nueva_flota(91,27);
--SETEAMOS ESTO EN LA FUNCION DE ARRIBA!
SELECT COUNT(*)  FROM ts_detal_estado WHERE id_flota =91 and tiem_elimin is null;


SELECT de1.id as id1 , de2.id  as id2 , de3.id as id3, de3.nombre, de2.nombre, de1.nombre, te.nombre, de1.equipmentshow, de2.equipmentshow, de3.equipmentshow
                                          FROM ts_detal_estado de1
                                          LEFT JOIN ts_detal_estado de2 ON de1.id_tipo_estad = de2.id
                                          LEFT JOIN ts_detal_estado de3 ON de2.id_tipo_estad = de3.id
                                          LEFT JOIN ts_equipos te ON de1.id_flota = te.ID
                                          WHERE de1.isestado = 't' AND de1.id_flota =   91
--                                            AND de3.id = 5
                                          ORDER BY 1 ASC; LIMIT 1;

-- update ts_detal_estado set equipmentshow = false where id in (1179, 1180, 1182, 1183, 1185, 1187, 1188, 1190, 1209, 1212, 1225, 1226, 1227, 1228, 1229, 1230, 1231, 1232, 1233, 1234, 1235, 1236, 1237, 1238, 1239, 1240, 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257, 1258, 1259, 1260, 1261, 1262, 1263, 1264, 1265, 1266, 1267, 1268, 1269, 1270, 1271, 1272, 1273, 1274, 1275, 1276, 1277, 1278, 1279, 1280, 1281, 1282, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1296, 1297, 1298, 1299, 1300, 1301, 1302, 1303, 1304, 1305, 1306, 1307, 1308, 1309, 1310, 1311, 1312);

-- TENER EN CUENTA QUE EL TRUE DEBERIA DE IR SOLO PARA LOS ESTADOS QUE SE ADICIONAN Y SE COPIAN IGUAL A LA OTRA FLOTA WA900
UPDATE ts_detal_estado
SET equipmentshow = true
WHERE isestado = 't' AND id_flota = 91;

-- UPDATE ts_detal_estado de3_update
-- SET equipmentshow = false
-- FROM ts_detal_estado de1
-- LEFT JOIN ts_detal_estado de2 ON de1.id_tipo_estad = de2.id
-- LEFT JOIN ts_detal_estado de3 ON de2.id_tipo_estad = de3.id
-- LEFT JOIN ts_equipos te ON de1.id_flota = te.id
-- WHERE de1.isestado = 't' AND de1.id_flota = 91 AND de3.id = 5;


-- #######
-- PROCEDEMOS A REALIZAR EL CAMBIO CON EL ID OBTENIDO LUEGO DE CREAR UN EQUIPO DE PRUEBA,
-- LOS EQUIPOS A CAMBIAR SON EL LD01 Y LD02
-- LD01 = 74
-- LD02 = 73
SELECT * from ts_equipos where id = 74; --actualmente esta asi con el id_flota 27 del WA900

select id,* from ts_equipos where id = 74; --luego del cambio deberia estar con el id_flota 91 del WA900

-- select agrega_estados_a_nueva_flota(91,27);
--
--  SELECT COUNT(*)  FROM ts_detal_estado WHERE id_flota =91 and tiem_elimin is null;
--


-- select * from ts_detal_estado where id_flota = 91;
-- select id from ts_detal_estado  order by id desc limit 1; --1248
-- delete from ts_detal_estado where id >1248;



-- REVISAR LO SIGUIENTE::;
select * from camionescampo;
select * from ta_factortonelaje;


-- CHECAR EL FORMULARIO WORKER LIST EN CASO SE DESEE LOGUEAR A UN USUARIO
SELECT * from ts_trabajador;
select * from tp_trabajador where id_trabajador = 131;


--DATAQUALITY
-- AGREGAR EL CHECKLIST
-- >COPIAR FROM
-- > FLOTA PRINCIPAL: SHOVEL
-- > FLOTA SECUNDARIA: WA900