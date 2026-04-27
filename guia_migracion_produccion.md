# Guía de Migración a Producción — ANSEP3

> **Stack:** PHP + Smarty · MySQL · Python/CobraPy (Conda) · Nginx  
> **Origen:** MAMP local (`/Applications/MAMP/htdocs/ansep3`)  
> **Destino:** VPS `168.176.61.231` — accesible en `http://168.176.61.231/ansep3`

---

## 1. Requisitos en el VPS

```bash
# Agregar repositorio de PHP
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# PHP 8.4 + extensiones necesarias
sudo apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-pdo php8.4-mysql \
                   php8.4-mbstring php8.4-xml php8.4-zip

# MySQL 8
sudo apt install -y mysql-server

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Miniconda (para CobraPy)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /opt/miniconda3
echo 'export PATH="/opt/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Aceptar términos de servicio de Conda (requerido desde versiones recientes)
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

---

## 2. Transferir los Archivos

```bash
# Desde tu Mac — excluye lo que se reconstruye en el servidor
rsync -avz --exclude='conda_env/' \
           --exclude='templates_c/' \
           --exclude='vendor/' \
           --exclude='.git/' \
           /Applications/MAMP/htdocs/ansep3/ \
           usuario@168.176.61.231:/var/www/html/ansep3/
```

---

## 3. Instalar Dependencias PHP

```bash
cd /var/www/html/ansep3
composer install --no-dev --optimize-autoloader
```

---

## 4. Recrear el Entorno Conda

El `conda_env` no se transfiere — se reconstruye en el servidor:

```bash
cd /var/www/html/ansep3
/opt/miniconda3/bin/conda create --prefix ./conda_env python=3.10 -c conda-forge -y
./conda_env/bin/pip install python-libsbml cobra pandas matplotlib

# Verificar
./conda_env/bin/python -c "import cobra; print('CobraPy OK')"
```

---

## 5. Configurar la Base de Datos

```bash
sudo mysql -u root
```

```sql
CREATE DATABASE ANSEP3 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'ansep3_user'@'localhost' IDENTIFIED BY 'CONTRASEÑA_SEGURA';
GRANT ALL PRIVILEGES ON ANSEP3.* TO 'ansep3_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# Exportar desde MAMP (en tu Mac)
/Applications/MAMP/Library/bin/mysql80/bin/mysqldump -u root -proot ANSEP3 > ansep3_dump.sql

# Transferir al servidor
scp ansep3_dump.sql usuario@168.176.61.231:/var/www/html/ansep3/

# Importar en el servidor
mysql -u ansep3_user -p ANSEP3 < /var/www/html/ansep3/ansep3_dump.sql
```

---

## 6. Actualizar Archivos de Configuración

### `config/paths.php` — CRÍTICO

```php
<?php
/**
 * Configuración de Rutas Globales - ANSEP3
 * Entorno: PRODUCCIÓN
 */

define('BASE_PATH', '/var/www/html/ansep3');

define('CONDA_BIN', '/opt/miniconda3/bin/conda');
define('CONDA_ENV', BASE_PATH . '/conda_env');

define('SCRIPTS_PATH', BASE_PATH . '/scripts');
define('RESULTS_VAULT', BASE_PATH . '/public/results_vault');

define('SMARTY_TEMPLATES', BASE_PATH . '/templates');
define('SMARTY_COMPILE', BASE_PATH . '/templates_c');
define('SMARTY_CACHE', BASE_PATH . '/cache');

define('BASE_URL', 'http://168.176.61.231/ansep3');
```

### `config/database.php` — CRÍTICO

```php
<?php
$host    = 'localhost';
$db      = 'ANSEP3';
$user    = 'ansep3_user';
$pass    = 'CONTRASEÑA_SEGURA';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    return $pdo;
} catch (\PDOException $e) {
    error_log("DB Connection Error: " . $e->getMessage());
    die("Error de conexión a base de datos.");
}
```

---

## 7. Permisos de Directorios

```bash
# Crear directorios que no vienen en el rsync
mkdir -p /var/www/html/ansep3/templates_c
mkdir -p /var/www/html/ansep3/cache
mkdir -p /var/www/html/ansep3/public/results_vault

# Directorios de caché para paquetes Python (CobraPy, Matplotlib)
# Necesarios para que www-data pueda escribir al ejecutar scripts
sudo mkdir -p /var/www/.cache/cobrapy
sudo mkdir -p /var/www/.config/matplotlib
sudo mkdir -p /var/www/.local
sudo chown -R www-data:www-data /var/www/.cache /var/www/.config /var/www/.local
sudo chmod -R 775 /var/www/.cache /var/www/.config /var/www/.local

# Permisos generales del proyecto
sudo chmod -R 775 /var/www/html/ansep3/templates_c
sudo chmod -R 775 /var/www/html/ansep3/cache
sudo chmod -R 775 /var/www/html/ansep3/public/results_vault
sudo chown -R www-data:www-data /var/www/html/ansep3

# Agregar tu usuario al grupo www-data
sudo usermod -aG www-data $USER
```

---

## 8. Configuración Nginx

```bash
sudo nano /etc/nginx/sites-available/ansep3
```

```nginx
server {
    listen 80;
    server_name 168.176.61.231;

    # /ansep3 apunta a la carpeta /public del proyecto
    location /ansep3 {
        alias /var/www/html/ansep3/public;
        index index.php index.html;
        try_files $uri $uri/ @ansep3_php;
    }

    location @ansep3_php {
        rewrite ^/ansep3(.*)$ /ansep3/index.php?$query_string last;
    }

    # Captura el path relativo con $1 para evitar duplicar /ansep3 en SCRIPT_FILENAME
    location ~ ^/ansep3/(.+\.php)$ {
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/html/ansep3/public/$1;
        include fastcgi_params;
    }

    # Bloquear acceso directo a directorios sensibles
    location ~* ^/ansep3/(config|scripts|templates|vendor)/ {
        deny all;
    }

    error_log /var/log/nginx/ansep3_error.log;
    access_log /var/log/nginx/ansep3_access.log;
}
```

```bash
# Activar el sitio y desactivar el default
sudo ln -s /etc/nginx/sites-available/ansep3 /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx
```

---

## 9. Iniciar PHP 8.4-FPM

```bash
sudo systemctl enable php8.4-fpm
sudo systemctl start php8.4-fpm
sudo systemctl status php8.4-fpm
```

### Ajustar php.ini para análisis largos

```bash
sudo nano /etc/php/8.4/fpm/php.ini
```

```ini
max_execution_time = 300
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
```

```bash
sudo systemctl restart php8.4-fpm
sudo systemctl reload nginx
```

---

## 10. Permisos de Ejecución Python para www-data

```bash
# Verificar que www-data puede ejecutar python del conda_env
sudo -u www-data /var/www/html/ansep3/conda_env/bin/python -c "import cobra; print('OK')"

# Si falla con permisos
sudo chmod -R 755 /var/www/html/ansep3/conda_env/bin
```

---

## 11. Verificación Final

```bash
# 1. PHP conecta a MySQL
php -r "require '/var/www/html/ansep3/config/database.php'; echo 'DB OK\n';"

# 2. Acceso web desde el servidor
curl -I http://localhost/ansep3

# 3. Script Python funciona
sudo -u www-data /var/www/html/ansep3/conda_env/bin/python \
    /var/www/html/ansep3/scripts/fba_analysis.py --help

# 4. Logs si algo falla
sudo tail -f /var/log/nginx/ansep3_error.log
```

---

## Resumen de Archivos a Modificar

| Archivo | Cambio |
|---|---|
| `config/paths.php` | BASE_PATH → `/var/www/html/ansep3`, BASE_URL → `http://168.176.61.231/ansep3` |
| `config/database.php` | user, pass (nunca usar root en producción) |

---

## Checklist

- [ ] PHP 8.4 instalado (vía PPA `ondrej/php`)
- [ ] MySQL 8 instalado y corriendo
- [ ] Nginx instalado y corriendo
- [ ] PHP 8.4-FPM habilitado e iniciado
- [ ] Miniconda instalado en `/opt/miniconda3` y ToS aceptados
- [ ] Archivos transferidos con rsync (sin `conda_env/`, `vendor/`, `templates_c/`)
- [ ] `composer install` ejecutado en `/var/www/html/ansep3`
- [ ] `conda_env` recreado en el servidor
- [ ] Base de datos creada con usuario dedicado e importada
- [ ] `config/paths.php` actualizado con rutas del VPS
- [ ] `config/database.php` actualizado con credenciales de producción
- [ ] Directorios `templates_c/`, `cache/` y `results_vault/` creados con permisos 775
- [ ] Directorios `/var/www/.cache`, `/var/www/.config`, `/var/www/.local` creados para www-data
- [ ] `www-data` como propietario de todo el proyecto
- [ ] Sitio `default` de Nginx desactivado
- [ ] Virtual host `ansep3` activado en Nginx con socket `php8.4-fpm.sock`
- [ ] `php.ini` (FPM) con `max_execution_time = 300`
- [ ] Prueba de login exitosa en `http://168.176.61.231/ansep3`
- [ ] Prueba de análisis FBA exitosa
