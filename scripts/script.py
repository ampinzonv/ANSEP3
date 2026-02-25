import sys
import os
import cobra

def run_analysis(analysis_id):
    # Definimos la ruta base de tu proyecto para que no haya pérdida
    base_path = "/Applications/MAMP/htdocs/ansep-mpv"
    output_dir = os.path.join(base_path, "resultados", analysis_id)
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    try:
        model = cobra.io.load_model("textbook")
        
        report_path = os.path.join(output_dir, "reporte.txt")
        with open(report_path, "w") as f:
            f.write(f"ID: {analysis_id}\n")
            f.write(f"Reacciones: {len(model.reactions)}\n")
            f.write(f"Metabolitos: {len(model.metabolites)}\n")
            
    except Exception as e:
        # Log de errores en el mismo reporte
        report_path = os.path.join(output_dir, "reporte.txt")
        with open(report_path, "w") as f:
            f.write(f"Error: {str(e)}")

if __name__ == "__main__":
    # sys.argv[1] es el ID que mandamos desde PHP
    run_analysis(sys.argv[1])