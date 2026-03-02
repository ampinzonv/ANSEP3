import cobra
import pandas as pd
import numpy as np
import json
import os
import sys
import argparse
from datetime import datetime
from expression_utils import parse_expression_csv
from exp2flux import run_exp2flux
from common_utils import generate_exchange_balance_plot, generate_flux_ranking_plot

def run_analysis():
    parser = argparse.ArgumentParser(description='ANSEP3 Expression Analysis (exp2flux)')
    parser.add_argument('--payload', type=str, required=True, help='Path to the JSON payload file')
    args = parser.parse_args()

    # 1. Load payload
    try:
        with open(args.payload, 'r') as f:
            payload = json.load(f)
    except Exception as e:
        print(f"Error loading payload: {e}")
        sys.exit(1)

    model_path = payload['model_path']
    expression_path = payload['expression_path']
    out_dir = payload['output_dir']
    missing_strategy = payload.get('missing_strategy', 'mean')
    scale = payload.get('scale', True)
    analysis_id = payload.get('analysis_id', 'expression_result')
    
    # Define termination flag path
    done_file = os.path.join(out_dir, 'process.done')

    try:
        # 2. Load Model
        model = cobra.io.read_sbml_model(model_path)

        # 3. Load Expression
        expression_dict = parse_expression_csv(expression_path)
        if not expression_dict:
             raise ValueError("Failed to parse expression file or file is empty.")

        # 4. Run Analysis
        sol, modified_model, weights = run_exp2flux(model, expression_dict, missing_strategy, scale)

        if sol.status != 'optimal':
             raise ValueError(f"Optimization failed: {sol.status}")

        # 5. Prepare Results
        results_file = os.path.join(out_dir, f"{analysis_id}.json")
        tsv_file = os.path.join(out_dir, f"{analysis_id}.tsv")

        # Save TSV (Full Results)
        with open(tsv_file, 'w') as f:
            f.write("Reaction_ID\tReaction_Name\tFlux_Value\n")
            for rxn in modified_model.reactions:
                f.write(f"{rxn.id}\t{rxn.name}\t{sol.fluxes[rxn.id]}\n")

        # Get Top Fluxes for Summary
        flux_dict = sol.fluxes.to_dict()
        top_fluxes = {}
        sorted_fluxes = sol.fluxes.abs().sort_values(ascending=False).head(20)
        
        for rid in sorted_fluxes.index:
            top_fluxes[rid] = {
                "name": modified_model.reactions.get_by_id(rid).name,
                "value": round(float(sol.fluxes[rid]), 6)
            }

        # Prepare JSON response
        response = {
            "status": "success",
            "analysis_identity": {
                "type": "EXPRESSION",
                "method": "exp2flux",
                "name": payload.get('analysis_name', 'Expression Analysis'),
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            },
            "model_info": {
                "id": model.id,
                "filename": os.path.basename(model_path),
                "reactions": len(model.reactions),
                "metabolites": len(model.metabolites)
            },
            "simulation_results": {
                "objective_value": round(sol.objective_value, 6) if sol.objective_value else 0.0,
                "status": sol.status,
                "missing_strategy": missing_strategy,
                "scaled": scale,
                "total_reactions": len(model.reactions),
                "displayed_fluxes": len(top_fluxes)
            },
            "visualizations": {
                "flux_ranking": "flux_ranking.png",
                "exchange_balance": "exchange_balance.png"
            },
            "fluxes": top_fluxes,
            "exports": {
                "tsv": f"{analysis_id}.tsv"
            }
        }

        # 6. Generate Visualizations
        generate_flux_ranking_plot(
            top_fluxes, 
            str(modified_model.objective.expression), 
            os.path.join(out_dir, "flux_ranking.png")
        )
        
        generate_exchange_balance_plot(
            modified_model, 
            sol, 
            os.path.join(out_dir, "exchange_balance.png")
        )

        with open(results_file, 'w') as f:
            json.dump(response, f, indent=4)

        print(f"Success: Results saved to {results_file}")

    except Exception as e:
        error_msg = f"Unexpected error during Expression Analysis: {str(e)}"
        print(error_msg)
        sys.exit(1)

    finally:
        # ALWAYS create the 'done' flag so PHP knows we stopped
        try:
            with open(done_file, 'w') as f:
                f.write('done')
        except:
            pass

if __name__ == "__main__":
    run_analysis()
