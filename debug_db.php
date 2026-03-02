<?php
require_once __DIR__ . '/config/database.php';
try {
    $stmt = $pdo->prepare("SELECT * FROM simulations WHERE created_at >= '2026-03-01' ORDER BY id DESC");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($results, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
