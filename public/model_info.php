<?php
/**
 * Model Information Controller - ANSEP3
 * Allows users to browse metadata for available metabolic models.
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

$user_id = $_SESSION['user_id'];
$user_name = $_SESSION['user_name'];
$selected_id = $_GET['id'] ?? null;

// Initialize Smarty
$smarty = require __DIR__ . '/../config/smarty_init.php';

// 1. Fetch all models for the selector
try {
    $stmt = $pdo->query("SELECT Id, model_name, model_filename FROM models ORDER BY model_name ASC");
    $all_models = $stmt->fetchAll();
    $smarty->assign('all_models', $all_models);
} catch (PDOException $e) {
    die("Database Error: " . $e->getMessage());
}

// 2. Fetch specific model details if requested
$model_details = null;
$file_exists = false;
$file_size = 0;

if ($selected_id) {
    $model_details = get_model_by_id($pdo, $selected_id);
    
    if ($model_details) {
        $model_path = BASE_PATH . '/public/models/' . $model_details['model_filename'];
        if (file_exists($model_path)) {
            $file_exists = true;
            $file_size = filesize($model_path);
        }
    }
}

// Assign to Smarty
$smarty->assign('user_name', $user_name);
$smarty->assign('selected_id', $selected_id);
$smarty->assign('model', $model_details);
$smarty->assign('file_exists', $file_exists);
$smarty->assign('file_size', $file_size);

// Render view
$smarty->display('model_info.tpl');
