# VPS Ubuntu Web Apps — Guía de despliegue y proxy (repositorio `imw-vps-apps`)

Este documento explica cómo preparar un servidor VPS con Ubuntu y desplegar las aplicaciones incluidas en `https://github.com/Nahuel472/imw-vps-apps.git`.

> Ajusta rutas, nombres de servicio y puertos según la aplicación concreta que vayas a desplegar.

## Preparación del servidor

1. Conéctate al servidor por SSH como `root` (o un usuario con permisos para preparar el sistema):

```powershell
ssh root@<server-ip>
```

2. Clona el repositorio y muévete al directorio del proyecto:

```bash
git clone https://github.com/Nahuel472/imw-vps-apps.git
cd imw-vps-apps
```

3. Si existe un script de preparación (`production_setup.sh`), dale permisos y ejecútalo tras revisarlo:

```bash
chmod +x production_setup.sh
./production_setup.sh
```

Ese script normalmente instala dependencias, crea el usuario sin privilegios (`user`), configura `ufw` y prepara servicios básicos. Revisa el contenido antes de ejecutarlo en producción.

### Comprobaciones posteriores

- Verifica que puedes acceder como `user` (si el script creó este usuario):

```powershell
ssh user@<server-ip>
```

- Si hay problemas de conexión SSH revisa:

```bash
cat /etc/ssh/sshd_config
sudo ufw status
sudo systemctl status ssh
```

- La autenticación por contraseña puede estar deshabilitada; usa llaves SSH.

## Desplegar las aplicaciones (guía rápida)

El repositorio puede contener varias aplicaciones (Go, Spring Boot, Node, etc.). A continuación hay instrucciones generales por tipo.

### Go

```bash
cd apps/gowebapp
go build -o gowebapp
nohup ./gowebapp > /var/log/gowebapp.log 2>&1 &
```

### Java / Spring Boot

```bash
cd apps/my-springboot-app
./mvnw package -DskipTests
nohup java -jar target/myapp-0.0.1-SNAPSHOT.jar > /var/log/myapp.log 2>&1 &
```

Recomendado: crear una unidad `systemd` para gestionar la app. Ejemplo `systemd`:

```ini
[Unit]
Description=My Spring Boot App
After=network.target

[Service]
User=user
WorkingDirectory=/home/user/imw-vps-apps/apps/my-springboot-app
ExecStart=/usr/bin/java -jar /home/user/imw-vps-apps/apps/my-springboot-app/target/myapp.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Guardar como `/etc/systemd/system/myapp.service` y luego:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now myapp.service
sudo journalctl -u myapp.service -f
```

### Node.js

```bash
cd apps/my-node-app
npm ci
# correr con pm2 (recomendado)
sudo npm install -g pm2
pm2 start npm --name my-node-app -- start
pm2 save
```

## Proxy inverso con Caddy

El repositorio incluye ejemplos y scripts para configurar Caddy como proxy inverso y obtener certificados TLS automáticamente.

### Script de ejemplo

Ejecuta el script `setup_caddy_reverse_proxy` (si está incluido) con: dominio, puerto y email:

```bash
sudo bash setup_caddy_reverse_proxy example.com 8080 admin@example.com
```

Al abrir `https://example.com`, Caddy redirigirá a `http://127.0.0.1:8080` en el servidor.

### Ejemplo de `Caddyfile`

```text
{
    email admin@example.com
}

example.com {
    encode zstd gzip
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    reverse_proxy 127.0.0.1:8080
}

newapp.com {
    encode zstd gzip
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    reverse_proxy 127.0.0.1:8081
}
```

- Caddy maneja WebSockets y SSE automáticamente en `reverse_proxy`.
- Para añadir otra app: crea un `A record` en DNS apuntando a la IP del servidor y añade la sección correspondiente en el `Caddyfile`.

