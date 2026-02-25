
<?php
/**
 * Login Controller - ANSEP3
 */

session_start();

// Redirigir si ya está logueado
if (isset($_SESSION['user_id']) && !isset($_POST['action'])) {
    header('Location: loggedin.php');
    exit;
}

// Inicializar Smarty
$smarty = require_once __DIR__ . '/../config/smarty_init.php';

// Inicializar Base de Datos
$pdo = require_once __DIR__ . '/../config/database.php';

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $name = $_POST['name'] ?? '';

    if ($action === 'register') {
        // Lógica de Registro
        if (!empty($name) && !empty($email) && !empty($password)) {
            $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
            try {
                $stmt = $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
                $stmt->execute([$name, $email, $hashedPassword]);
                $message = "Registration successful! You can now sign in.";
            } catch (PDOException $e) {
                if ($e->getCode() == 23000) {
                    $error = "This user seems to be already registered.";
                } else {
                    $error = "Error during registration: " . $e->getMessage();
                }
            }
        } else {
            $error = "Please fill in all fields.";
        }
    } elseif ($action === 'login') {
        // Lógica de Login
        if (!empty($email) && !empty($password)) {
            $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
            $stmt->execute([$email]);
            $user = $stmt->fetch();

            if ($user && password_verify($password, $user['password'])) {
                // Iniciar sesión
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['user_name'] = $user['name'];
                $_SESSION['user_email'] = $user['email'];

                header('Location: loggedin.php');
                exit;
            } else {
                $error = "Invalid email or password.";
            }
        } else {
            $error = "Please fill in all fields.";
        }
    }
}

// Pasar mensajes a Smarty
$smarty->assign('message', $message);
$smarty->assign('error', $error);

// Renderizar la plantilla
$smarty->display('login.tpl');
?>