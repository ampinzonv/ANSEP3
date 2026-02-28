<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{block name="title"}Platform - ANSEP3{/block}</title>
    <link rel="stylesheet" href="css/platform.css">
    {block name="head"}{/block}
</head>
<body>
    <header class="site-header">
        <div class="header-left">
            <img src="img/logo.png" alt="ANSEP Logo" class="logo-img">
        </div>
        <div class="header-right">
            <div class="user-info">
                <span>Welcome, <strong>{$user_name}</strong></span>
            </div>
            <a href="logout.php" class="btn-logout">Log Out</a>
        </div>
    </header>

    <nav class="main-nav">
        <ul class="nav-list">
            <li class="nav-item">
                <a href="loggedin.php" class="nav-link">Home</a>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link chevron">Model Exploration</a>
                <div class="dropdown">
                    <a href="#" class="dropdown-link">Model Capacity</a>
                    <a href="model_info.php" class="dropdown-link">Model Info</a>
                </div>
            </li>
            <li class="nav-item">
                <a href="#" class="nav-link chevron">Model Analysis</a>
                <div class="dropdown">
                    <a href="fba_analysis.php" class="dropdown-link">FBA</a>
                    <a href="fva_analysis.php" class="dropdown-link">FVA</a>
                    <a href="#" class="dropdown-link">Robustness</a>
                    <a href="#" class="dropdown-link">Expression Analysis</a>
                </div>
            </li>
            <li class="nav-item"><a href="results_history.php" class="nav-link">Results History</a></li>
            <li class="nav-item"><a href="#" class="nav-link">Microbiomes</a></li>
            <li class="nav-item"><a href="#" class="nav-link">Our Models</a></li>
            <li class="nav-item"><a href="#" class="nav-link">Documentation</a></li>
            <li class="nav-item"><a href="#" class="nav-link">Contact us</a></li>
        </ul>
    </nav>

    <main class="content-main">
        {block name="content"}{/block}
    </main>

    <footer class="site-footer">
        <p>&copy; 2026 ANSEP3 Platform. All rights reserved.</p>
        <div class="footer-links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms of Service</a>
            <a href="#">Technical Support</a>
        </div>
    </footer>
    {block name="scripts"}{/block}
</body>
</html>
