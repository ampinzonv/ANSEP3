<?php
/**
 * FVA Documentation Controller - ANSEP3
 */

session_start();

// Check authentication
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

// Initialize Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

// Assign user metadata
$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('user_email', $_SESSION['user_email']);
$smarty->assign('user_id', $_SESSION['user_id']);

// Render the template
$smarty->display('docs_fva.tpl');
