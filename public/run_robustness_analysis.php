<?php
/**
 * Robustness Execution Bridge - ANSEP3
 * Launches Metabolic Robustness Analysis in the background.
 */

session_start();
require_once __DIR__ . '/../config/paths.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/model_functions.php';

// Allow AJAX response
header('Content-Type: application/json');

// Check authentication
if (!isset($_SESSION['user_id'])) {
    echo json_encode(['status' => 'error', 'message' => 'Unauthorized session.']);
    exit;
}

$user_id = $_SESSION['user_id'];
$model_id = $_POST['model_id'] ?? null;
$analysis_name = $_POST['analysis_name'] ?? 'Unnamed Robustness';
$control_reaction = $_POST['control_reaction'] ?? '';
$sampling_mode = $_POST['sampling_mode'] ?? 'steps';
$steps = $_POST['steps'] ?? '20';
$step_size = $_POST['step_size'] ?? '';
$min_flux = $_POST['min_flux'] ?? '';
$max_flux = $_POST['max_flux'] ?? '';

if (!$model_id || !$control_reaction) {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters.']);
    exit;
}

// Fetch model details
$model = get_model_by_id($pdo, $model_id);
if (!$model) {
    echo json_encode(['status' => 'error', 'message' => 'Model not found.']);
    exit;
}

$model_file = BASE_PATH . '/public/models/' . $model['model_filename'];
if (!file_exists($model_file)) {
    echo json_encode(['status' => 'error', 'message' => 'Model file missing.']);
    exit;
}

$timestamp = date('Ymd_His');
$analysis_id = 'robustness_result_' . $timestamp;
$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$output_file = $analysis_dir . '/' . $analysis_id . '.json';

if (!is_dir($analysis_dir)) {
    mkdir($analysis_dir, 0777, true);
}

// 1. Database Registration
try {
    $stmt = $pdo->prepare("
        INSERT INTO simulations 
        (user_id, analysis_id, analysis_name, analysis_type, model_id, model_filename, execution_status) 
        VALUES (?, ?, ?, 'ROBUSTNESS', ?, ?, 'processing')
    ");
    $stmt->execute([
        $user_id,
        $analysis_id,
        $analysis_name,
        $model_id,
        $model['model_filename']
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Registration failed.']);
    exit;
}

// 2. Construct Command
$env_python = CONDA_ENV . '/bin/python';
$log_file = $analysis_dir . '/execution.log';

$command = sprintf(
    '%s %s --model %s --output %s --name %s --reaction %s --steps %s --step-size %s --min %s --max %s > %s 2>&1 &',
    escapeshellarg($env_python),
    escapeshellarg(SCRIPTS_PATH . '/robustness_analysis.py'),
    escapeshellarg($model_file),
    escapeshellarg($output_file),
    escapeshellarg($analysis_name),
    escapeshellarg($control_reaction),
    escapeshellarg($steps),
    escapeshellarg($step_size),
    escapeshellarg($min_flux),
    escapeshellarg($max_flux),
    escapeshellarg($log_file)
);

exec($command);

echo json_encode(['status' => 'launched', 'analysis_id' => $analysis_id]);
exit;
