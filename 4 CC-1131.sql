/* 
************************

      CUARTA PARTE
	     AUDITORIA
 			CC-1131

************************
*/

CREATE TABLE auditoria_horas_rendidas (
	id_aud_hr INT not null AUTO_INCREMENT PRIMARY KEY,
	fecha_mod DATETIME NOT NULL,
	user_modid VARCHAR(150) NOT NULL,
	tipo_de_cambio VARCHAR(1) NOT NULL,
	id_proy_nue INT NOT NULL,
	id_legajo_nue INT NOT NULL,
	Hs_dia_rendido_nue DATE NOT null,
	hs_rendidas_nue DOUBLE NOT NULL,
	id_proy_ant INT ,
	id_legajo_ant INT,
	Hs_dia_rendido_ant DATE,
	hs_rendidas_ant DOUBLE
	)
	;

delimiter $$
create trigger trg_update_auditoria_horas_rendidas
     after update
     on Horas_rendidas
  for each row 
  begin
    insert into auditoria_horas_rendidas(fecha_mod, user_modid,tipo_de_cambio,id_proy_nue,id_legajo_nue, Hs_dia_rendido_nue,hs_rendidas_nue, id_proy_ant,id_legajo_ant,Hs_dia_rendido_ant,hs_rendidas_ant)
    values (now(),CURRENT_USER(),'U', NEW.ID_Proy, NEW.ID_Legajo, NEW.Hs_dia_rendido, NEW.Hs_Rendidas, old.ID_Proy, old.ID_Legajo, old.Hs_dia_rendido, old.Hs_Rendidas);
  end;
$$


Delimiter $$
create trigger trg_insert_auditoria_horas_rendidas
     after Insert
     on Horas_rendidas
  for each row 
  begin
    insert into auditoria_horas_rendidas(fecha_mod, user_modid,tipo_de_cambio,id_proy_nue,id_legajo_nue, Hs_dia_rendido_nue,hs_rendidas_nue, id_proy_ant,id_legajo_ant,Hs_dia_rendido_ant,hs_rendidas_ant)
    VALUES (NOW(),CURRENT_USER(),'I',NEW.ID_Proy, NEW.ID_Legajo, NEW.Hs_dia_rendido, NEW.Hs_Rendidas,NULL,NULL,NULL,NULL);
  end;
$$