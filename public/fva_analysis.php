<?php
/**
 * FVA Analysis Controller - ANSEP3
 * Flux Variability Analysis configuration page.
 */

session_start();

// Check authentication
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

// Initialize Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

// Load model functions and database
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/model_functions.php';

// Fetch available models for selection
$models = get_all_models($pdo);

// Assign variables to template
$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('user_email', $_SESSION['user_email']);
$smarty->assign('user_id', $_SESSION['user_id']);
$smarty->assign('models', $models);

// Render FVA view
$smarty->display('fva_analysis.tpl');
