/*
******************************

        QUINTA PARTE
 PROCEDIMIENTO DE ELIMINACION
 		    CC-1132

******************************
*/

DROP TRIGGER trg_update_auditoria_horas_rendidas;
DROP procedure CalcularLiquidacionMensual;


/* Agrego el campo de Estado */
ALTER TABLE horas_rendidas
	add (estado BINary DEFAULT 0);   


/* Prodedimiento Eliminación */

delimiter $$
CREATE PROCEDURE eliminar_horas_rendidas (IN ID_Proy_delete int,IN ID_Legajo_delete INT, in Hs_dia_rendido_delete int)
BEGIN
	update horas_rendidas SET estado = 1
	WHERE (ID_Proy_delete = id_proy AND ID_Legajo_delete = ID_Legajo AND Hs_dia_rendido_delete = Hs_dia_rendido);
END
$$

/*
******************************

ACTUALIZO TRIGGER UPDATE POR
PROCEDIMIENTO DE ELIMINACIÓN

******************************
*/

/* Actualizo Tabla de auditoría */
ALTER TABLE auditoria_horas_rendidas
	add (estado_nue BiNary DEFAULT 0,
		  estado_ant BiNary DEFAULT 0);   



/* Actulizo trigger de update con opcion de eliminarción */


delimiter $$
create trigger trg_update_auditoria_horas_rendidas
     after update
     on Horas_rendidas
  for each row 
  begin
  		DECLARE tipo_cam VARCHAR(1);
  	 if new.estado = 1 AND OLD.estado = 0 then
		SET tipo_cam = 'D';
	 else 
		SET tipo_cam = 'U';
	 END if;
    insert into auditoria_horas_rendidas(fecha_mod, user_modid,tipo_de_cambio,id_proy_nue,id_legajo_nue, Hs_dia_rendido_nue,hs_rendidas_nue, id_proy_ant,id_legajo_ant,Hs_dia_rendido_ant,hs_rendidas_ant,estado_nue,estado_ant)
    values (now(),CURRENT_USER(),tipo_cam, NEW.ID_Proy, NEW.ID_Legajo, NEW.Hs_dia_rendido, NEW.Hs_Rendidas, old.ID_Proy, old.ID_Legajo, old.Hs_dia_rendido, old.Hs_Rendidas,new.estado,OLD.estado);  	 
  end;
$$

/*
******************************

ACTUALIZO PRODECIMIENTO DE
LIQUIDACIÓN CONTEMPLANDO EL 
EL CAMPO ESTADO DE ELIMINACIÓN

******************************
*/

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
												WHERE (hr.ID_Proy = ID_proy_CLM and year(hr.Hs_dia_rendido) = anio_CLM and MONTH(hr.Hs_dia_rendido) = mes_CLM AND ar.id_rol = rol_aux_ID AND HR.ESTADO = 0));
				
		
				
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

