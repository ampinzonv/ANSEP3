<?php
/**
 * Migration Script - Phase 4: Sync Filesystem to Database
 * Scans public/results_vault/ and populates the simulations table.
 */

require_once __DIR__ . '/../config/paths.php';
$pdo = require_once __DIR__ . '/../config/database.php';

echo "Starting migration...\n";

$vault_dir = RESULTS_VAULT;
if (!is_dir($vault_dir)) {
    die("Vault directory not found: $vault_dir\n");
}

$user_folders = scandir($vault_dir);
$count = 0;

foreach ($user_folders as $user_folder) {
    if ($user_folder === '.' || $user_folder === '..') continue;
    
    $user_id = $user_folder;
    $user_dir = $vault_dir . '/' . $user_id;
    
    if (is_dir($user_dir)) {
        $analysis_folders = scandir($user_dir);
        
        foreach ($analysis_folders as $analysis_folder) {
            if ($analysis_folder === '.' || $analysis_folder === '..') continue;
            
            $analysis_path = $user_dir . '/' . $analysis_folder;
            $json_file = $analysis_path . '/' . $analysis_folder . '.json';
            
            if (file_exists($json_file)) {
                $content = file_get_contents($json_file);
                $data = json_decode($content, true);
                
                if ($data) {
                    try {
                        // Extract metadata
                        $analysis_id = $analysis_folder;
                        $analysis_name = $data['analysis_identity']['name'] ?? 'Unnamed';
                        $model_filename = $data['model_info']['filename'] ?? null;
                        $objective_value = $data['simulation_results']['objective_value'] ?? null;
                        $status = $data['simulation_results']['status'] ?? null;
                        
                        // Parse timestamp for the 'created_at' field if possible
                        // Format: 20260227_100447 -> YYYY-MM-DD HH:MM:SS
                        $raw_ts = $data['analysis_identity']['timestamp'] ?? '';
                        $created_at = null;
                        if ($raw_ts) {
                            $date_obj = DateTime::createFromFormat('Ymd_His', $raw_ts);
                            if ($date_obj) {
                                $created_at = $date_obj->format('Y-m-d H:i:s');
                            }
                        }

                        // Insert into DB
                        $stmt = $pdo->prepare("
                            INSERT IGNORE INTO simulations 
                            (user_id, analysis_id, analysis_name, model_filename, objective_value, status, created_at) 
                            VALUES (?, ?, ?, ?, ?, ?, ?)
                        ");
                        $stmt->execute([
                            $user_id,
                            $analysis_id,
                            $analysis_name,
                            $model_filename,
                            $objective_value,
                            $status,
                            $created_at
                        ]);
                        
                        if ($stmt->rowCount() > 0) {
                            echo "Indexed: $analysis_id\n";
                            $count++;
                        }
                    } catch (Exception $e) {
                        echo "Failed to index $analysis_id: " . $e->getMessage() . "\n";
                    }
                }
            }
        }
    }
}

echo "Migration finished. Total records indexed: $count\n";
