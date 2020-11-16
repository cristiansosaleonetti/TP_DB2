/*
******************************

        SEPTIMA PARTE
          PRUEBAS		    

******************************
*/

/* Cargadas en Pruebas anteriores */

/* Pruebas CC-1131 */
/* Alta y Modificación de filas en RendiciónDeHoras*/
		
CALL RendicionDeHoras (1,1000001,10,"20201109",15); -- Dia - Opción 1
CALL RendicionDeHoras (2,1000002,10,"20201109",8); -- Semana - Opción 2
CALL RendicionDeHoras (3,1000002,11,DATE_SUB("20201109",INTERVAL 1 month),6); -- Mes - Opción 3

/* Liquidacion de dos proyectos 1000001 y 1000002 */

CALL CalcularLiquidacionMensual (1000001,2020,11);
CALL CalcularLiquidacionMensual (1000002,2020,11);

/* Cargo más horas al proyecto 1000002 en noviembre */ 


CALL RendicionDeHoras (2,1000002,11,DATE_add("20201109",INTERVAL 1 WEEK),7); -- Semana - Opción 2

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 1*/ 

CALL CalcularLiquidacionMensual (1000002,2020,11);

/* Cargo más horas al proyecto 1000002 en noviembre */

CALL RendicionDeHoras (1,1000002,11,DATE_add("20201109",INTERVAL 2 WEEK),3); -- Semana - Opción 2

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 2*/ 

CALL CalcularLiquidacionMensual (1000002,2020,11);

/* Liquido las horas del proyecto 100002 - de octubre - Original */

CALL CalcularLiquidacionMensual (1000002,2020,10);

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 3*/ 

CALL RendicionDeHoras (1,1000002,10,DATE_SUB("20201130",INTERVAL 1 day),7); -- Dia - Opción 1
CALL RendicionDeHoras (1,1000002,11,DATE_SUB("20201130",INTERVAL 1 day),9); -- Dia - Opción 1

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 3*/ 

CALL CalcularLiquidacionMensual (1000002,2020,11);

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 4*/ 
CALL RendicionDeHoras (1,1000002,11,DATE_SUB("20201129",INTERVAL 1 day),9); -- Dia - Opción 1

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 4*/ 

CALL CalcularLiquidacionMensual (1000002,2020,11);


/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 5*/ 
CALL RendicionDeHoras (1,1000002,10,DATE_SUB("20201129",INTERVAL 1 DAY),5); -- Dia - Opción 1

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 5*/ 

CALL CalcularLiquidacionMensual (1000002,2020,11);

/* Modificación */
		

UPDATE Horas_rendidas 
SET Hs_Rendidas = 1 WHERE (ID_Proy = 1000002 AND ID_Legajo = 11 AND Hs_dia_rendido = "20201123");


CALL CalcularLiquidacionMensual (1000002,2020,11);


/* Pruebas CC-1132 */
/* Eliminación de filas en RendiciónDeHoras*/
		
call eliminar_horas_rendidas (1000002,11,"20201129")

CALL CalcularLiquidacionMensual (1000002,2020,11);


SELECT *
FROM horas_rendidas;

SELECT *
FROM liquidacion_mensual;

SELECT *
FROM auditoria_horas_rendidas;
