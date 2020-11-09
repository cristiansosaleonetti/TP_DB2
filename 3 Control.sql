/* Tablas Iniciales */ 

INSERT INTO Legajo (ID_Legajo,Apellido,Nombre) 
			VALUES 
					(10,'Apellido 10','Nombre 10'),
			      (11,'Apellido 11','Nombre 11'),			
					(12,'Apellido 12','Nombre 12')
			;

INSERT INTO Rol (ID_rol,Desc_rol) 
			VALUES 
					(100,'Rol 100'),
			      (101,'Rol 101'),			
					(102,'Rol 102')
			;
			
INSERT INTO Centro_costos (ID_CC,Desc_CC) 
			VALUES 
					(1000,'CC 1000'),
			      (1001,'CC 1001'),			
					(1002,'CC 1002')
			;
			
INSERT INTO Centro_Facturacion (ID_Fact,Desc_Fact) 
			VALUES 
					(10000,'CF 10000'),
			      (10001,'CF 10001'),			
					(10002,'CF 10002')
			;

INSERT INTO Cliente (ID_Cliente,Desc_Cliente,ID_CC,ID_Fact) 
			VALUES 
					(100000,'Cliente 100000',1001,10000),
					(100001,'Cliente 100001',1002,10000),		
					(100002,'Cliente 100002',1001,10002),
					(100003,'Cliente 100003',1001,10002)
			;
			
INSERT INTO Proyecto (ID_Proy,Desc_Proy,ID_Cliente) 
			VALUES 
					(1000000,'Proyecto 1000000',100003),
					(1000001,'Proyecto 1000001',100002),
					(1000002,'Proyecto 1000002',100000),
					(1000003,'Proyecto 1000003',100002),
					(1000004,'Proyecto 1000004',100000),
					(1000005,'Proyecto 1000005',100000),
					(1000006,'Proyecto 1000006',100000)
			;
			
INSERT INTO Asignacion_rol (ID_Proy,ID_Legajo,ID_Rol) 
			VALUES 
					(1000001,10,100),
					(1000002,10,101),
					(1000003,12,102),
					(1000002,11,100),
					(1000001,11,101),
					(1000001,12,101)
			;

/* Carga Inicial, probando las 3 posibilidades */
		
CALL RendicionDeHoras (1,1000001,10,now(),15); -- Dia - Opción 1
CALL RendicionDeHoras (2,1000002,10,NOW(),8); -- Semana - Opción 2
CALL RendicionDeHoras (3,1000002,11,DATE_SUB(NOW(),INTERVAL 1 month),6); -- Mes - Opción 3

SELECT *
FROM horas_rendidas;

/* Liquidacion de dos proyectos 1000001 y 1000002 */

CALL CalcularLiquidacionMensual (100002,1000001,2020,11);
CALL CalcularLiquidacionMensual (100000,1000002,2020,11);

SELECT *
FROM Liquidacion_Mensual;

/* Cargo más horas al proyecto 1000002 en noviembre */ 


CALL RendicionDeHoras (2,1000002,11,DATE_add(NOW(),INTERVAL 1 WEEK),7); -- Semana - Opción 2


SELECT *
FROM horas_rendidas;


/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 1*/ 

CALL CalcularLiquidacionMensual (100000,1000002,2020,11);

SELECT *
FROM liquidacion_mensual;



/* Cargo más horas al proyecto 1000002 en noviembre */

CALL RendicionDeHoras (1,1000002,11,DATE_add(NOW(),INTERVAL 2 WEEK),3); -- Semana - Opción 2
SELECT *
FROM horas_rendidas;

/* Liquido nuevamente las horas del proyecto 1000002 - Ajuste 2*/ 

CALL CalcularLiquidacionMensual (100000,1000002,2020,11);

SELECT *
FROM Liquidacion_Mensual;

/* Liquido las horas del proyecto 100002 - de octubre - Original */

CALL CalcularLiquidacionMensual (100000,1000002,2020,10);

SELECT *
FROM Liquidacion_Mensual;

--DROP TABLE horas_rendidas;
--DROP TABLE liquidacion_mensual;
