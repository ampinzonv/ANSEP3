<?php
/**
 * Database Connection - ANSEP3
 */

$host = 'localhost';
$db   = 'ANSEP3';
$user = 'root';
$pass = 'root'; // Default MAMP password
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
     $pdo = new PDO($dsn, $user, $pass, $options);
     return $pdo;
} catch (\PDOException $e) {
     // En un entorno real, no mostraríamos el error directamente
     die("Error al conectar a la base de datos: " . $e->getMessage());
}
