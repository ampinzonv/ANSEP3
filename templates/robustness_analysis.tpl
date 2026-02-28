{extends file="layout.tpl"}

{block name="title"}Robustness Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Robustness Analysis</h1>
            <p class="text-muted">Analyze how the objective function responds to variations in a specific reaction flux.</p>
        </header>

        <form id="robustnessForm" action="run_robustness_analysis.php" method="POST" class="card-style">
            <div class="form-section">
                <h3 class="section-title">General Configuration</h3>
                
                <div class="form-group">
                    <label for="analysis_name">Name of Analysis</label>
                    <input type="text" id="analysis_name" name="analysis_name" placeholder="e.g., Oxygen Robustness Ecoli" class="form-control" required>
                </div>

                <div class="form-group">
                    <label for="model_id">Select Metabolic Model</label>
                    {include file="components/model_selector.tpl"}
                </div>
            </div>

            <div class="form-section">
                <h3 class="section-title">Robustness Parameters</h3>
                
                <div class="form-group">
                    <label for="control_reaction">Reaction to Vary (Control)</label>
                    <input type="text" id="control_reaction" name="control_reaction" placeholder="e.g., EX_o2_e" class="form-control" required>
                    <small class="text-muted">Enter the ID of the reaction to be varied step-by-step.</small>
                </div>

                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="sampling_mode">Sampling Strategy</label>
                        <select id="sampling_mode" name="sampling_mode" class="form-select" onchange="toggleSamplingInputs()">
                            <option value="steps">Fixed Number of Steps</option>
                            <option value="step_size">Specific Step Size (Delta)</option>
                        </select>
                    </div>
                </div>


                <div class="form-row" style="margin-top: 1rem;">
                    <div class="form-group col" id="steps_container">
                        <label for="steps">Number of Steps</label>
                        <input type="number" id="steps" name="steps" value="20" min="5" max="100" class="form-control">
                    </div>
                    <div class="form-group col" id="step_size_container" style="display: none;">
                        <label for="step_size">Step Size (Δ Flux)</label>
                        <input type="text" id="step_size" name="step_size" placeholder="e.g., 0.5" class="form-control">
                    </div>
                </div>

                <!-- Sign Convention Warning (Pink/Loud style) -->
                <div class="alert" style="background-color: #fff0f6; border: 1px solid #ffadd2; border-left: 5px solid #eb2f96; color: #c41d7f; font-size: 0.85rem; padding: 1rem; margin-top: 1.5rem; margin-bottom: 0.5rem;">
                    <i class="fas fa-exclamation-triangle"></i> <strong>Critical Convention Hint:</strong> 
                    In COBRA models, <strong>negative</strong> values typically represent <strong>uptake</strong> (entering the cell). 
                    <br>To see growth <em>increase</em> with a nutrient (e.g., Glucose), try a range like <code>-20 to 0</code>.
                </div>

                <div class="form-row">
                    <div class="form-group col">
                        <label for="min_flux">Min Flux (Optional)</label>
                        <input type="text" id="min_flux" name="min_flux" value="-20" placeholder="Auto" class="form-control">
                    </div>
                    <div class="form-group col">
                        <label for="max_flux">Max Flux (Optional)</label>
                        <input type="text" id="max_flux" name="max_flux" value="0" placeholder="Auto" class="form-control">
                    </div>
                </div>
                <small class="text-muted">If Min/Max are blank, the system will use the default reaction bounds.</small>
            </div>

            <footer class="form-footer">
                <button type="submit" class="btn-primary-large">
                    <i class="fas fa-play"></i> Run Robustness Simulation
                </button>
            </footer>
        </form>
    </div>

    <!-- Standard Loading Overlay for ANSEP3 -->
    <div id="simulation-overlay" class="loading-overlay">
        <div class="spinner-content">
            <div class="modern-spinner"></div>
            <div class="loading-text">Initializing robustness simulation...</div>
            <p class="text-muted" style="color: rgba(255,255,255,0.6); margin-top: 10px;">
                Varying fluxes and calculating objective points. This may take a moment.
            </p>
        </div>
    </div>

    <script src="js/simulation.js"></script>
    <script>
        function toggleSamplingInputs() {
            const mode = document.getElementById('sampling_mode').value;
            const stepsContainer = document.getElementById('steps_container');
            const sizeContainer = document.getElementById('step_size_container');
            
            if (mode === 'steps') {
                stepsContainer.style.display = 'block';
                sizeContainer.style.display = 'none';
            } else {
                stepsContainer.style.display = 'none';
                sizeContainer.style.display = 'block';
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            // Use the standard ANSEP service instead of custom buggy code
            ANSEP.initSimulationForm('#robustnessForm', 'simulation-overlay');
        });
    </script>
{/block}
