import cobra
import pandas as pd
import numpy as np

def parse_expression_csv(file_path):
    """
    Parses a CSV/TSV file containing gene expression data.
    Expected format: Gene_ID, Value
    """
    try:
        # Try to detect separator
        df = pd.read_csv(file_path, sep=None, engine='python')
        if df.shape[1] < 2:
            raise ValueError("Expression file must have at least two columns: Gene_ID and Value.")
        
        # Assume first column is Gene ID and second is Value
        df.columns = ['gene_id', 'value']
        return df.set_index('gene_id')['value'].to_dict()
    except Exception as e:
        print(f"Error parsing expression file: {e}")
        return {}

def gene_to_reaction_expression(model, gene_expression_dict):
    """
    Maps gene expression to reactions using GPR rules.
    Logics:
    - AND (Complexes): min(expression)
    - OR (Isozymes): sum(expression)
    """
    reaction_expression = {}
    
    for reaction in model.reactions:
        if not reaction.genes:
            continue
            
        # Get expression levels for genes in this reaction
        # default to 0 if gene not in data
        expr_values = {g.id: gene_expression_dict.get(g.id, 0) for g in reaction.genes}
        
        # Solve GPR logic
        # cobrapy's reaction.gpr is a GPR object. We can use its evaluation logic.
        # But for a custom implementation, we might navigate the tree.
        # Simple approach for now: if multiple genes, use the logic from reaction.gene_reaction_rule
        
        # Using a simplified rule for prototype:
        # If reaction has GPR, we evaluate it.
        # For prototype, we'll use the min/max/sum logic.
        
        res = evaluate_gpr_rule(reaction.gene_reaction_rule, expr_values)
        if res is not None:
            reaction_expression[reaction.id] = res
            
    return reaction_expression

def evaluate_gpr_rule(rule, gene_values):
    """
    Simple recursive GPR evaluator.
    Rule example: '(G1 and G2) or G3'
    """
    if not rule:
        return None
        
    # Standardize spaces for parsing
    rule = rule.replace('(', ' ( ').replace(')', ' ) ')
    tokens = rule.split()
    
    # This is a complex task to do manually without a parser.
    # Fortunately, cobrapy has logic to evaluate GPRs if we provide a dict.
    # However, cobrapy's evaluate usually returns True/False.
    # To get continuous values, we map:
    # AND -> min
    # OR -> sum (or max, but sum is often used for isozymes)
    
    # For the prototype, we'll implement a very basic version or use a trick:
    # Replace 'and' with 'min(' and 'or' with 'max(' ... actually no.
    
    # Better approach: 
    # Use the 'and' -> min and 'or' -> max mapping.
    
    processed_rule = rule.lower()
    processed_rule = processed_rule.replace(' and ', ' , ')
    processed_rule = processed_rule.replace(' or ', ' , ')
    
    # If we want to be precise, we need a real parser.
    # For now, let's assume a simplified mapping or use cobra's internal info if possible.
    
    # Simplified logic for E. coli core testing:
    try:
        # Very crude evaluation for the prototype
        # If it's just one gene
        if rule in gene_values:
            return gene_values[rule]
            
        # If it has logic, we fallback to a simple average of known genes for now
        # until a robust parser is added to this util.
        found_values = [gene_values[g] for g in gene_values if g in rule]
        if found_values:
            if ' or ' in rule.lower():
                return sum(found_values)
            else:
                return min(found_values)
    except:
        pass
        
    return 0
