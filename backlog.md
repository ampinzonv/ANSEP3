# ANSEP3 Project Backlog 🚀🧪🔬⚖️

This document tracks future enhancements and ideas for the ANSEP3 metabolic analysis platform.

## Metabolic Analysis (FVA & FBA Extensions)

- [ ] **Flux Correlation Heatmaps**: 
    - Identify reactions that vary together to discover functional modules.
    - **Implementation Idea**: Use Flux Coupling Analysis (FCA) for structural dependencies or MCMC Sampling (ACHR) for statistical correlation.
    - **Optimization**: Pre-filter rigid reactions and use clustering/dendrograms for large models.

- [ ] **Dual-Parameter Robustness Analysis**:
    - Extend the current robustness module to support two varying parameters simultaneously (3D plots or Heatmaps).

- [ ] **Enzyme-Constrained Models (GIMME/iMAT)**:
    - Integration of transcriptomics data to restrict flux bounds.

## Interface & UX

- [ ] **Interactive Metabolic Maps**:
    - Integrate Escher or a custom SVG-based map viewer to see fluxes in context.
- [ ] **Model Comparison Tool**:
    - Compare results from two different models or conditions side-by-side.

## Performance & Backend

- [ ] **Dynamic Solver Selection**:
    - Build the bridge between the UI/PHP and Python to actually use the selected solver (CPLEX, Gurobi, GLPK).
    - Implement a "Solver Availability Check" to notify the user if a specific solver is missing in the environment.
- [ ] **Result Compression**:
    - Use binary formats or compression for large TSV exports.
