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

// Pre-flight check: Ensure model file actually exists before launching
if (!file_exists($model_file)) {
    header('Content-Type: application/json');
    echo json_encode([
        'status' => 'error',
        'message' => 'Model file not found on server: ' . $model['model_filename']
    ]);
    exit;
}

$timestamp = date('Ymd_His');
$analysis_id = 'fba_result_' . $timestamp;
$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$output_file = $analysis_dir . '/' . $analysis_id . '.json';

// Ensure analysis directory exists
if (!is_dir($analysis_dir)) {
    mkdir($analysis_dir, 0777, true);
}

// 1. Initial Database Registration (Status: processing)
try {
    $stmt = $pdo->prepare("
        INSERT INTO simulations 
        (user_id, analysis_id, analysis_name, model_id, model_filename, execution_status) 
        VALUES (?, ?, ?, ?, ?, 'processing')
    ");
    $stmt->execute([
        $user_id,
        $analysis_id,
        $analysis_name,
        $model_id,
        $model['model_filename']
    ]);
} catch (PDOException $e) {
    die("Error: Could not register analysis: " . $e->getMessage());
}

// 2. Construct Shell Command (Asynchronous using &)
$env_python = CONDA_ENV . '/bin/python';
$log_file = $analysis_dir . '/execution.log';

$command = sprintf(
    '%s %s --model %s --objective %s --output %s --name %s --only-active %s --top-n %s > %s 2>&1 &',
    escapeshellarg($env_python),
    escapeshellarg(SCRIPTS_PATH . '/fba_analysis.py'),
    escapeshellarg($model_file),
    escapeshellarg($objective),
    escapeshellarg($output_file),
    escapeshellarg($analysis_name),
    escapeshellarg($only_active),
    escapeshellarg($top_n),
    escapeshellarg($log_file)    // Direct logs to file
);

// Execute the command in the background
exec($command);

// 3. Return JSON Response for AJAX handling
header('Content-Type: application/json');
echo json_encode([
    'status' => 'launched',
    'analysis_id' => $analysis_id,
    'message' => 'Simulation started in background.'
]);
exit;
