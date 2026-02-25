#!/bin/bash

# 1. Crear la estructura de directorios (usando -p para subcarpetas)
mkdir -p config
mkdir -p conda_env
mkdir -p controllers
mkdir -p public/css
mkdir -p public/js
mkdir -p results_vault/user_1/analysis_001
mkdir -p results_vault/user_1/analysis_002
mkdir -p results_vault/user_2
mkdir -p scripts
mkdir -p templates/auth
mkdir -p templates/dashboard
mkdir -p templates/analysis
mkdir -p templates_c
mkdir -p vendor

# 2. Crear archivos de configuración y lógica [cite: 1]
touch config/database.php config/settings.php
touch controllers/LoginController.php controllers/AnalysisController.php controllers/ResultsController.php

# 3. Crear archivos públicos y activos 
touch public/index.php public/css/styles.css public/js/main.js

# 4. Crear archivos de resultados de ejemplo [cite: 3]
touch results_vault/user_1/analysis_001/data.json
touch results_vault/user_1/analysis_001/plot.png

# 5. Crear scripts de Python (CobraPy) [cite: 3]
touch scripts/fba_analysis.py scripts/fva_analysis.py scripts/common_utils.py

# 6. Crear plantillas de Smarty [cite: 4]
touch templates/auth/login.tpl templates/auth/register.tpl
touch templates/dashboard/panel_usuario.tpl
touch templates/analysis/fba.tpl templates/analysis/fva.tpl
touch templates/layout.tpl

# 7. Archivos de sistema y dependencias [cite: 5]
touch .gitignore
echo "vendor/" >> .gitignore
echo "conda_env/" >> .gitignore
echo "results_vault/" >> .gitignore

echo "Estructura 'ansep-mpv' creada con éxito."
