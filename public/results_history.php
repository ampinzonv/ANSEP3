<?php
/**
 * Results Gallery Controller - ANSEP3
 * Lists all past FBA simulations for the current user using the database.
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

// Get Results from Database
$stmt = $pdo->prepare("
    SELECT 
        analysis_id, 
        analysis_name as name, 
        model_filename as model, 
        objective_value as objective, 
        status, 
        execution_status,
        created_at as raw_date
    FROM simulations 
    WHERE user_id = ? 
    ORDER BY created_at DESC
");
$stmt->execute([$user_id]);
$raw_history = $stmt->fetchAll();

$history = [];
foreach ($raw_history as $row) {
    // Format timestamp for display
    $formatted_date = '-';
    if ($row['raw_date']) {
        $date_obj = new DateTime($row['raw_date']);
        $formatted_date = $date_obj->format('M j, Y - H:i');
    }

    $history[] = [
        'analysis_id'     => $row['analysis_id'],
        'name'            => $row['name'],
        'date'            => $formatted_date,
        'model'           => $row['model'],
        'objective'       => $row['objective'],
        'status'          => $row['status'],
        'execution_status' => $row['execution_status']
    ];
}

// Initialize Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

$smarty->assign('user_name', $_SESSION['user_name']);
$smarty->assign('history', $history);

$smarty->display('results_history.tpl');
