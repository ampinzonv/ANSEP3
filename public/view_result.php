<?php
/**
 * Individual Result Viewer - ANSEP3
 * Loads a past JSON result and displays it using the standard results template.
 */

session_start();
require_once __DIR__ . '/../config/paths.php';
require_once __DIR__ . '/../config/database.php';

// Check authentication
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}

$user_id = $_SESSION['user_id'];
$analysis_id = $_GET['id'] ?? null;

if (!$analysis_id) {
    die("Error: No analysis ID provided.");
}

// Security: Ensure ID doesn't contain path traversal
if (str_contains($analysis_id, '..') || str_contains($analysis_id, '/')) {
    die("Error: Invalid analysis ID.");
}

$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$json_file = $analysis_dir . '/' . $analysis_id . '.json';
$log_file = $analysis_dir . '/execution.log'; // Logs are now saved here in async model

// Load execution logs if they exist
$output = "Result reference: " . $analysis_id;
if (file_exists($log_file)) {
    $output = file_get_contents($log_file);
}

// Load and decode JSON data
$result_data = null;
$success = false;

if (file_exists($json_file)) {
    $json_content = file_get_contents($json_file);
    $result_data = json_decode($json_content, true);
    if ($result_data) {
        $success = true;
    }
}

// Initialize Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('user_id', $user_id);
$smarty->assign('analysis_id', $analysis_id);
$smarty->assign('result_data', $result_data);
$smarty->assign('result_file', basename($json_file));
$smarty->assign('success', true);
// Security: Sanitize output to avoid Information Disclosure
$output = "Result loaded from archive: " . $analysis_id;
$sanitized_output = str_replace(BASE_PATH, '[ROOT]', $output);

$smarty->assign('output', $sanitized_output);

$smarty->display('analysis_result.tpl');
