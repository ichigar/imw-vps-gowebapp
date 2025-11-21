#!/bin/bash
set -e

APP_USER="$SUDO_USER"
APP_HOME="/home/$APP_USER"
APP_DIR="$APP_HOME/webapp"
SERVICE_FILE="/etc/systemd/system/webapp.service"

apt update -y
apt install -y openjdk-17-jdk git wget unzip

mkdir -p "$APP_DIR"
cd "$APP_DIR"

wget -O webapp.zip "https://github.com/Nahuel472/imw-vps-apps/raw/main/Java-SpringBoot/webapp.zip"
unzip -o webapp.zip
cd webapp

mkdir -p src/main/java/com/example/webapp/controller
mkdir -p src/main/resources/templates

wget -O src/main/java/com/example/webapp/controller/MainController.java \
"https://github.com/Nahuel472/imw-vps-apps/raw/main/Java-SpringBoot/controller/MainController.java"

wget -O src/main/resources/templates/index.html \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/index.html"

wget -O src/main/resources/templates/contacto.html \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/contacto.html"

wget -O src/main/resources/application.properties \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/application.properties"

sed -i 's/^server\.port=.*/server.port=8081/' src/main/resources/application.properties

./mvnw clean package -DskipTests

wget -O "$SERVICE_FILE" \
"https://raw.githubusercontent.com/Nahuel472/imw-vps-apps/main/Java-SpringBoot/webapp.service"

sed -i "s|User=.*|User=$APP_USER|" "$SERVICE_FILE"
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$APP_DIR/webapp|" "$SERVICE_FILE"
sed -i "s|ExecStart=.*|ExecStart=/usr/bin/java -jar $APP_DIR/webapp/target/webapp-0.0.1-SNAPSHOT.jar|" "$SERVICE_FILE"

systemctl daemon-reload
systemctl enable webapp
systemctl restart webapp

echo "==========================================="
echo "  DEPLOY COMPLETADO"
echo "  http://$(hostname -I | awk '{print $1}'):8081"
echo "==========================================="
