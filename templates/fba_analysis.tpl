{extends file="layout.tpl"}

{block name="title"}FBA Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Flux Balance Analysis (FBA)</h1>
            <p>Predict growth rates and metabolic fluxes within a metabolic reconstruction using optimization techniques.</p>
        </header>

        <form action="run_fba_analysis.php" method="POST" class="analysis-form card-style">
            <!-- Analysis Identity -->
            <section class="form-section">
                <h3>1. Identification</h3>
                <div class="form-group">
                    <label for="analysis_name" class="form-label">Analysis Name:</label>
                    <input type="text" name="analysis_name" id="analysis_name" class="form-control" placeholder="e.g. My First Astrocyte Simulation" required>
                    <small class="text-muted">Give this analysis a name to help you identify it later.</small>
                </div>
            </section>

            <!-- Model Selection Routine -->
            <section class="form-section">
                <h3>2. Select Model</h3>
                {include file="components/model_selector.tpl"}
            </section>

            <!-- FBA Specific Parameters -->
            <section class="form-section">
                <h3>3. Setup Parameters</h3>
                <div class="form-group">
                    <label class="form-label">Objective Function:</label>
                    <div style="margin-bottom: 1rem; display: flex; gap: 2rem;">
                        <label style="font-weight: normal; cursor: pointer;">
                            <input type="radio" name="objective_choice" value="Default" checked onclick="document.getElementById('objective').value='Default'; document.getElementById('objective').readOnly=true;"> 
                            Default (from model)
                        </label>
                        <label style="font-weight: normal; cursor: pointer;">
                            <input type="radio" name="objective_choice" value="custom" onclick="document.getElementById('objective').value=''; document.getElementById('objective').readOnly=false; document.getElementById('objective').focus();"> 
                            Specific Reaction ID
                        </label>
                    </div>
                    <input type="text" name="objective" id="objective" class="form-control" value="Default" readonly required>
                    <small class="text-muted">The reaction to maximize/minimize during optimization.</small>
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

            <!-- Result Reporting Options -->
            <section class="form-section">
                <h3>4. Result Reporting</h3>
                <div class="form-group">
                    <label class="form-label" style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                        <input type="checkbox" name="only_active" id="only_active" value="1" checked onchange="toggleTopN()">
                        Show only active fluxes (Non-zero values)
                    </label>
                </div>

                <div class="form-group" id="top_n_container">
                    <label for="top_n" class="form-label">Number of reactions in summary:</label>
                    <input type="text" name="top_n" id="top_n" class="form-control" value="20" placeholder="e.g. 10, 50 or 'all'">
                    <small class="text-muted">Enter a number for top fluxes or 'all' to see everything. Default is 20.</small>
                </div>
            </section>

            <div class="form-actions">
                <button type="submit" class="btn-primary-large">Run FBA Simulation</button>
                <button type="reset" class="btn-secondary">Reset Fields</button>
            </div>
        </form>

        <!-- Loading Overlay -->
        <div id="spinner-overlay" class="loading-overlay">
            <div class="spinner-content">
                <div class="modern-spinner"></div>
                <div class="loading-text">Running metabolic simulation...</div>
                <p class="text-muted" style="color: rgba(255,255,255,0.6); margin-top: 10px;">Please do not close this window.</p>
            </div>
        </div>
    </div>
{/block}

{block name="scripts"}
<script src="js/simulation.js"></script>
{literal}
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize the FBA form with universal simulation logic
        ANSEP.initSimulationForm('.analysis-form', 'spinner-overlay');
    });

    /**
     * FBA-specific UI logic
     */
    function toggleTopN() {
        const onlyActive = document.getElementById('only_active').checked;
        const topNContainer = document.getElementById('top_n_container');
        const topNInput = document.getElementById('top_n');
        
        if (!onlyActive) {
            topNInput.value = 'all';
            topNContainer.style.opacity = '0.5';
            topNInput.readOnly = true;
        } else {
            topNInput.value = '20';
            topNContainer.style.opacity = '1';
            topNInput.readOnly = false;
        }
    }
</script>
{/literal}
{/block}
