# Guía de Migración a Producción — ANSEP3

> **Stack:** PHP + Smarty · MySQL · Python/CobraPy (Conda) · Apache/Nginx  
> **Origen:** MAMP local (`/Applications/MAMP/htdocs/ansep3`)  
> **Destino:** VPS Linux (Ubuntu 22.04 recomendado)

---

## 1. Requisitos en el VPS

```bash
# PHP 8.1+ con extensiones necesarias
sudo apt update
sudo apt install -y php8.1 php8.1-cli php8.1-fpm php8.1-pdo php8.1-mysql \
                   php8.1-mbstring php8.1-xml php8.1-zip

# MySQL 8
sudo apt install -y mysql-server

# Apache (o Nginx si prefieres)
sudo apt install -y apache2
sudo a2enmod rewrite

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Miniconda (para CobraPy)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /opt/miniconda3
echo 'export PATH="/opt/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 2. Transferir los Archivos

### Opción A — rsync (recomendado)

```bash
# Desde tu Mac, excluye conda_env (se reinstala en el servidor) y templates_c
rsync -avz --exclude='conda_env/' \
           --exclude='templates_c/' \
           --exclude='vendor/' \
           --exclude='.git/' \
           /Applications/MAMP/htdocs/ansep3/ \
           usuario@TU_SERVIDOR_IP:/var/www/ansep3/
```

### Opción B — Git

```bash
# En el servidor
git clone https://github.com/tu-usuario/ansep3.git /var/www/ansep3
```

---

## 3. Instalar Dependencias PHP

```bash
cd /var/www/ansep3
composer install --no-dev --optimize-autoloader
```

---

## 4. Recrear el Entorno Conda

El `conda_env` no se transfiere — se reconstruye en el servidor:

```bash
cd /var/www/ansep3
/opt/miniconda3/bin/conda create --prefix ./conda_env python=3.10 -c conda-forge -y
./conda_env/bin/pip install python-libsbml cobra pandas matplotlib

# Verificar
./conda_env/bin/python -c "import cobra; print('CobraPy OK')"
```

---

## 5. Configurar la Base de Datos

```bash
# Crear DB y usuario seguro (NO usar root en producción)
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
# Importar el esquema
mysql -u ansep3_user -p ANSEP3 < /var/www/ansep3/scripts/setup_database.sql

# Si tienes datos existentes, exportar desde MAMP primero:
# (en tu Mac)
/Applications/MAMP/Library/bin/mysqldump -u root -proot ANSEP3 > ansep3_dump.sql
# Luego transferir y ejecutar en el servidor:
mysql -u ansep3_user -p ANSEP3 < ansep3_dump.sql
```

---

## 6. Actualizar Archivos de Configuración

### `config/paths.php` — CRÍTICO

Reemplaza **todas** las rutas de MAMP con las del VPS:

```php
<?php
/**
 * Configuración de Rutas Globales - ANSEP3
 * Entorno: PRODUCCIÓN
 */

define('BASE_PATH', '/var/www/ansep3');

// Conda instalado en /opt/miniconda3 en el servidor
define('CONDA_BIN', '/opt/miniconda3/bin/conda');
define('CONDA_ENV', BASE_PATH . '/conda_env');

define('SCRIPTS_PATH', BASE_PATH . '/scripts');
define('RESULTS_VAULT', BASE_PATH . '/public/results_vault');

define('SMARTY_TEMPLATES', BASE_PATH . '/templates');
define('SMARTY_COMPILE', BASE_PATH . '/templates_c');
define('SMARTY_CACHE', BASE_PATH . '/cache');

// Cambia esto por tu dominio real
define('BASE_URL', 'https://tudominio.com');
```

### `config/database.php` — CRÍTICO

```php
<?php
$host    = 'localhost';
$db      = 'ANSEP3';
$user    = 'ansep3_user';       // usuario creado en paso 5
$pass    = 'CONTRASEÑA_SEGURA'; // la contraseña real
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
# Propietario: www-data (usuario de Apache)
sudo chown -R www-data:www-data /var/www/ansep3

# Directorios que necesitan escritura
sudo chmod -R 775 /var/www/ansep3/templates_c
sudo chmod -R 775 /var/www/ansep3/public/results_vault
sudo chmod -R 775 /var/www/ansep3/cache   # si existe

# El usuario actual en el grupo www-data (para poder editar archivos)
sudo usermod -aG www-data $USER
```

---

## 8. Virtual Host Apache

```bash
sudo nano /etc/apache2/sites-available/ansep3.conf
```

```apache
<VirtualHost *:80>
    ServerName tudominio.com
    ServerAlias www.tudominio.com

    DocumentRoot /var/www/ansep3/public

    <Directory /var/www/ansep3/public>
        AllowOverride All
        Require all granted
    </Directory>

    # Logs
    ErrorLog ${APACHE_LOG_DIR}/ansep3_error.log
    CustomLog ${APACHE_LOG_DIR}/ansep3_access.log combined
</VirtualHost>
```

```bash
sudo a2ensite ansep3.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
```

### HTTPS con Let's Encrypt (recomendado)

```bash
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache -d tudominio.com -d www.tudominio.com
```

---

## 9. Configurar PHP para Ejecución de Scripts Python

Los scripts Python se ejecutan vía `shell_exec()` desde PHP. El usuario `www-data` debe poder correr Conda:

```bash
# Verificar que www-data puede ejecutar python del conda_env
sudo -u www-data /var/www/ansep3/conda_env/bin/python -c "import cobra; print('OK')"
```

Si falla, ajustar permisos del conda_env:

```bash
sudo chmod -R 755 /var/www/ansep3/conda_env/bin
```

### Aumentar tiempo de ejecución PHP (los análisis pueden tardar)

```bash
sudo nano /etc/php/8.1/apache2/php.ini
```

```ini
max_execution_time = 300
memory_limit = 512M
upload_max_filesize = 50M
post_max_size = 50M
```

```bash
sudo systemctl restart apache2
```

---

## 10. Verificación Final

```bash
# 1. PHP conecta a MySQL
php -r "require '/var/www/ansep3/config/database.php'; echo 'DB OK\n';"

# 2. Smarty compila templates (intentar renderizar)
curl -I http://tudominio.com/login.php

# 3. Script Python funciona
sudo -u www-data /var/www/ansep3/conda_env/bin/python \
    /var/www/ansep3/scripts/fba_analysis.py --help

# 4. Logs de Apache si algo falla
sudo tail -f /var/log/apache2/ansep3_error.log
```

---

## Resumen de Archivos a Modificar

| Archivo | Cambio |
|---|---|
| `config/paths.php` | BASE_PATH, CONDA_BIN, BASE_URL |
| `config/database.php` | user, pass (nunca usar root) |

## Checklist

- [ ] Servidor con PHP 8.1+, MySQL 8, Apache
- [ ] Miniconda instalado en `/opt/miniconda3`
- [ ] Archivos transferidos con rsync (sin `conda_env/`, `vendor/`, `templates_c/`)
- [ ] `composer install` ejecutado
- [ ] `conda_env` recreado en el servidor
- [ ] Base de datos creada con usuario dedicado
- [ ] `config/paths.php` actualizado
- [ ] `config/database.php` actualizado
- [ ] Permisos de `templates_c/` y `results_vault/` en 775
- [ ] Virtual host configurado y activo
- [ ] HTTPS habilitado con Certbot
- [ ] `php.ini` con `max_execution_time = 300`
- [ ] Prueba de login exitosa
- [ ] Prueba de análisis FBA exitosa
