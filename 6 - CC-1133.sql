/*
******************************

         SEXTA PARTE
          USUARIOS
 		    CC-1133

******************************
*/

/* Auditor */ 
CREATE user auditor IDENTIFIED BY 'auditor';
GRANT SELECT ON TP_BD2.* TO auditor;


/* Administrador */ 
CREATE user administrador IDENTIFIED BY 'administrador';
GRANT INSERT, ALTER ON TP_BD2.* TO administrador;

/* sitio_web */ 
CREATE user sitio_web IDENTIFIED BY 'sitio_web';
GRANT INSERT, SELECT ON TP_BD2.* TO sitio_web;

/* sitio_web_revisor */ 
CREATE user sitio_web_revisor IDENTIFIED BY 'sitio_web_revisor';
GRANT INSERT, SELECT, UPDATE ON TP_BD2.* TO sitio_web_revisor;

