<?php
/**
 * File-based Status Checker for Polling - ANSEP3
 * Checks for the existence of the result JSON file.
 */

require_once __DIR__ . '/../config/paths.php';
require_once __DIR__ . '/../config/database.php';

header('Content-Type: application/json');

$analysis_id = $_GET['id'] ?? null;
$user_id = $_SESSION['user_id'] ?? 1; // Fallback for debugging, though session should be active

if (!$analysis_id) {
    echo json_encode(['status' => 'error', 'message' => 'Missing Analysis ID']);
    exit;
}

$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;
$json_file = $analysis_dir . '/' . $analysis_id . '.json';
$log_file = $analysis_dir . '/execution.log';
$done_file = $analysis_dir . '/process.done';

try {
    // 1. Check if the process is finished (flag exists)
    $is_finished = file_exists($done_file);

    // 2. If JSON exists, it's a success regardless of the flag (robustness)
    if (file_exists($json_file)) {
        // Success! Update DB if not already updated
        $stmt = $pdo->prepare("SELECT execution_status FROM simulations WHERE analysis_id = ?");
        $stmt->execute([$analysis_id]);
        $sim = $stmt->fetch();

        if ($sim && $sim['execution_status'] !== 'success') {
            // Load scientific results from JSON
            $json_data = json_decode(file_get_contents($json_file), true);
            $sci_status = $json_data['simulation_results']['status'] ?? 'Optimal';
            
            // FVA doesn't have a single objective_value
            $obj_val = $json_data['simulation_results']['objective_value'] ?? null;

            $update = $pdo->prepare("
                UPDATE simulations 
                SET execution_status = 'success', 
                    status = ?, 
                    objective_value = ? 
                WHERE analysis_id = ?
            ");
            $update->execute([$sci_status, $obj_val, $analysis_id]);
        }
        
        echo json_encode(['status' => 'success']);
        exit;
    }

    // 3. If finished but NO JSON exists -> It's a CRASH or ERROR
    if ($is_finished) {
        // Update DB to error
        $update = $pdo->prepare("UPDATE simulations SET execution_status = 'error' WHERE analysis_id = ?");
        $update->execute([$analysis_id]);
        
        echo json_encode(['status' => 'error']);
        exit;
    }

    // 4. Check for immediate errors in logs even if not "finished" 
    // (useful for early crashes or syntax errors)
    if (file_exists($log_file) && filesize($log_file) > 0) {
        $log_content = file_get_contents($log_file);
        if (str_contains($log_content, 'Traceback') || str_contains($log_content, 'Error:')) {
            $update = $pdo->prepare("UPDATE simulations SET execution_status = 'error' WHERE analysis_id = ?");
            $update->execute([$analysis_id]);
            echo json_encode(['status' => 'error']);
            exit;
        }
    }

    // 5. Otherwise, it's still processing
    echo json_encode(['status' => 'processing']);

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error']);
}
