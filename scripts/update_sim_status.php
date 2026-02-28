<?php
/**
 * Utility to update simulation status from the command line.
 * Usage: php update_sim_status.php <analysis_id> <status> [objective_value]
 */

require_once __DIR__ . '/../config/database.php';

if ($argc < 3) {
    die("Usage: php update_sim_status.php <analysis_id> <status> [objective_value]\n");
}

$analysis_id = $argv[1];
$status = $argv[2]; // 'success', 'error', etc.
$obj_value = isset($argv[3]) ? (double)$argv[3] : null;

try {
    $stmt = $pdo->prepare("UPDATE simulations SET status = ?, objective_value = ? WHERE analysis_id = ?");
    $stmt->execute([$status, $obj_value, $analysis_id]);
    echo "Status updated to $status for $analysis_id\n";
} catch (PDOException $e) {
    die("Error updating status: " . $e->getMessage() . "\n");
}
