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

def categorize_exchange_reaction(rxn_id, name=""):
    """
    Categorizes a reaction metabolite based on ID and Name.
    Returns: (category_name, hex_color)
    """
    rxn_id = rxn_id.lower()
    name = name.lower()
    
    # Carbohydrates
    if any(x in rxn_id for x in ['glc', 'fru', 'suc', 'gal', 'xyl', 'mal', 'tre']):
        return "Carbohydrates", "#2ecc71"
    # Organic Acids
    if any(x in rxn_id for x in ['ac', 'lac', 'for', 'succ', 'pyr', 'cit', 'fum', 'mal']):
        return "Organic Acids", "#e67e22"
    # Gases / Inorganic
    if any(x in rxn_id for x in ['co2', 'o2', 'nh4', 'h2o', 'h2', 'pi', 'so4', 'n2']):
        return "Gases/Inorganic", "#95a5a6"
    # Amino Acids
    if any(x in rxn_id for x in ['ala', 'arg', 'asn', 'asp', 'cys', 'glu', 'gln', 'gly', 'his', 'ile', 'leu', 'lys', 'met', 'phe', 'pro', 'ser', 'thr', 'trp', 'tyr', 'val']):
        return "Amino Acids", "#3498db"
    # Biomasa (special check for common IDs)
    if 'biomass' in rxn_id or 'growth' in rxn_id:
        return "Biomass", "#2c3e50"
        
    return "Others", "#9b59b6"

def generate_exchange_balance_plot(model, solution, save_path):
    """
    Generates a minimalist "Barrier" (Membrane Visualization) plot.
    Membrane = Vertical Dashed Line at x=0
    Inputs (Uptake) -> Horizontal Arrows from Left to Center
    Outputs (Secretion) -> Horizontal Arrows from Center to Right
    """
    import numpy as np


    flux_dict = solution.fluxes.to_dict()
    exchange_rxns = [r for r in model.reactions if r.boundary and abs(float(flux_dict.get(r.id, 0))) > 1e-7]
    
    inputs = []
    outputs = []
     
    used_categories = {}
     
    for r in exchange_rxns:
        flux = float(flux_dict.get(r.id, 0))
        cat, color = categorize_exchange_reaction(r.id, r.name)
        label = r.name if r.name and len(r.name) < 25 else r.id
        data = {'id': r.id, 'name': label, 'flux': abs(flux), 'color': color}
        used_categories[cat] = color
        if flux < 0: inputs.append(data)
        else: outputs.append(data)

    # Sort
    inputs = sorted(inputs, key=lambda x: x['flux'], reverse=True)
    outputs = sorted(outputs, key=lambda x: x['flux'], reverse=True)
    
    if not inputs and not outputs: return

    # Scale thickness
    all_fluxes = [i['flux'] for i in inputs + outputs]
    max_flux = max(all_fluxes) if all_fluxes else 1
    def flux_to_width(f):
        return max(1.0, (f / max_flux) * 6)

    # Plot Setup
    num_items = max(len(inputs), len(outputs))
    fig_height = max(6, num_items * 0.6 + 1.5) # Extra space for legend
    fig, ax = plt.subplots(figsize=(12, fig_height), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')

    # Draw Central Barrier (Membrane)
    ax.axvline(0, color='#3c4b5e', linestyle='--', linewidth=2, alpha=0.8, zorder=2)
    ax.text(0, num_items + 0.5, "CELL MEMBRANE", ha='center', fontsize=10, 
            fontweight='bold', color='#3c4b5e', bbox=dict(facecolor='white', edgecolor='none', alpha=0.7))

    # Plot Inputs (Left -> Center)
    for i, item in enumerate(inputs):
        y = num_items - i
        width = flux_to_width(item['flux'])
        
        # Arrow from -10 to -0.2
        ax.annotate("", xy=(-0.2, y), xytext=(-10, y),
                    arrowprops=dict(arrowstyle="->,head_width=0.6,head_length=0.8", 
                                  color=item['color'], lw=width, alpha=0.7))
        
        # Label
        ax.text(-10.5, y, f"{item['name']}\n{item['flux']:.2f}", 
                ha='right', va='center', fontsize=10, color='#2c3e50')

    # Plot Outputs (Center -> Right)
    for i, item in enumerate(outputs):
        y = num_items - i
        width = flux_to_width(item['flux'])
        
        # Arrow from 0.2 to 10
        ax.annotate("", xy=(10, y), xytext=(0.2, y),
                    arrowprops=dict(arrowstyle="->,head_width=0.6,head_length=0.8", 
                                  color=item['color'], lw=width, alpha=0.7))
        
        # Label
        ax.text(10.5, y, f"{item['name']}\n{item['flux']:.2f}", 
                ha='left', va='center', fontsize=10, color='#2c3e50')

    # Final Polish
    ax.set_xlim(-15, 15)
    ax.set_ylim(-1, num_items + 1) # Added bottom margin for legend
    ax.set_axis_off()
    
    plt.title("Metabolic Exchange Interface: Barrier Analysis", fontsize=18, color='#2c3e50', pad=20)
    
    # Add Legend
    if used_categories:
        from matplotlib.lines import Line2D
        legend_elements = [Line2D([0], [0], color=color, lw=4, label=cat) 
                         for cat, color in sorted(used_categories.items())]
        ax.legend(handles=legend_elements, loc='lower center', 
                  bbox_to_anchor=(0.5, 0.02), ncol=min(4, len(legend_elements)), 
                  fontsize=10, frameon=True, facecolor='white', edgecolor='none', framealpha=0.7)

    plt.figtext(0.5, 0.01, "Inward = Uptake | Outward = Secretion\nThickness proportional to flux magnitude.", 
                ha="center", fontsize=9, color='#7f8c8d', style='italic')
    
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()

def generate_flux_ranking_plot(flux_dict, objective_id, save_path):
    """
    Generates a horizontal bar chart of metabolic fluxes sorted by magnitude.
    Args:
        flux_dict: Dictionary of reaction_id -> flux_value
        objective_id: ID of the objective reaction to highlight
        save_path: Path to save the PNG file
    """
    if not flux_dict:
        return

    # Convert to DataFrame - correctly handling metadata dict
    data = []
    for rxn_id, info in flux_dict.items():
        # Handle both raw values and info dicts for backward compatibility or different call sites
        val = info['value'] if isinstance(info, dict) else info
        data.append({'Reaction': rxn_id, 'Flux': float(val)})
    
    df = pd.DataFrame(data)
    df['Magnitude'] = df['Flux'].abs()
    df = df.sort_values(by='Magnitude', ascending=True)

    # Define Colors
    # Positive: #3498db, Negative: #95a5a6, Objective: #2c3e50
    colors = []
    for _, row in df.iterrows():
        if row['Reaction'] == objective_id:
            colors.append('#2c3e50')
        elif row['Flux'] >= 0:
            colors.append('#3498db')
        else:
            colors.append('#95a5a6')

    # Create Plot - Dynamic height based on number of reactions
    # Base height of 6, plus 0.3 inches per reaction beyond 10
    num_reactions = len(df)
    plot_height = max(6, num_reactions * 0.3)
    fig, ax = plt.subplots(figsize=(10, plot_height), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')
    
    bars = ax.barh(df['Reaction'], df['Magnitude'], color=colors, edgecolor='none', height=0.7)
    
    # Add annotations (flux values)
    for bar, val, rxn in zip(bars, df['Flux'], df['Reaction']):
        width = bar.get_width()
        label = f"{'+' if val > 0 else ''}{val:.2f}"
        
        # Color of the text
        text_color = '#34495e'
        ax.text(width + (df['Magnitude'].max() * 0.02), bar.get_y() + bar.get_height()/2, 
                label, va='center', fontsize=9, color=text_color)

    # Styling
    ax.set_title("Metabolic Flux Ranking (Sorted by Magnitude)", fontsize=14, pad=20, color='#2c3e50')
    ax.set_xlabel("Absolute Flux Value |v| mmol/gDW/hr", fontsize=10, color='#7f8c8d')
    
    # Remove top/right/left spines for a cleaner look
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    # ax.spines['left'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()

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
