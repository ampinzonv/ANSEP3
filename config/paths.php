<?php
/**
 * Configuración de Rutas Globales - ANSEP3
 */

// Ruta raíz del proyecto en el servidor
define('BASE_PATH', '/Applications/MAMP/htdocs/ansep3');

// Ruta al binario de Conda y al entorno específico
define('CONDA_BIN', '/Users/apinzon/.environments/miniconda3/bin/conda'); 
define('CONDA_ENV', BASE_PATH . '/conda_env');

// Rutas de almacenamiento
define('SCRIPTS_PATH', BASE_PATH . '/scripts');
define('RESULTS_VAULT', BASE_PATH . '/results_vault');

// Configuración de Smarty
define('SMARTY_TEMPLATES', BASE_PATH . '/templates');
define('SMARTY_COMPILE', BASE_PATH . '/templates_c');
define('SMARTY_CACHE', BASE_PATH . '/cache');

// URL Base para redirecciones y assets
define('BASE_URL', 'http://localhost:8888/ansep3');