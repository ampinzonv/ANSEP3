<?php
/**
 * Lógica específica para procesamiento con CobraPy
 */
require_once 'vendor/autoload.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['analisis_id'])) {
    
    // 1. Limpieza de datos (Seguridad primero)
    $id_crudo = $_POST['analisis_id'];
    $id_escaped = escapeshellarg($id_crudo);

    $base_path = "/Applications/MAMP/htdocs/ansep-mpv";
    $env_path  = "$base_path/conda_env"; // La ruta a tu entorno
    $script_py = "$base_path/scripts/script.py";

    // Usamos el comando 'conda run' apuntando al prefijo del entorno (-p)
    // Esto activa el ambiente y ejecuta el script en un solo paso
    $conda_path = "/Users/apinzon/.environments/miniconda3/condabin/conda";
    $comando = "$conda_path run -p $env_path python3 $script_py $id_escaped > /dev/null 2>&1 &";

    shell_exec($comando);

    // 5. Redirección al usuario
    // urlencode asegura que el ID sea seguro para la URL
    header("Location: confirmacion.php?id=" . urlencode($id_crudo));
    exit;

} else {
    // Si se accede sin POST, regresamos al formulario
    header('Location: analisis.php');
    exit;
}