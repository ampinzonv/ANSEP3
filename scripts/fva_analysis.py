import os
import sys
import json
import argparse
from datetime import datetime
import cobra
import pandas as pd
import matplotlib.pyplot as plt

# Use non-interactive backend for server-side plotting
plt.switch_backend('Agg')

def categorize_exchange_reaction(rxn_id, name=""):
    """
    Categorizes a reaction metabolite based on ID and Name.
    Shared logic with FBA for consistency.
    """
    rxn_id = rxn_id.lower()
    name = name.lower()
    
    if any(x in rxn_id for x in ['glc', 'fru', 'suc', 'gal', 'xyl', 'mal', 'tre']):
        return "Carbohydrates", "#2ecc71"
    if any(x in rxn_id for x in ['ac', 'lac', 'for', 'succ', 'pyr', 'cit', 'fum', 'mal']):
        return "Organic Acids", "#e67e22"
    if any(x in rxn_id for x in ['co2', 'o2', 'nh4', 'h2o', 'h2', 'pi', 'so4', 'n2']):
        return "Gases/Inorganic", "#95a5a6"
    if any(x in rxn_id for x in ['ala', 'arg', 'asn', 'asp', 'cys', 'glu', 'gln', 'gly', 'his', 'ile', 'leu', 'lys', 'met', 'phe', 'pro', 'ser', 'thr', 'trp', 'tyr', 'val']):
        return "Amino Acids", "#3498db"
    if 'biomass' in rxn_id or 'growth' in rxn_id:
        return "Biomass", "#2c3e50"
        
    return "Others", "#9b59b6"

def generate_fva_range_plot(fva_result, save_path, top_n=20):
    """
    Generates a range plot (Tornado style) for the most variable reactions.
    """
    # Calculate variability width
    fva_result['width'] = fva_result['maximum'] - fva_result['minimum']
    
    # Take top N by width
    df = fva_result.sort_values(by='width', ascending=True).tail(top_n)
    
    if df.empty:
        return

    num_rxns = len(df)
    plot_height = max(6, num_rxns * 0.4)
    fig, ax = plt.subplots(figsize=(10, plot_height), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')

    # Plot ranges as error bars / horizontal lines
    y_pos = range(num_rxns)
    
    # Draw a line from min to max
    for i, (idx, row) in enumerate(df.iterrows()):
        ax.plot([row['minimum'], row['maximum']], [i, i], color='#3498db', linewidth=4, solid_capstyle='round', alpha=0.7)
        # Add dots for min/max
        ax.plot(row['minimum'], i, 'o', color='#2980b9', markersize=6)
        ax.plot(row['maximum'], i, 'o', color='#2980b9', markersize=6)

    ax.set_yticks(y_pos)
    ax.set_yticklabels(df.index, fontsize=9)
    
    ax.set_title(f"Top {num_rxns} Most Variable Fluxes", fontsize=14, pad=20, color='#2c3e50')
    ax.set_xlabel("Flux Range (mmol/gDW/hr)", fontsize=10, color='#7f8c8d')
    ax.grid(axis='x', linestyle='--', alpha=0.3)
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()

def generate_uncertainty_histogram(fva_result, save_path):
    """
    Generates a histogram of flux widths (v_max - v_min).
    Categorizes reactions by redundancy levels.
    """
    import numpy as np
    
    widths = fva_result['maximum'] - fva_result['minimum']
    
    # Define Bins for Redundancy
    # 0-1e-6: Rigid (Essential/No variability)
    # 1e-6 - 1: Low Flexibility
    # 1 - 100: Moderate Redundancy
    # > 100: High Uncertainty / Redundancy
    
    fig, ax = plt.subplots(figsize=(10, 6), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')
    
    # Use log-spaced bins if there's high range, or just fixed categories for "Redundancy"
    # To make it readable for users, categorical histogram is often better
    
    rigid = widths[widths < 1e-6]
    low = widths[(widths >= 1e-6) & (widths < 1)]
    mod = widths[(widths >= 1) & (widths < 100)]
    high = widths[widths >= 100]
    
    categories = ['Rigid\n(<1e-6)', 'Low\n(1e-6 to 1)', 'Moderate\n(1 to 100)', 'High\n(>100)']
    counts = [len(rigid), len(low), len(mod), len(high)]
    colors = ['#95a5a6', '#3498db', '#2980b9', '#e67e22'] # Gray, Blue, Dark Blue, Orange
    
    bars = ax.bar(categories, counts, color=colors, edgecolor='none', alpha=0.8)
    
    # Add values on top
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                f'{int(height)}', ha='center', va='bottom', fontsize=10, fontweight='bold', color='#2c3e50')

    ax.set_title("Metabolic Redundancy: Uncertainty Distribution", fontsize=16, pad=20, color='#2c3e50')
    ax.set_ylabel("Number of Reactions", fontsize=11, color='#7f8c8d')
    ax.set_xlabel("Flux Interval Width (∆v)", fontsize=11, color='#7f8c8d')
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.grid(axis='y', linestyle='--', alpha=0.2)
    
    plt.figtext(0.5, -0.05, "High counts in 'Rigid' indicate a very constrained or sensitive model.\nHigh counts in 'High' indicate high structural redundancy.", 
                ha="center", fontsize=9, color='#7f8c8d', style='italic')

    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()

def run_fva(model_path, output_path, analysis_name="FVA Result", fraction=0.9, loopless=False, processes=2):
    """
    Main execution routine for FVA.
    """
    done_file = os.path.join(os.path.dirname(output_path), 'process.done')

    try:
        # Load the metabolic model
        model = cobra.io.read_sbml_model(model_path)
        
        # 0. Preliminary FBA to get the absolute optimum
        # This helps the user know what "100%" growth actually is
        fba_sol = model.optimize()
        max_growth = fba_sol.objective_value if fba_sol.objective_value else 0.0

        # Perform FVA
        # We use a fraction of the optimum growth rate
        fva_result = cobra.flux_analysis.flux_variability_analysis(
            model, 
            fraction_of_optimum=float(fraction),
            loopless=bool(int(loopless)),
            processes=int(processes)
        )
        
        # Prepare JSON structure
        results = {
            "analysis_identity": {
                "name": analysis_name or "Unnamed FVA",
                "type": "FVA",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            },
            "model_info": {
                "id": model.id,
                "filename": os.path.basename(model_path),
                "reactions": len(model.reactions),
                "metabolites": len(model.metabolites)
            },
            "simulation_results": {
                "status": "Optimal",
                "objective_value": round(max_growth, 6),
                "fraction_optimum": float(fraction),
                "constrained_target": round(max_growth * float(fraction), 6),
                "loopless": bool(int(loopless)),
                "processes": int(processes)
            },
            "visualizations": {
                "range_plot": "fva_ranges.png",
                "uncertainty_hist": "uncertainty_hist.png"
            },
            "ranges": {},
            "exports": {
                "tsv": f"{os.path.basename(output_path).replace('.json', '.tsv')}"
            }
        }

        # Generate TSV (Full Results with Classification)
        def classify_width(w):
            if w < 1e-6: return "Rigid"
            if w < 1: return "Low Flexibility"
            if w < 100: return "Moderate Redundancy"
            return "High Uncertainty/Redundancy"

        fva_result['width'] = fva_result['maximum'] - fva_result['minimum']
        fva_result['classification'] = fva_result['width'].apply(classify_width)
        
        tsv_path = output_path.replace('.json', '.tsv')
        fva_result.to_csv(tsv_path, sep='\t', index_label='reaction_id')

        # Prepare Top 20 for JSON preview (Rigid first)
        top_20 = fva_result.sort_values(by='width', ascending=True).head(20)
        
        for rxn_id, row in top_20.iterrows():
            rxn = model.reactions.get_by_id(rxn_id)
            results["ranges"][rxn_id] = {
                "name": rxn.name,
                "min": round(row['minimum'], 6),
                "max": round(row['maximum'], 6),
                "width": round(row['width'], 6),
                "class": row['classification']
            }

        # Prepare Visualizations
        results_dir = os.path.dirname(output_path)
        
        # 1. Range Plot (Tornado)
        generate_fva_range_plot(
            fva_result, 
            os.path.join(results_dir, "fva_ranges.png"),
            top_n=20
        )
        
        # 2. Uncertainty Histogram (Redundancy)
        generate_uncertainty_histogram(
            fva_result,
            os.path.join(results_dir, "uncertainty_hist.png")
        )

        # Success: Save JSON
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=4)
        
        print(f"Success: FVA Results saved to {output_path}")

    except Exception as e:
        error_msg = f"Unexpected error during FVA: {str(e)}"
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
    parser = argparse.ArgumentParser(description='Run FVA Analysis using COBRApy')
    parser.add_argument('--model', required=True, help='Path to the SBML model file')
    parser.add_argument('--output', required=True, help='Path to save the results JSON file')
    parser.add_argument('--name', help='Custom name for this analysis')
    parser.add_argument('--fraction', default=0.9, help='Fraction of optimum growth')
    parser.add_argument('--loopless', default=0, help='Enable loopless FVA (0 or 1)')
    parser.add_argument('--processes', default=2, help='Number of processes')
    
    args = parser.parse_args()
    
    run_fva(args.model, args.output, args.name, args.fraction, args.loopless, args.processes)
