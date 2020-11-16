/* 
************************

      PRIMERA PARTE

	CREACIÓN DE TABLAS

************************
*/

DROP DATABASE if exists TP_BD2;

CREATE DATABASE TP_BD2;

USE TP_BD2;

create table legajo (
	ID_Legajo int not null primary key,
	Apellido VARCHAR(50) NOT NULL,
   Nombre VARCHAR(50) NOT null
	);

create table rol (
	ID_Rol int not null primary key,
	Desc_rol VARCHAR(50) NOT null
	);

create table Centro_costos (
	ID_CC int not null primary key,
	Desc_CC VARCHAR(100) NOT null
	);

create table Centro_Facturacion (
	ID_fact int not null primary key,
	Desc_fact VARCHAR(100) NOT null
	);

create table cliente (
	ID_cliente int not null primary key,
	Desc_cliente VARCHAR(150) NOT null,
	ID_CC INT NOT NULL,
	ID_FACT INT NOT NULL,
		CONSTRAINT fk_id_CC_c FOREIGN KEY (id_cc)
	   REFERENCES centro_costos(ID_cc),
		CONSTRAINT fk_id_fact_c FOREIGN KEY (ID_fact)
	   REFERENCES centro_facturacion(ID_fact)			
	);

create table proyecto (
	ID_Proy int not null primary key,
	Desc_Proy VARCHAR(100) NOT NULL,
	ID_cliente INT NOT NULL,
		CONSTRAINT fk_id_cliente_p FOREIGN KEY (id_cliente)
	   REFERENCES cliente(ID_cliente)
	);
	
CREATE TABLE horas_rendidas (
	id_proy INT NOT NULL,
	id_legajo INT NOT NULL,
	Hs_dia_rendido DATE NOT null,
	hs_rendidas DOUBLE NOT NULL,
		CONSTRAINT fk_id_proy_HR FOREIGN KEY (ID_proy)
		REFERENCES proyecto(id_proy),
		CONSTRAINT fk_id_legajo_HR FOREIGN KEY (ID_legajo)
		REFERENCES legajo(id_legajo),
		CONSTRAINT PK_Horas_rendidas UNIQUE(id_proy,id_legajo,Hs_dia_rendido)
	);


CREATE TABLE Asignacion_rol (
	id_proy INT NOT NULL,
	id_legajo INT NOT NULL,
	id_rol INT NOT NULl,
		CONSTRAINT fk_id_proy_AR FOREIGN KEY (ID_proy)
		REFERENCES proyecto(id_proy),
		CONSTRAINT fk_id_legajo_AR FOREIGN KEY (ID_legajo)
		REFERENCES legajo(id_legajo),
		CONSTRAINT fk_id_rol_AR FOREIGN KEY (id_rol)
		REFERENCES rol(id_rol),
		CONSTRAINT PK_asignacion_rol UNIQUE(id_proy,id_legajo)
	);
	
CREATE TABLE Liquidacion_mensual (
	ID_Liquidacion INT not null AUTO_INCREMENT PRIMARY KEY ,
	ID_Cliente INT NOT NULL,
	ID_Proy INT NOT NULL,
	ID_Rol INT NOT NULL,
	anio_liquidacion INT NOT NULL,
	mes_liquidacion INT NOT NULL,
	cant_horas DOUBLE,
	correlativo int,
		cONSTRAINT fk_id_cliente_LM FOREIGN KEY (id_cliente)
	   REFERENCES cliente(ID_cliente),
		CONSTRAINT fk_id_proy_LM FOREIGN KEY (ID_proy)
		REFERENCES proyecto(id_proy),
		coNSTRAINT fk_id_rol_LM FOREIGN KEY (ID_rol)
		REFERENCES rol(id_rol)
	);
	
	




