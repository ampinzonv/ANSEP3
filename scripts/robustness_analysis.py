import os
import sys
import json
import argparse
from datetime import datetime
import cobra
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Use non-interactive backend for server-side plotting
plt.switch_backend('Agg')

def run_robustness(model_path, output_path, reaction_id, analysis_name="Robustness Result", steps=20, min_f=None, max_f=None, step_size=None):
    """
    Main execution routine for Robustness Analysis.
    Varies reaction_id flux and measures objective value.
    """
    done_file = os.path.join(os.path.dirname(output_path), 'process.done')

    try:
        # 1. Load the model
        model = cobra.io.read_sbml_model(model_path)
        
        if reaction_id not in model.reactions:
            raise ValueError(f"Reaction '{reaction_id}' not found in model.")

        rxn = model.reactions.get_by_id(reaction_id)
        
        # 2. Determine bounds for the sweep
        # Use provided min/max or default to reaction bounds
        start_val = float(min_f) if (min_f and min_f != '') else rxn.lower_bound
        end_val = float(max_f) if (max_f and max_f != '') else rxn.upper_bound
        
        # Safety check for infinite bounds
        if start_val < -1000: start_val = -20
        if end_val > 1000: end_val = 20
        
        # 3. Perform the Sweep (Logic for Steps vs Step Size)
        delta = end_val - start_val
        
        if step_size and step_size != '' and float(step_size) > 0:
            s_size = float(step_size)
            # Calculate number of steps based on size
            num_steps = int(abs(delta) / s_size) + 1
            step_values = np.linspace(start_val, end_val, num_steps)
        else:
            # Traditional linspace
            step_values = np.linspace(start_val, end_val, int(steps))
            
        results_data = []
        
        original_bounds = (rxn.lower_bound, rxn.upper_bound)
        
        for val in step_values:
            with model:
                # Fix the reaction to the specific value
                rxn.bounds = (val, val)
                sol = model.optimize()
                
                obj_val = sol.objective_value if sol.status == 'optimal' else 0.0
                results_data.append({
                    "flux": round(float(val), 6),
                    "objective": round(float(obj_val), 6),
                    "status": sol.status
                })
        
        # 4. Prepare JSON structure
        results = {
            "analysis_identity": {
                "name": analysis_name or "Unnamed Robustness",
                "type": "ROBUSTNESS",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            },
            "model_info": {
                "id": model.id,
                "filename": os.path.basename(model_path),
                "reactions": len(model.reactions),
                "metabolites": len(model.metabolites)
            },
            "simulation_results": {
                "control_reaction": reaction_id,
                "control_name": rxn.name,
                "steps": len(results_data),
                "step_size": float(step_size) if (step_size and step_size != '') else None,
                "range": [round(float(start_val), 2), round(float(end_val), 2)],
                "objective_id": str(model.objective.expression).split('*')[-1].strip()
            },
            "visualizations": {
                "robustness_plot": "robustness_plot.png"
            },
            "points": results_data,
            "exports": {
                "tsv": f"{os.path.basename(output_path).replace('.json', '.tsv')}"
            }
        }

        # 5. Generate Visualizations (Line Plot)
        results_dir = os.path.dirname(output_path)
        plot_path = os.path.join(results_dir, "robustness_plot.png")
        
        df = pd.DataFrame(results_data)
        
        plt.figure(figsize=(10, 6), facecolor='#f8fafc')
        ax = plt.gca()
        ax.set_facecolor('#f8fafc')
        
        plt.plot(df['flux'], df['objective'], color='#3498db', linewidth=3, marker='o', markersize=4, alpha=0.8)
        plt.fill_between(df['flux'], df['objective'], color='#3498db', alpha=0.1)
        
        plt.title(f"Robustness Analysis: {reaction_id}", fontsize=16, pad=20, color='#2c3e50')
        plt.xlabel(f"Flux of {reaction_id} (mmol/gDW/hr)", fontsize=11, color='#7f8c8d')
        plt.ylabel(f"Objective Value", fontsize=11, color='#7f8c8d')
        
        plt.grid(True, linestyle='--', alpha=0.3)
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        
        plt.tight_layout()
        plt.savefig(plot_path, dpi=150)
        plt.close()

        # 6. Generate TSV
        tsv_path = output_path.replace('.json', '.tsv')
        df.to_csv(tsv_path, sep='\t', index=False)

        # 7. Success: Save JSON
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=4)
        
        print(f"Success: Robustness Results saved to {output_path}")

    except Exception as e:
        error_msg = f"Unexpected error during Robustness Analysis: {str(e)}"
        print(error_msg)
        sys.exit(1)

    finally:
        # ALWAYS create the 'done' flag
        try:
            with open(done_file, 'w') as f:
                f.write('done')
        except:
            pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run Robustness Analysis using COBRApy')
    parser.add_argument('--model', required=True, help='Path to the SBML model file')
    parser.add_argument('--output', required=True, help='Path to save the results JSON file')
    parser.add_argument('--name', help='Custom name for this analysis')
    parser.add_argument('--reaction', required=True, help='Reaction ID to vary')
    parser.add_argument('--steps', default=20, help='Number of points')
    parser.add_argument('--step-size', help='Specific delta flux between points')
    parser.add_argument('--min', help='Minimum flux')
    parser.add_argument('--max', help='Maximum flux')
    
    args = parser.parse_args()
    
    run_robustness(
        args.model, 
        args.output, 
        args.reaction, 
        args.name, 
        args.steps, 
        args.min, 
        args.max,
        args.step_size
    )
