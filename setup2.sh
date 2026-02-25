
composer init
composer require smarty/smarty
conda create --prefix ./conda_env python=3.10 -c conda-forge -y
./conda_env/bin/pip3 install python-libsbml cobra
./conda_env/bin/python -c "import cobra; print('Éxito: CobraPy y libSBML cargados')"
