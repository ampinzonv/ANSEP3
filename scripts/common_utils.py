import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

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
    """
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

    inputs = sorted(inputs, key=lambda x: x['flux'], reverse=True)
    outputs = sorted(outputs, key=lambda x: x['flux'], reverse=True)
    
    if not inputs and not outputs: return

    all_fluxes = [i['flux'] for i in inputs + outputs]
    max_flux = max(all_fluxes) if all_fluxes else 1
    def flux_to_width(f):
        return max(1.0, (f / max_flux) * 6)

    num_items = max(len(inputs), len(outputs))
    fig_height = max(6, num_items * 0.6 + 1.5)
    fig, ax = plt.subplots(figsize=(12, fig_height), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')

    ax.axvline(0, color='#3c4b5e', linestyle='--', linewidth=2, alpha=0.8, zorder=2)
    ax.text(0, num_items + 0.5, "CELL MEMBRANE", ha='center', fontsize=10, 
            fontweight='bold', color='#3c4b5e', bbox=dict(facecolor='white', edgecolor='none', alpha=0.7))

    for i, item in enumerate(inputs):
        y = num_items - i
        width = flux_to_width(item['flux'])
        ax.annotate("", xy=(-0.2, y), xytext=(-10, y),
                    arrowprops=dict(arrowstyle="->,head_width=0.6,head_length=0.8", 
                                  color=item['color'], lw=width, alpha=0.7))
        ax.text(-10.5, y, f"{item['name']}\n{item['flux']:.2f}", 
                ha='right', va='center', fontsize=10, color='#2c3e50')

    for i, item in enumerate(outputs):
        y = num_items - i
        width = flux_to_width(item['flux'])
        ax.annotate("", xy=(10, y), xytext=(0.2, y),
                    arrowprops=dict(arrowstyle="->,head_width=0.6,head_length=0.8", 
                                  color=item['color'], lw=width, alpha=0.7))
        ax.text(10.5, y, f"{item['name']}\n{item['flux']:.2f}", 
                ha='left', va='center', fontsize=10, color='#2c3e50')

    ax.set_xlim(-15, 15)
    ax.set_ylim(-1, num_items + 1)
    ax.set_axis_off()
    
    plt.title("Metabolic Exchange Interface: Barrier Analysis", fontsize=18, color='#2c3e50', pad=20)
    
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
    """
    if not flux_dict:
        return

    data = []
    for rxn_id, info in flux_dict.items():
        val = info['value'] if isinstance(info, dict) else info
        data.append({'Reaction': rxn_id, 'Flux': float(val)})
    
    df = pd.DataFrame(data)
    df['Magnitude'] = df['Flux'].abs()
    df = df.sort_values(by='Magnitude', ascending=True)

    colors = []
    for _, row in df.iterrows():
        if row['Reaction'] == objective_id:
            colors.append('#2c3e50')
        elif row['Flux'] >= 0:
            colors.append('#3498db')
        else:
            colors.append('#95a5a6')

    num_reactions = len(df)
    plot_height = max(6, num_reactions * 0.3)
    fig, ax = plt.subplots(figsize=(10, plot_height), facecolor='#f8fafc')
    ax.set_facecolor('#f8fafc')
    
    bars = ax.barh(df['Reaction'], df['Magnitude'], color=colors, edgecolor='none', height=0.7)
    
    for bar, val, rxn in zip(bars, df['Flux'], df['Reaction']):
        width = bar.get_width()
        label = f"{'+' if val > 0 else ''}{val:.2f}"
        text_color = '#34495e'
        ax.text(width + (df['Magnitude'].max() * 0.02), bar.get_y() + bar.get_height()/2, 
                label, va='center', fontsize=9, color=text_color)

    ax.set_title("Metabolic Flux Ranking (Sorted by Magnitude)", fontsize=14, pad=20, color='#2c3e50')
    ax.set_xlabel("Absolute Flux Value |v| mmol/gDW/hr", fontsize=10, color='#7f8c8d')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
