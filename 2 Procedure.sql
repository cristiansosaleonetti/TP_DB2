
/* 
************************

      SEGUNDA PARTE

	     PROCEDURES

************************
*/


DROP procedure if exists RendicionDeHoras;

delimiter $$
create procedure RendicionDeHoras(IN opcion INT,in ID_proy_RDH int,in ID_Legajo_RDH INT,IN fec_RDH DATE,in hs_rendidas_RDH INT)
BEGIN
	DECLARE fec_hasta_RDH DATE;
	/* Opción 1 = Ingreso solo horas del día */ 
  if opcion = 1
 	 then
 	 INSERT INTO Horas_Rendidas (ID_Proy,ID_Legajo,Hs_dia_rendido,Hs_Rendidas) 
	  		VALUES (ID_Proy_RDH,ID_Legajo_RDH,fec_RDH,hs_rendidas_RDH);
	 END if; 
	 
  /* Opción 2 = Ingreso horas de una semana */	 
  if opcion = 2
 	 then
  	 SET fec_hasta_RDH = adddate(fec_RDH,INTERVAL 1 week);
  	 while fec_RDH < fec_hasta_RDH do
 	 		INSERT INTO Horas_Rendidas (ID_Proy,ID_Legajo,Hs_dia_rendido,Hs_Rendidas) 
	  			VALUES (ID_Proy_RDH,ID_Legajo_RDH,fec_RDH,hs_rendidas_RDH);
	  		set fec_RDH = adddate(fec_RDH,INTERVAL 1 day);
	 END while;
  END if;   
	    
  /* Opción 3 = Ingreso horas de un mes */	 
  if opcion = 3
 	 then
  	 SET fec_hasta_RDH = adddate(fec_RDH,INTERVAL 1 month);
  	 while fec_RDH < fec_hasta_RDH do
 	 		INSERT INTO Horas_Rendidas (ID_Proy,ID_Legajo,Hs_dia_rendido,Hs_Rendidas) 
	  			VALUES (ID_Proy_RDH,ID_Legajo_RDH,fec_RDH,hs_rendidas_RDH);
	  		set fec_RDH = adddate(fec_RDH,INTERVAL 1 day);
	 END while;
  END if;      
END
$$

DROP procedure if EXISTS  CalcularLiquidacionMensual;
delimiter $$
create procedure CalcularLiquidacionMensual (in ID_Proy_CLM int,in Anio_CLM INT,IN mes_CLM INT)
BEGIN
	DECLARE cliente_aux_ID INT ; 
	DECLARE rol_aux_ID INT ; 
	DECLARE acum_horas_rend DOUBLE DEFAULT 0;
	DECLARE acum_horas_liq DOUBLE DEFAULT 0;
	DECLARE correlativo_prox INT DEFAULT -1; 
	DECLARE acum_horas DOUBLE DEFAULT 0;
	DECLARE done INT DEFAULT 0;
	declare Curs_rol cursor for 
			SELECT r.id_rol
			from rol r;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  
/* Dertermino el cliente de este proyecto */ 
		SET cliente_aux_ID =  (SELECT p.ID_Cliente
										from proyecto p WHERE p.ID_Proy = ID_Proy_CLM);				

		SET correlativo_prox =  (SELECT MAX(l.Correlativo)
										from liquidacion_mensual l
										WHERE (l.ID_Proy = ID_proy_CLM AND l.anio_liquidacion = anio_CLM AND l.mes_liquidacion = mes_cLM));
		
		if correlativo_prox IS NULL then 
			SET correlativo_prox = -1;
		  END if; 		  		
	  	SET correlativo_prox = correlativo_prox + 1;	
		
		
		open Curs_rol;
  	 		ciclo_rol: loop
  	 			set done = false;
	 			fetch Curs_rol into rol_aux_ID;
				SET acum_Horas_rend = 0;
  	 			SET acum_Horas_liq = 0;
					if done then
      				leave ciclo_rol;
 	   			end if;
 	   			
 	   		
				/* Determino las horas rendidas para este proyecto por este rol*/
				set acum_Horas_rend = 	(SELECT sum(hr.hs_rendidas) 
												from Horas_Rendidas hr INNER JOIN Asignacion_rol ar on ar.id_legajo = hr.id_legajo and  hr.ID_Proy = ar.ID_Proy
												WHERE (hr.ID_Proy = ID_proy_CLM and year(hr.Hs_dia_rendido) = anio_CLM and MONTH(hr.Hs_dia_rendido) = mes_CLM AND ar.id_rol = rol_aux_ID));
				
		
				
				if acum_Horas_rend IS NULL then 
					SET acum_Horas_rend = 0;
		  		END if; 
								
				/* Determino las horas ya liquidadas para este proyecto
 				  y también el último correlativo de liquidación       */
				set acum_Horas_liq = (SELECT SUM(l.Cant_Horas)
											from liquidacion_mensual l 
											WHERE (l.ID_Proy = ID_proy_CLM AND l.anio_liquidacion = anio_CLM AND l.mes_liquidacion = mes_cLM AND l.ID_Rol = rol_aux_ID));
		
				if acum_Horas_liq IS NULL then 
					SET acum_Horas_liq = 0;
		 		END if; 									
  				
				/* Si la cantidad de horas rendidas menos las liquidadas 
  				es distinto a cero                                   */
  				set Acum_horas =  acum_Horas_rend - acum_Horas_liq;
  				If acum_Horas != 0 then
					INSERT INTO liquidacion_mensual (ID_Cliente    ,ID_Proy   ,ID_Rol    ,anio_liquidacion,mes_liquidacion,Cant_Horas,Correlativo) 
					VALUES                      	 (cliente_aux_ID,ID_proy_CLM,rol_aux_ID,anio_CLM        ,mes_CLM        ,acum_Horas,correlativo_prox);
				SET acum_Horas_rend = 0;
  	 			SET acum_Horas_liq = 0;
  				END if;
  				
		 	end loop ciclo_rol;
 	 	close Curs_rol;
END
$$
