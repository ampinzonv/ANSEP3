<?php
/**
 * Smarty Initialization - ANSEP3
 */

require_once __DIR__ . '/paths.php';
require_once BASE_PATH . '/vendor/autoload.php';

$smarty = new Smarty\Smarty();

// Configuración de directorios
$smarty->setTemplateDir(SMARTY_TEMPLATES);
$smarty->setCompileDir(SMARTY_COMPILE);

if (defined('SMARTY_CACHE')) {
    $smarty->setCacheDir(SMARTY_CACHE);
}

// Opciones adicionales (opcional)
$smarty->escape_html = true; // Seguridad básica

return $smarty;
