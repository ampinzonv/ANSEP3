<?php
/**
 * Schema Migration: Add execution_status to simulations table - ANSEP3
 */

require_once __DIR__ . '/../config/database.php';

try {
    $sql = "ALTER TABLE simulations ADD COLUMN execution_status VARCHAR(50) DEFAULT 'processing' AFTER status";
    $pdo->exec($sql);
    echo "Migration Success: Updated simulations table with execution_status column.\n";
} catch (PDOException $e) {
    if (str_contains($e->getMessage(), 'Duplicate column name')) {
        echo "Migration Note: execution_status column already exists.\n";
    } else {
        die("Migration Error: " . $e->getMessage() . "\n");
    }
}
