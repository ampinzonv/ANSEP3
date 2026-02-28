<?php
/**
 * FVA Execution Bridge - ANSEP3
 * Launches Flux Variability Analysis in the background.
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
$analysis_name = $_POST['analysis_name'] ?? 'Unnamed FVA';
$fraction_optimum = $_POST['fraction_optimum'] ?? '0.9';
$loopless = isset($_POST['loopless']) ? '1' : '0';
$processes = $_POST['processes'] ?? '2';

if (!$model_id) {
    echo json_encode(['status' => 'error', 'message' => 'Missing Model ID.']);
    exit;
}

// Fetch model details from Database
$model = get_model_by_id($pdo, $model_id);
if (!$model) {
    echo json_encode(['status' => 'error', 'message' => 'Selected model not found in database.']);
    exit;
}

// Define Paths
$model_file = BASE_PATH . '/public/models/' . $model['model_filename'];

// Pre-flight check: Ensure model file actually exists
if (!file_exists($model_file)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Model file not found on server: ' . $model['model_filename']
    ]);
    exit;
}

$timestamp = date('Ymd_His');
$analysis_id = 'fva_result_' . $timestamp;
$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$output_file = $analysis_dir . '/' . $analysis_id . '.json';

// Ensure analysis directory exists
if (!is_dir($analysis_dir)) {
    mkdir($analysis_dir, 0777, true);
}

// 1. Initial Database Registration
try {
    $stmt = $pdo->prepare("
        INSERT INTO simulations 
        (user_id, analysis_id, analysis_name, analysis_type, model_id, model_filename, execution_status) 
        VALUES (?, ?, ?, 'FVA', ?, ?, 'processing')
    ");
    $stmt->execute([
        $user_id,
        $analysis_id,
        $analysis_name,
        $model_id,
        $model['model_filename']
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Could not register analysis in DB: ' . $e->getMessage()]);
    exit;
}

// 2. Construct Shell Command (Asynchronous using &)
$env_python = CONDA_ENV . '/bin/python';
$log_file = $analysis_dir . '/execution.log';

$command = sprintf(
    '%s %s --model %s --output %s --name %s --fraction %s --loopless %s --processes %s > %s 2>&1 &',
    escapeshellarg($env_python),
    escapeshellarg(SCRIPTS_PATH . '/fva_analysis.py'),
    escapeshellarg($model_file),
    escapeshellarg($output_file),
    escapeshellarg($analysis_name),
    escapeshellarg($fraction_optimum),
    escapeshellarg($loopless),
    escapeshellarg($processes),
    escapeshellarg($log_file)
);

// Execute the command in the background
exec($command);

// 3. Return JSON Response for AJAX
echo json_encode([
    'status' => 'launched',
    'analysis_id' => $analysis_id,
    'message' => 'FVA Simulation started in background.'
]);
exit;
