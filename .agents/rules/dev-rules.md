---
trigger: always_on
---

ANSEP3 Development Rules & Project Context
This document provides essential context and rules for agents working on the ANSEP3 platform.

🔗 Architecture Overview: The PHP/Python Bridge
ANSEP3 uses a hybrid architecture:

Frontend/Orchestration: PHP (Smarty) handles user requests, database state, and background process launching.
Scientific Backend: Python (COBRApy) performs the actual metabolic simulations.
🚀 Simulation Lifecycle
Trigger: User submits a form (e.g., 
fba_analysis.php
).
Bridge: run_[analysis]_analysis.php receives the request.
Registers entry in simulations table with status = 'processing'.
Creates a directory in public/results_vault/{user_id}/{analysis_id}/.
Launches the Python script asynchronously using exec().
Execution: Python script (scripts/[analysis]_analysis.py) runs.
Loads the SBML model from public/models/.
Writes results to a .json file and a .tsv file.
Generates plots (.png).
CRITICAL: Creates a process.done file in the results directory upon completion/failure.
Follow-up: PHP checks for process.done to update the DB status from 'processing' to 'success' or 'error'.
🛠️ Tech Stack & Conventions
PHP
Framework: Custom MVC-ish with Smarty Template Engine.
Database: PDO for MySQL.
Paths: Always use constants from config/paths.php (BASE_PATH, SCRIPTS_PATH, RESULTS_VAULT).
Templates: .tpl files in templates/. Always check templates_c/ if changes aren't reflecting (though typically auto-compiled).
Python
Environment: Managed via Conda. Path defined in config/paths.php as CONDA_ENV.
Libraries: cobra, pandas, matplotlib.
Plotting: Always use plt.switch_backend('Agg') for server-side generation.
CLI: Use argparse for all scripts.
Database (ANSEP3)
users: Authentication metadata.
models: Metadata for SBML files (filename, description, author).
simulations: Logs of all runs. analysis_id is the unique folder name in results_vault.
📏 Coding Rules
Path Safety:

Never hardcode absolute paths. Use BASE_PATH in PHP and os.path in Python.
In PHP, use escapeshellarg() when building commands for exec().
Error Handling:

PHP: Use try/catch for PDO. Return JSON errors for AJAX calls.
Python: Wrap main execution in try/except. Always write to execution.log in the results directory.
Background Processes:

Simulations MUST run in the background (& at the end of the command).
Always redirect output to execution.log (> log_file 2>&1).
UI/UX:

Use provided public/css/platform.css for styling.
Graphics should use the curated color palette (see categorize_exchange_reaction in scripts/fba_analysis.py).
Security:

Check $_SESSION['user_id'] at the start of every sensitive PHP script.
Escape all user inputs before SQL or Shell execution.
📂 Key Directories
config/: System configuration and path definitions.
public/: Web entry points, assets, and the results_vault.
scripts/: Python core logic.
templates/: Smarty UI templates.
