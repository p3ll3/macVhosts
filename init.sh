#!/bin/sh
# script para evitar la configuracion manual de un nuevo proyecto
echo "\x1b[32m \n\n######## CONFIGURAR APACHE ########\n"
echo "\x1b[37m Escriba el nombre del proyecto (solo caracteres alfabeto ingles en MAYUSCULA o minuscula) seguido de [ENTER]:"
read nombreProyecto

if [ ! -f "$HOME/.bash_profile" ]; then
	touch "$HOME/.bash_profile"
fi

#if [ -z "${ENVRUTAWEB+x}" ]; then
	echo "Escriba la ruta de su carpeta de proyectos web sin ningun slash al final, seguido de [ENTER]:"
	read rutaWeb
	#ENVRUTAWEB=$rutaWeb
	#export ENVRUTAWEB
	#source ~/.bash_profile
#else
#	set rutaWeb = $ENVRUTAWEB
#fi

if ( [ ! -d "$rutaWeb/$nombreProyecto" ]  && [ $rutaWeb != "" ] && [ $nombreProyecto != "" ] ); then
		read -r -d '' VHOST <<-IQNIS
		\n
		<VirtualHost *:80>\n
		\tServerAdmin info@iqnis.com\n
		\tDocumentRoot "$rutaWeb/$nombreProyecto/www"\n
		\tServerName $nombreProyecto.dev\n
		\tErrorLog "$rutaWeb/$nombreProyecto/log/$nombreProyecto.dev-error_log"\n
		\tCustomLog "$rutaWeb/$nombreProyecto/log/$nombreProyecto.dev-access_log" common\n
		\t<Directory "$rutaWeb/$nombreProyecto/www">\n
		\t\tOptions Indexes FollowSymLinks\n
		\t\tAllowOverride All\n
		\t\tOrder allow,deny\n
		\t\tAllow from all\n
		\t</Directory>\n
		</VirtualHost>\n
		\n
		IQNIS

		echo $VHOST >> /etc/apache2/extra/httpd-vhosts.conf
		echo "\n127.0.0.1		$nombreProyecto.dev" >> /etc/hosts
		if [ ! -d "$rutaWeb/$nombreProyecto" ]; then
		  mkdir $rutaWeb/$nombreProyecto/
		fi

		if [ ! -d "$rutaWeb/$nombreProyecto/www" ]; then
		  mkdir $rutaWeb/$nombreProyecto/www/
		fi

		if [ ! -d "$rutaWeb/$nombreProyecto/log" ]; then
		  mkdir $rutaWeb/$nombreProyecto/log/
		  touch $rutaWeb/$nombreProyecto/log/$nombreProyecto.dev-error_log
		  touch $rutaWeb/$nombreProyecto/log/$nombreProyecto.dev-access_log
		fi

else
 echo "\x1b[31m Encontramos una carpeta con el mismo nombre del proyecto ( o dejo la ruta o el nombre en blanco! ), si quiere crear nueva estructura eliminela,\n recuerde borrar la informacion del archivo hosts y del archivo httpd-vhosts.conf \n\n"
fi

echo "\x1b[31m ######## MYSQL ######## \nDigite su clave del usuario root mysql, seguido de [ENTER]: "
read mysqlRoot
mysql -uroot -p$mysqlRoot -e "CREATE DATABASE $nombreProyecto"

echo "\x1b[30m Creando directorio para importar BD en: $rutaWeb/$nombreProyecto/db_schema"
if [ ! -d "$rutaWeb/$nombreProyecto/db_schema" ]; then
	mkdir $rutaWeb/$nombreProyecto/db_schema/
fi

if [ -f "$rutaWeb/$nombreProyecto/db_schema/$nombreProyecto.sql" ]; then
	echo "\x1b[31m "
	mysql -uroot -p$mysqlRoot $nombreProyecto < $nombreProyecto.sql
else
	echo "\x1b[32m No se encontro el archivo $rutaWeb/$nombreProyecto/db_schema/$nombreProyecto.sql para importar la base de datos"
fi

apachectl restart