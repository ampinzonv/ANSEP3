import os
import sys
import json
import argparse
from datetime import datetime
import cobra
import pandas as pd
import matplotlib.pyplot as plt
import subprocess

# Use non-interactive backend for server-side plotting
plt.switch_backend('Agg')

from common_utils import generate_exchange_balance_plot, generate_flux_ranking_plot

def run_fba(model_path, objective, output_path, analysis_name="FBA Result", only_active=True, top_n=20):
    """
    Main execution routine for FBA.
    """
    # Define termination flag path
    done_file = os.path.join(os.path.dirname(output_path), 'process.done')

    try:
        # Load the metabolic model
        model = cobra.io.read_sbml_model(model_path)
        
        # Determine the objective function
        if objective and str(objective).lower() != 'default':
            try:
                model.objective = objective
            except ValueError:
                print(f"Error: Reaction '{objective}' not found in model.")
                sys.exit(1)
        
        # Perform FBA
        solution = model.optimize()
        
        # Prepare JSON structure
        results = {
            "analysis_identity": {
                "name": analysis_name or "Unnamed Analysis",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            },
            "model_info": {
                "id": model.id,
                "filename": os.path.basename(model_path),
                "reactions": len(model.reactions),
                "metabolites": len(model.metabolites),
                "genes": len(model.genes)
            },
            "simulation_results": {
                "objective_value": round(solution.objective_value, 6) if solution.objective_value else 0.0,
                "status": solution.status,
                "displayed_fluxes": 0,
                "total_reactions": len(model.reactions),
                "filtering": {
                    "only_active": only_active,
                    "top_n_requested": top_n
                }
            },
            "visualizations": {
                "flux_ranking": "flux_ranking.png",
                "exchange_balance": "exchange_balance.png"
            },
            "fluxes": {},
            "exports": {
                "tsv": f"{os.path.basename(output_path).replace('.json', '.tsv')}"
            }
        }

        # Generate TSV (Full Results)
        tsv_path = output_path.replace('.json', '.tsv')
        with open(tsv_path, 'w') as f:
            f.write("Reaction_ID\tReaction_Name\tFlux_Value\n")
            for rxn in model.reactions:
                f.write(f"{rxn.id}\t{rxn.name}\t{solution.fluxes[rxn.id]}\n")

        # Get all non-zero fluxes (or all if requested)
        flux_dict = solution.fluxes.to_dict()
        active_fluxes = {}
        for reaction_id, flux_value in flux_dict.items():
            f_val = float(flux_value)
            if only_active and abs(f_val) < 1e-7:
                continue
            active_fluxes[reaction_id] = {
                "name": model.reactions.get_by_id(reaction_id).name,
                "value": round(f_val, 6)
            }

        # Sort by absolute magnitude and take Top N
        limit = int(top_n) if str(top_n).isdigit() else 20
        preview_limit = min(limit, 20)
        
        # Explicit sorting
        sorted_items = sorted(
            active_fluxes.items(), 
            key=lambda x: abs(float(x[1]['value'])), 
            reverse=True
        )
        top_fluxes = dict(sorted_items[:preview_limit])
        
        results["fluxes"] = top_fluxes
        results["simulation_results"]["displayed_fluxes"] = len(top_fluxes)

        # Generate Visualizations (PNGs)
        results_dir = os.path.dirname(output_path)
        
        # 1. Flux Ranking
        generate_flux_ranking_plot(
            top_fluxes, 
            str(model.objective.expression), 
            os.path.join(results_dir, "flux_ranking.png")
        )
        
        # 2. Exchange Balance
        generate_exchange_balance_plot(
            model, 
            solution, 
            os.path.join(results_dir, "exchange_balance.png")
        )

        # Success: Save JSON
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=4)
        
        print(f"Success: Results saved to {output_path}")

    except Exception as e:
        error_msg = f"Unexpected error during FBA: {str(e)}"
        print(error_msg)
            
        # Cleanup JSON if it was half-written or failed
        if os.path.exists(output_path):
            try:
                os.remove(output_path)
            except:
                pass
            
        sys.exit(1)

    finally:
        # ALWAYS create the 'done' flag so PHP knows we stopped
        try:
            with open(done_file, 'w') as f:
                f.write('done')
        except:
            pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run FBA Analysis using COBRApy')
    parser.add_argument('--model', required=True, help='Path to the SBML model file')
    parser.add_argument('--objective', required=True, help='ID of the objective reaction')
    parser.add_argument('--output', required=True, help='Path to save the results text file')
    parser.add_argument('--name', help='Custom name for this analysis')
    parser.add_argument('--only-active', type=int, default=1, help='1 to show only non-zero fluxes, 0 for all')
    parser.add_argument('--top-n', type=str, default="20", help='Number of reactions in summary')
    
    args = parser.parse_args()
    
    run_fba(args.model, args.objective, args.output, args.name, bool(args.only_active), args.top_n)
