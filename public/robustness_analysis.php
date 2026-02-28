<?php
/**
 * Robustness Analysis Controller - ANSEP3
 * Renders the interface for metabolic robustness studies.
 */

session_start();
require_once __DIR__ . '/../config/paths.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/model_functions.php';

// Check authentication
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

// Fetch available models for the selector
$models = get_all_models($pdo);

// Initialize Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('models', $models);
$smarty->assign('page_title', 'Robustness Analysis');

$smarty->display('robustness_analysis.tpl');
