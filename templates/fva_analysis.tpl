{extends file="layout.tpl"}

{block name="title"}FVA Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Flux Variability Analysis (FVA)</h1>
            <p>Determine the range of possible flux values for each reaction while maintaining a specific state (e.g. 90% growth).</p>
        </header>

        <form action="run_fva_analysis.php" method="POST" class="analysis-form card-style">
            <!-- Analysis Identity -->
            <section class="form-section">
                <h3>1. Identification</h3>
                <div class="form-group">
                    <label for="analysis_name" class="form-label">Analysis Name:</label>
                    <input type="text" name="analysis_name" id="analysis_name" class="form-control" placeholder="e.g. Robustness study of E. coli" required>
                    <small class="text-muted">Give this variability study a descriptive name.</small>
                </div>
            </section>

            <!-- Model Selection Routine -->
            <section class="form-section">
                <h3>2. Select Model</h3>
                {include file="components/model_selector.tpl"}
            </section>

            <!-- FVA Specific Parameters -->
            <section class="form-section">
                <h3>3. Variability Parameters</h3>
                <div class="form-group">
                    <label for="fraction_optimum" class="form-label">Fraction of Optimum:</label>
                    <input type="number" name="fraction_optimum" id="fraction_optimum" class="form-control" value="0.9" step="0.05" min="0" max="1" required>
                    <small class="text-muted">Fraction of the maximum growth rate to be maintained as a constraint (usually 0.9 or 1.0).</small>
                </div>

                <div class="form-group">
                    <label class="form-label" style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                        <input type="checkbox" name="loopless" id="loopless" value="1">
                        Use Loopless FVA
                    </label>
                    <small class="text-muted">Eliminate thermodynamically infeasible internal loops (Significantly slower).</small>
                </div>

                <div class="form-group">
                    <label for="solver" class="form-label">Mathematical Solver:</label>
                    <select name="solver" id="solver" class="form-select">
                        <option value="glpk">GLPK (Free)</option>
                        <option value="gurobi">Gurobi (Expert)</option>
                        <option value="cplex">CPLEX</option>
                    </select>
                </div>
            </section>

            <!-- Multi-processing -->
            <section class="form-section">
                <h3>4. Performance</h3>
                <div class="form-group">
                    <label for="processes" class="form-label">Parallel Processes:</label>
                    <input type="number" name="processes" id="processes" class="form-control" value="2" min="1" max="16">
                    <small class="text-muted">Number of CPU cores to use for parallel flux variability calculations.</small>
                </div>
            </section>

            <div class="form-actions">
                <button type="submit" class="btn-primary-large">Run FVA Simulation</button>
                <button type="reset" class="btn-secondary">Reset Fields</button>
            </div>
        </form>

        <!-- Loading Overlay -->
        <div id="spinner-overlay" class="loading-overlay">
            <div class="spinner-content">
                <div class="modern-spinner"></div>
                <div class="loading-text">Launching variability analysis...</div>
                <p class="text-muted" style="color: rgba(255,255,255,0.6); margin-top: 10px;">FVA takes longer than FBA. You can check results later in History.</p>
            </div>
        </div>
    </div>
{/block}

{block name="scripts"}
<script src="js/simulation.js"></script>
{literal}
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize the universal simulation engine for FVA
        ANSEP.initSimulationForm('.analysis-form', 'spinner-overlay');
    });
</script>
{/literal}
{/block}
