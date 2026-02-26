<?php
/**
 * FBA Execution Bridge - ANSEP3
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
$model_id = $_POST['model_id'] ?? null;
$objective = $_POST['objective'] ?? null;
$analysis_name = $_POST['analysis_name'] ?? 'Unnamed Analysis';
$only_active = isset($_POST['only_active']) ? '1' : '0';
$top_n = $_POST['top_n'] ?? '20';

if (!$model_id || !$objective) {
    die("Error: Missing required parameters (Model or Objective).");
}

// Fetch model details from Database
$model = get_model_by_id($pdo, $model_id);
if (!$model) {
    die("Error: Selected model not found in database.");
}

// Define Paths
$model_file = BASE_PATH . '/public/models/' . $model['model_filename'];
$user_results_dir = RESULTS_VAULT . '/' . $user_id;
$timestamp = date('Ymd_His');
$output_file = $user_results_dir . '/fba_result_' . $timestamp . '.txt';

// Ensure user directory exists
if (!is_dir($user_results_dir)) {
    mkdir($user_results_dir, 0777, true);
}

// Construct Shell Command
$command = sprintf(
    '%s run -p %s python %s --model %s --objective %s --output %s --name %s --only-active %s --top-n %s 2>&1',
    escapeshellarg(CONDA_BIN),
    escapeshellarg(CONDA_ENV),
    escapeshellarg(SCRIPTS_PATH . '/fba_analysis.py'),
    escapeshellarg($model_file),
    escapeshellarg($objective),
    escapeshellarg($output_file),
    escapeshellarg($analysis_name),
    escapeshellarg($only_active),
    escapeshellarg($top_n)
);

// Execute the command
$output = shell_exec($command);

// Logic to handle the view
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

// In some setups smarty_init returns the object, in others it's global.
// Based on previous steps, $smarty = require_once ... is the pattern.

$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('command', $command);
$smarty->assign('output', $output);
$smarty->assign('result_file', basename($output_file));
$smarty->assign('success', str_contains($output, 'Success:'));

// We can reuse a simple "Results" block or create a new template.
// For now, let's redirect to a results view or show it in a block in loggedin.tpl?
// Let's create a tiny result page.
$smarty->display('analysis_result.tpl');
