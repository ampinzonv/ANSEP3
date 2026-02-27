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
$timestamp = date('Ymd_His');
$analysis_id = 'fba_result_' . $timestamp;
$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$output_file = $analysis_dir . '/' . $analysis_id . '.json';

// Ensure analysis directory exists
if (!is_dir($analysis_dir)) {
    mkdir($analysis_dir, 0777, true);
}

// Construct Shell Command (Synchronous using direct python path)
$env_python = CONDA_ENV . '/bin/python';
$command = sprintf(
    '%s %s --model %s --objective %s --output %s --name %s --only-active %s --top-n %s 2>&1',
    escapeshellarg($env_python),
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
$success = str_contains($output, 'Success:');

// Read JSON data if successful and register in database
$result_data = null;
if ($success && file_exists($output_file)) {
    $json_content = file_get_contents($output_file);
    $result_data = json_decode($json_content, true);

    if ($result_data) {
        try {
            // Prepare and execute database insertion
            $stmt = $pdo->prepare("
                INSERT INTO simulations 
                (user_id, analysis_id, analysis_name, model_id, model_filename, objective_value, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $user_id,
                $analysis_id,
                $analysis_name,
                $model_id,
                $model['model_filename'],
                $result_data['simulation_results']['objective_value'],
                $result_data['simulation_results']['status']
            ]);
        } catch (PDOException $e) {
            // We log the error in the output for debugging but don't stop the flow
            $output .= "\nWarning: Could not register analysis in database: " . $e->getMessage();
        }
    }
}

// Security: Sanitize paths in command and output to avoid Information Disclosure
$sanitized_command = str_replace(BASE_PATH, '[ROOT]', $command);
$sanitized_output  = str_replace(BASE_PATH, '[ROOT]', $output);

// Logic to handle the view
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('user_id', $user_id);
$smarty->assign('analysis_id', $analysis_id);
$smarty->assign('command', $sanitized_command);
$smarty->assign('output', $sanitized_output);
$smarty->assign('result_data', $result_data);
$smarty->assign('result_file', basename($output_file));
$smarty->assign('success', $success);

$smarty->display('analysis_result.tpl');
