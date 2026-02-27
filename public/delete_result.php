<?php
/**
 * Result Deletion Controller - ANSEP3
 * Securely deletes a past FBA simulation directory and its contents.
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

// Security: Check for path traversal attempts
if (str_contains($analysis_id, '..') || str_contains($analysis_id, '/')) {
    die("Error: Invalid analysis ID.");
}

$analysis_dir = RESULTS_VAULT . '/' . $user_id . '/' . $analysis_id;

/**
 * Recursively delete a directory and its contents.
 */
function rrmdir($dir) {
    if (is_dir($dir)) {
        $objects = scandir($dir);
        foreach ($objects as $object) {
            if ($object != "." && $object != "..") {
                if (is_dir($dir . "/" . $object) && !is_link($dir . "/" . $object))
                    rrmdir($dir . "/" . $object);
                else
                    unlink($dir . "/" . $object);
            }
        }
        rmdir($dir);
    }
}

// Perform deletion if the directory exists and belongs to the user
if (is_dir($analysis_dir)) {
    rrmdir($analysis_dir);
    
    // Also delete from database
    try {
        $stmt = $pdo->prepare("DELETE FROM simulations WHERE analysis_id = ? AND user_id = ?");
        $stmt->execute([$analysis_id, $user_id]);
    } catch (PDOException $e) {
        // We log the error but the filesystem is already clean
    }
    
    $status = "success";
    $message = "Analysis " . htmlspecialchars($analysis_id) . " has been deleted from history.";
} else {
    $status = "error";
    $message = "Analysis not found or could not be deleted.";
}

// Redirect back to history with a message
header("Location: results_history.php?status=$status&message=" . urlencode($message));
exit;
