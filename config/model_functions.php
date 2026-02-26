<?php
/**
 * Model selection and retrieval functions
 */

function get_all_models($pdo) {
    try {
        $stmt = $pdo->query("SELECT * FROM models ORDER BY model_name ASC");
        return $stmt->fetchAll();
    } catch (\PDOException $e) {
        error_log("Error fetching models: " . $e->getMessage());
        return [];
    }
}

function get_model_by_id($pdo, $id) {
    try {
        $stmt = $pdo->prepare("SELECT * FROM models WHERE Id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch();
    } catch (\PDOException $e) {
        error_log("Error fetching model $id: " . $e->getMessage());
        return null;
    }
}
