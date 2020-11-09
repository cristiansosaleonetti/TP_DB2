-- DROP procedure RendicionDeHoras;
-- DROP procedure CalcularLiquidacionMensual;

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

delimiter $$
create procedure CalcularLiquidacionMensual (IN ID_Cliente_CLM INT, in ID_Proy_CLM int,in Anio_CLM INT,IN mes_CLM INT)
BEGIN
	DECLARE done INT DEFAULT 0;
	DECLARE Hs_rendidas_CLM double;
	DECLARE Hs_liquidadas_CLM double;
	DECLARE acum_horas DOUBLE DEFAULT 0;
	DECLARE acum_horas_rend DOUBLE DEFAULT 0;
	DECLARE acum_horas_liq DOUBLE DEFAULT 0;
	DECLARE correlativo_liq INT DEFAULT 0;
	DECLARE correlativo_prox INT DEFAULT -1; 
	declare Hs_rend cursor for 
			SELECT sum(hr.hs_rendidas) 
			from Horas_Rendidas hr 
			WHERE (hr.ID_Proy = ID_proy_CLM and year(hr.Hs_dia_rendido) = anio_CLM and MONTH(hr.Hs_dia_rendido) = mes_CLM)
			;
  	declare liquidaciones cursor for 
			SELECT SUM(l.Cant_Horas),l.Correlativo
			from liquidacion_mensual l
			WHERE (l.ID_Proy = ID_proy_CLM AND l.anio_liquidacion = anio_CLM AND l.mes_liquidacion = mes_cLM)
			GROUP BY l.correlativo
			ORDER BY l.correlativo asc
			;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

/* Determino las horas rendidas para este proyecto */
  open Hs_rend;
  	 mi_ciclo: loop
  	 	set done = false;
	 	fetch Hs_rend into Hs_Rendidas_CLM;
	 	if done then
      	leave mi_ciclo;
 	   end if;
		set acum_Horas_rend = acum_Horas_rend +Hs_Rendidas_CLM;
	 end loop mi_ciclo;
  close Hs_Rend;
  
/* Determino las horas ya liquidadas para este proyecto
   y también el último correlativo de liquidación       */
  open liquidaciones;
  	 mi_ciclo2: loop
  	 	set done = false;
	 	fetch liquidaciones into Hs_liquidadas_CLM,correlativo_liq;
	 	if done then
      	leave mi_ciclo2;
 	   end if;
		set acum_Horas_liq = acum_Horas_liq+Hs_liquidadas_CLM;
		SET correlativo_prox = correlativo_liq;
    end loop mi_ciclo2;
  close liquidaciones; 
  
  /* Si la cantidad de horas rendidas menos las liquidadas 
  		es distinto a cero                                    */
  Set acum_horas = acum_Horas_rend - acum_Horas_liq;
  If acum_Horas != 0 then
  		SET correlativo_prox = correlativo_prox + 1;
		INSERT INTO liquidacion_mensual (ID_Cliente    ,ID_Proy    ,anio_liquidacion,mes_liquidacion,Cant_Horas,Correlativo) 
			VALUES                       (ID_Cliente_CLM,ID_proy_CLM,anio_CLM        ,mes_CLM        ,acum_Horas,correlativo_prox);
  END if;
END
$$


