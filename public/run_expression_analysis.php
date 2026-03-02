<?php
/**
 * Expression Execution Bridge - ANSEP3
 * Handles file upload and launches exp2flux integration.
 */

session_start();
require_once __DIR__ . '/../config/paths.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/model_functions.php';

// Allow AJAX or Form response
header('Content-Type: application/json');

// Check authentication
if (!isset($_SESSION['user_id'])) {
    echo json_encode(['status' => 'error', 'message' => 'Unauthorized session.']);
    exit;
}

$user_id = $_SESSION['user_id'];
$model_id = $_POST['model_id'] ?? null;
$missing_strategy = $_POST['missing_strategy'] ?? 'mean';
$scale = isset($_POST['scale']) ? true : false;
$analysis_name = $_POST['analysis_name'] ?? ("Expression Analysis " . date('Y-m-d H:i'));

if (!$model_id || !isset($_FILES['expression_file'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing Model ID or Expression File.']);
    exit;
}

// Fetch model details
$model = get_model_by_id($pdo, $model_id);
if (!$model) {
    echo json_encode(['status' => 'error', 'message' => 'Selected model not found.']);
    exit;
}

$model_file = BASE_PATH . '/public/models/' . $model['model_filename'];

// Setup directory and IDs
$timestamp = date('Ymd_His');
$analysis_id = 'expression_result_' . $timestamp;
$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;

// Pre-flight check: Ensure model file exists
if (!file_exists($model_file)) {
    echo json_encode(['status' => 'error', 'message' => 'Model file not found on server: ' . $model['model_filename']]);
    exit;
}

if (!is_dir($analysis_dir)) {
    mkdir($analysis_dir, 0777, true);
}

// 1. Handle File Upload
$expression_filename = 'expression_data.csv';
$expression_path = $analysis_dir . '/' . $expression_filename;

if (!move_uploaded_file($_FILES['expression_file']['tmp_name'], $expression_path)) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to save expression data to server.']);
    exit;
}

// 2. Prepare JSON Payload
$payload = [
    'model_path' => $model_file,
    'expression_path' => $expression_path,
    'output_dir' => $analysis_dir,
    'analysis_name' => $analysis_name,
    'missing_strategy' => $missing_strategy,
    'scale' => $scale,
    'analysis_id' => $analysis_id,
    'timestamp' => $timestamp
];

$payload_file = $analysis_dir . '/payload.json';
file_put_contents($payload_file, json_encode($payload, JSON_PRETTY_PRINT));

// 3. Register in Database
try {
    $stmt = $pdo->prepare("
        INSERT INTO simulations 
        (user_id, analysis_id, analysis_name, analysis_type, model_id, model_filename, execution_status) 
        VALUES (?, ?, ?, 'EXPRESSION', ?, ?, 'processing')
    ");
    $stmt->execute([
        $user_id,
        $analysis_id,
        $analysis_name,
        $model_id,
        $model['model_filename']
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
    exit;
}

// 4. Construct Command
$env_python = CONDA_ENV . '/bin/python';
$log_file = $analysis_dir . '/execution.log';

$command = sprintf(
    '%s %s --payload %s > %s 2>&1 &',
    escapeshellarg($env_python),
    escapeshellarg(SCRIPTS_PATH . '/expression_analysis.py'),
    escapeshellarg($payload_file),
    escapeshellarg($log_file)
);

// Execute background process
exec($command);

// 5. Return Response
echo json_encode([
    'status' => 'launched',
    'analysis_id' => $analysis_id,
    'message' => 'Expression Analysis (exp2flux) launched successfully.'
]);
exit;
