#!/bin/bash

# UT2-A1. Script de despliegue automático para aplicación Spring Boot
# Este script configura todo según el documento proporcionado

set -e  # Detener script en caso de error

echo "==========================================="
echo "  Despliegue Automático Spring Boot"
echo "==========================================="

# Variables configurables
USER_NAME=$(whoami)
PROJECT_NAME="webapp"
PROJECT_DIR="/home/$USER_NAME/$PROJECT_NAME"
SERVER_PORT="9090"
HTTPS_PORT="8443"
PRIVATE_IP=$(hostname -I | awk '{print $1}')

echo "Usuario: $USER_NAME"
echo "Directorio proyecto: $PROJECT_DIR"
echo "IP privada: $PRIVATE_IP"
echo ""

# 1. Actualizar sistema e instalar dependencias
echo "=== PASO 1: Instalando dependencias ==="
sudo apt update
sudo apt install -y openjdk-17-jdk git wget unzip mkcert libnss3-tools

# Verificar instalación de Java
echo "Verificando Java..."
java -version

# 2. Crear estructura del proyecto
echo ""
echo "=== PASO 2: Creando estructura del proyecto ==="
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Crear estructura de directorios Maven
mkdir -p src/main/java/com/example/$PROJECT_NAME/controller
mkdir -p src/main/resources/templates
mkdir -p src/main/resources/certs
mkdir -p src/main/resources/static

# 3. Crear archivo pom.xml
echo "=== PASO 3: Creando pom.xml ==="
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.4.11</version>
        <relativePath/>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>webapp</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>webapp</name>
    <description>Aplicación web básica con Spring Boot</description>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 4. Crear clase principal de Spring Boot
echo "=== PASO 4: Creando clase principal ==="
cat > src/main/java/com/example/$PROJECT_NAME/WebappApplication.java << 'EOF'
package com.example.webapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class WebappApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebappApplication.class, args);
    }
}
EOF

# 5. Crear controlador principal
echo "=== PASO 5: Creando MainController ==="
cat > src/main/java/com/example/$PROJECT_NAME/controller/MainController.java << 'EOF'
package com.example.webapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class MainController {

    @GetMapping("/")
    public String index(Model model, HttpServletRequest request) {
        DateTimeFormatter formato = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        model.addAttribute("lenguaje", "Java - Spring Boot");
        model.addAttribute("fechahora", LocalDateTime.now().format(formato));
        model.addAttribute("ip", request.getRemoteAddr());
        model.addAttribute("navegador", request.getHeader("User-Agent"));
        model.addAttribute("versionJava", System.getProperty("java.version"));
        return "index";
    }

    @GetMapping("/contacto")
    public String contacto() {
        return "contacto";
    }
}
EOF

# 6. Crear plantilla index.html
echo "=== PASO 6: Creando plantillas Thymeleaf ==="
cat > src/main/resources/templates/index.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="es">
<head>
    <meta charset="UTF-8">
    <title>Aplicación Java - Spring Boot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
    <div class="container py-5">
        <div class="card shadow-lg p-4 border-0 rounded-4">
            <h1 class="text-center mb-4 text-primary">
                Aplicación en <span th:text="${lenguaje}">Java - Spring Boot</span>
            </h1>
            <div class="row g-3">
                <div class="col-md-6">
                    <p><strong>📅 Fecha y hora:</strong> <span th:text="${fechahora}"></span></p>
                    <p><strong>🌐 IP del cliente:</strong> <span th:text="${ip}"></span></p>
                </div>
                <div class="col-md-6">
                    <p><strong>🔍 Navegador:</strong> <span th:text="${navegador}"></span></p>
                    <p><strong>☕ Versión de Java:</strong> <span th:text="${versionJava}"></span></p>
                </div>
            </div>
            <div class="text-center mt-4">
                <a href="/contacto" class="btn btn-outline-primary">📞 Ir a contacto</a>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# 7. Crear plantilla contacto.html
cat > src/main/resources/templates/contacto.html << 'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="es">
<head>
    <meta charset="UTF-8">
    <title>Contacto - Spring Boot</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
    <div class="container py-5">
        <div class="card shadow-lg p-4 border-0 rounded-4">
            <h1 class="text-center text-success mb-4">📞 Formulario de contacto</h1>
            <form>
                <div class="mb-3">
                    <label class="form-label">Nombre</label>
                    <input type="text" class="form-control" placeholder="Tu nombre">
                </div>
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" placeholder="tu@email.com">
                </div>
                <div class="mb-3">
                    <label class="form-label">Mensaje</label>
                    <textarea class="form-control" rows="4" placeholder="Escribe tu mensaje..."></textarea>
                </div>
                <button type="submit" class="btn btn-primary w-100">Enviar</button>
            </form>
            <div class="text-center mt-4">
                <a href="/" class="btn btn-outline-secondary">🏠 Volver al inicio</a>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# 8. Configurar application.properties para HTTP
echo "=== PASO 7: Configurando application.properties ==="
cat > src/main/resources/application.properties << EOF
spring.application.name=$PROJECT_NAME

# Puerto HTTP
server.port=$SERVER_PORT

# Configuración de plantillas
spring.thymeleaf.cache=false
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
EOF

# 9. Compilar la aplicación
echo ""
echo "=== PASO 8: Compilando la aplicación ==="
cd $PROJECT_DIR
chmod +x mvnw 2>/dev/null || true

# Si no existe mvnw, usar Maven del sistema
if [ ! -f "mvnw" ]; then
    echo "Usando Maven del sistema..."
    mvn clean package -DskipTests
else
    echo "Usando Maven Wrapper..."
    ./mvnw clean package -DskipTests
fi

# 10. Configurar HTTPS con mkcert
echo ""
echo "=== PASO 9: Configurando HTTPS ==="

# Instalar CA local
mkcert -install

# Generar certificados
echo "Generando certificados para $PRIVATE_IP y localhost..."
mkcert "$PRIVATE_IP" localhost

# Convertir a formato PKCS12
echo "Convirtiendo certificados a formato PKCS12..."
openssl pkcs12 -export \
    -in "${PRIVATE_IP}+1.pem" \
    -inkey "${PRIVATE_IP}+1-key.pem" \
    -out src/main/resources/certs/webapp-keystore.p12 \
    -name "webapp" \
    -CAfile "$(mkcert -CAROOT)/rootCA.pem" \
    -caname root \
    -password pass:123456

# 11. Actualizar application.properties para HTTPS
echo "Actualizando configuración para HTTPS..."
cat >> src/main/resources/application.properties << 'EOF'

# Configuración HTTPS
server.ssl.enabled=true
server.ssl.key-store-type=PKCS12
server.ssl.key-store=classpath:certs/webapp-keystore.p12
server.ssl.key-store-password=123456
server.ssl.key-alias=webapp

# Puerto HTTPS
server.port=8443
EOF

# 12. Recompilar con HTTPS
echo "Recompilando con soporte HTTPS..."
if [ ! -f "mvnw" ]; then
    mvn clean package -DskipTests
else
    ./mvnw clean package -DskipTests
fi

# 13. Configurar servicio systemd
echo ""
echo "=== PASO 10: Configurando servicio systemd ==="
SERVICE_FILE="/etc/systemd/system/$PROJECT_NAME.service"

sudo tee $SERVICE_FILE > /dev/null << EOF
[Unit]
Description=Aplicación web Java Spring Boot
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/java -jar $PROJECT_DIR/target/$PROJECT_NAME-0.0.1-SNAPSHOT.jar
SuccessExitStatus=143
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 14. Activar y iniciar el servicio
echo "Activando servicio systemd..."
sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME
sudo systemctl start $PROJECT_NAME

# 15. Verificar estado del servicio
echo ""
echo "=== PASO 11: Verificando despliegue ==="
sleep 3
sudo systemctl status $PROJECT_NAME --no-pager

# 16. Mostrar información final
echo ""
echo "==========================================="
echo "         DESPLIEGUE COMPLETADO"
echo "==========================================="
echo "✅ Aplicación desplegada correctamente"
echo ""
echo "📊 URLs de acceso:"
echo "   HTTP:  http://$PRIVATE_IP:$SERVER_PORT"
echo "   HTTPS: https://$PRIVATE_IP:$HTTPS_PORT"
echo "   HTTPS: https://localhost:$HTTPS_PORT"
echo ""
echo "🔧 Comandos útiles:"
echo "   Ver logs: sudo journalctl -u $PROJECT_NAME -f"
echo "   Reiniciar: sudo systemctl restart $PROJECT_NAME"
echo "   Detener: sudo systemctl stop $PROJECT_NAME"
echo "   Estado: sudo systemctl status $PROJECT_NAME"
echo ""
echo "⚠️  Nota: Para evitar avisos de seguridad en HTTPS,"
echo "    instala mkcert en tu máquina cliente también."
echo "==========================================="
