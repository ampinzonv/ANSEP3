<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - ANSEP3</title>
    <link rel="stylesheet" href="css/login_style.css">
</head>
<body>
    <div class="container">
        <div class="card">
            {if $message}
                <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 6px; margin-bottom: 1rem; text-align: center; border: 1px solid #c3e6cb;">
                    {$message}
                </div>
            {/if}
            {if $error}
                <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 6px; margin-bottom: 1rem; text-align: center; border: 1px solid #f5c6cb;">
                    {$error}
                </div>
            {/if}
            <div style="text-align: center; margin-bottom: 2rem;">
                <img src="img/logo.png" alt="ANSEP3 Logo" width="300" height="100">
            </div>
            <h2 id="form-title" style="margin-top: 0; text-align: center; font-weight: 500;">Sign In</h2>
            <form id="auth-form" method="POST" action="login.php">
                <input type="hidden" name="action" id="form-action" value="login">
                
                <div class="form-group" id="name-group" style="display: none;">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" placeholder="Your name">
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="example@email.com" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn-primary" id="submit-btn">Sign In</button>
            </form>

            <div style="margin-top: 1.5rem; text-align: center; font-size: 0.9rem;">
                <span id="toggle-text">Don't have an account?</span>
                <a href="#" id="toggle-auth" style="color: var(--accent); font-weight: 600; text-decoration: none; margin-left: 5px;">Register</a>
            </div>
        </div>
    </div>

    <script>
        const toggleBtn = document.getElementById('toggle-auth');
        const formTitle = document.getElementById('form-title');
        const submitBtn = document.getElementById('submit-btn');
        const nameGroup = document.getElementById('name-group');
        const formAction = document.getElementById('form-action');
        const toggleText = document.getElementById('toggle-text');
        
        let isLogin = true;

        toggleBtn.addEventListener('click', (e) => {
            e.preventDefault();
            isLogin = !isLogin;

            if (isLogin) {
                formTitle.textContent = 'Sign In';
                submitBtn.textContent = 'Sign In';
                toggleText.textContent = "Don't have an account?";
                toggleBtn.textContent = 'Register';
                nameGroup.style.display = 'none';
                formAction.value = 'login';
                document.getElementById('name').required = false;
            } else {
                formTitle.textContent = 'Create Account';
                submitBtn.textContent = 'Register';
                toggleText.textContent = 'Already have an account?';
                toggleBtn.textContent = 'Sign In';
                nameGroup.style.display = 'block';
                formAction.value = 'register';
                document.getElementById('name').required = true;
            }
        });
    </script>
</body>
</html>
