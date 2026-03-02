import cobra
import pandas as pd
import numpy as np
import json
import os
import sys
import argparse
from expression_utils import parse_expression_csv, gene_to_reaction_expression

def run_exp2flux(model, expression_dict, missing_strategy="mean", scale=True):
    """
    Python implementation of the exp2flux method (Osorio et al. 2016).
    Maps gene expression to reaction flux boundaries.
    """
    # 1. Map gene expression to reactions
    # This uses the GPR logic (AND: min, OR: sum)
    rxn_expression = gene_to_reaction_expression(model, expression_dict)
    
    # 2. Handle missing/zero values using the specified strategy
    # Calculate global statistics from the genes that ARE in the dict
    all_values = list(expression_dict.values())
    if not all_values:
        global_stat = 0
    elif missing_strategy == "mean":
        global_stat = np.mean(all_values)
    elif missing_strategy == "median":
        global_stat = np.median(all_values)
    elif missing_strategy == "min":
        global_stat = np.min(all_values)
    elif missing_strategy == "max":
        global_stat = np.max(all_values)
    else:
        global_stat = np.mean(all_values)

    # Apply to reactions that didn't get a value (or have 0)
    for rxn in model.reactions:
        if rxn.id not in rxn_expression or rxn_expression[rxn.id] == 0:
            rxn_expression[rxn.id] = global_stat

    # 3. Scaling (Optional)
    # Scale to 0-1000 range as per R implementation
    max_val = max(rxn_expression.values()) if rxn_expression else 1
    if scale and max_val > 0:
        for rid in rxn_expression:
            rxn_expression[rid] = (rxn_expression[rid] / max_val) * 1000

    # 4. Set boundaries
    # Keep track of original bounds for exchange reactions (they shouldn't be touched)
    exp_model = model.copy()
    
    for rxn in exp_model.reactions:
        # Skip exchange/boundary reactions
        if len(rxn.metabolites) == 1:
            continue
            
        val = rxn_expression.get(rxn.id, global_stat)
        
        # Set new bounds
        if rxn.reversibility:
            rxn.lower_bound = -val
            rxn.upper_bound = val
        else:
            rxn.lower_bound = 0
            rxn.upper_bound = val

    # 5. Run FBA
    solution = exp_model.optimize()
    
    return solution, exp_model, rxn_expression

    return solution, exp_model, rxn_expression

if __name__ == "__main__":
    # Internal test logic removed for library consolidation.
    # Use scripts/expression_analysis.py for execution.
    pass
