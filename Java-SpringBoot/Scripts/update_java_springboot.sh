#!/bin/bash
set -e

APP_USER="$SUDO_USER"
APP_HOME="/home/$APP_USER"
APP_DIR="$APP_HOME/webapp/webapp"

cd "$APP_DIR"

wget -O src/main/java/com/example/webapp/controller/MainController.java \
"https://github.com/Nahuel472/imw-vps-apps/raw/main/Java-SpringBoot/Modificaciones/controller/MainController.java"

wget -O src/main/resources/templates/index.html \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/Modificaciones/index.html"

wget -O src/main/resources/templates/contacto.html \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/Modificaciones/contacto.html"

wget -O src/main/resources/application.properties \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/Modificaciones/application.properties"

sed -i 's/^server\.port=.*/server.port=8081/' src/main/resources/application.properties

./mvnw clean package -DskipTests

systemctl restart webapp

echo "==========================================="
echo "  ACTUALIZACIÓN COMPLETADA"
echo "  Servicio reiniciado correctamente"
echo "==========================================="
