<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - ANSEP3</title>
    <link rel="stylesheet" href="css/login_style.css">
</head>
<body>
    <div class="container">
        <div class="card" style="text-align: center;">
            <div style="margin-bottom: 2rem;">
                 <img src="../public/img/logo.png" alt="ANSEP3 Logo" width="300" height="100">
            </div>
            <h1>Welcome back, {$user_name}!</h1>
            <p style="color: #666; margin-bottom: 2rem;">You have successfully logged in to ANSEP3.</p>
            <p style="color: #666; margin-bottom: 2rem;">Your email is: {$user_email}</p>
            <p style="color: #666; margin-bottom: 2rem;">Your id is: {$user_id}</p>
            
            <a href="logout.php" class="btn-primary" style="text-decoration: none; display: inline-block;">Log Out</a>
        </div>
    </div>
</body>
</html>
