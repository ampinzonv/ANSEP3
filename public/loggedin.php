<?php
/**
 * Logged In Controller - ANSEP3
 */

session_start();

// Verificar si el usuario está autenticado
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

// Inicializar Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

// Pasar datos del usuario a la plantilla
$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('user_email', $_SESSION['user_email']);
$smarty->assign('user_id', $_SESSION['user_id']);

// Renderizar la plantilla
$smarty->display('loggedin.tpl');
