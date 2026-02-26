import cobra
import sys
import argparse
import os

def run_fba(model_path, objective, output_path, analysis_name=None, only_active=True, top_n="20"):
    try:
        # Load the metabolic model
        if not os.path.exists(model_path):
            print(f"Error: Model file not found at {model_path}")
            sys.exit(1)
            
        model = cobra.io.read_sbml_model(model_path)
        
        # Set the objective function
        actual_objective = str(model.objective.expression)
        if objective.lower() != 'default':
            if objective in model.reactions:
                model.objective = objective
                actual_objective = objective
            else:
                print(f"Error: Reaction {objective} not found in model.")
                sys.exit(1)
        
        # Run FBA
        solution = model.optimize()
        
        # Prepare the summary
        results = []
        if analysis_name:
            results.append(f"Analysis Name: {analysis_name}")
            results.append("-" * (15 + len(analysis_name)))
            
        results.extend([
            f"FBA Analysis Results",
            f"====================",
            f"Model: {os.path.basename(model_path)}",
            f"Objective: {actual_objective}",
            f"Status: {solution.status}",
            f"Objective Value: {solution.objective_value}",
            f"Filtering: {'Only non-zero fluxes' if only_active else 'All reactions'}",
            f"Limit: {top_n}",
            f"\nReactions Summary:",
            f"------------------"
        ])
        
        # Process fluxes
        fluxes = solution.fluxes
        
        if only_active:
            # Filter non-zero (using a small epsilon for numerical stability)
            fluxes = fluxes[fluxes.abs() > 1e-9]

        # Handling "all" or specific N
        if str(top_n).lower() != "all":
            try:
                n = int(top_n)
                # Sort by absolute magnitude descending
                fluxes = fluxes.abs().sort_values(ascending=False).head(n)
                # Recover original signs
                flux_list = solution.fluxes[fluxes.index]
            except ValueError:
                flux_list = fluxes # Fallback to all if top_n is invalid
        else:
            flux_list = fluxes

        for rxn_id, flux_val in flux_list.items():
            results.append(f"{rxn_id}: {flux_val:.4f}")

        # Ensure directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        # Write to output file
        with open(output_path, 'w') as f:
            f.write("\n".join(results))
            
        print(f"Success: Results saved to {output_path}")

    except Exception as e:
        print(f"Panic Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run FBA Analysis using COBRApy')
    parser.add_argument('--model', required=True, help='Path to the SBML model file')
    parser.add_argument('--objective', required=True, help='ID of the objective reaction')
    parser.add_argument('--output', required=True, help='Path to save the results text file')
    parser.add_argument('--name', help='Custom name for this analysis')
    parser.add_argument('--only-active', type=int, default=1, help='1 to show only non-zero fluxes, 0 for all')
    parser.add_argument('--top-n', default="20", help='Number of reactions or "all"')
    
    args = parser.parse_args()
    
    run_fba(args.model, args.objective, args.output, args.name, bool(args.only_active), args.top_n)
