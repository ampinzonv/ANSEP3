{extends file="layout.tpl"}

{block name="title"}Expression Analysis - ANSEP3{/block}

{block name="content"}
<div class="analysis-container">
    <header class="page-header">
        <h1>Expression Analysis</h1>
        <p class="text-muted">Incorporate gene expression data as continuous flux boundaries for tissue-specific metabolic modeling.</p>
    </header>

    <form id="expressionForm" action="run_expression_analysis.php" method="POST" enctype="multipart/form-data" class="card-style modern-form">
        
        <!-- 1. Identification -->
        <div class="form-section">
            <h3 class="section-title">1. Identification</h3>
            <div class="form-group">
                <label for="analysis_name">Analysis Name</label>
                <input type="text" name="analysis_name" id="analysis_name" class="form-control" placeholder="e.g. Brain Region X mapped to Recon3D" required>
                <small class="text-muted">Give this integration a name to identify it in your results history.</small>
            </div>
        </div>

        <!-- 2. Model Selection -->
        <div class="form-section">
            <h3 class="section-title">2. Metabolic Context</h3>
            <div class="form-group">
                <label for="model_id">Select Base Metabolic Model</label>
                {include file="components/model_selector.tpl"}
                <small class="text-muted">The reference model (e.g., Recon3D) to be constrained by expression data.</small>
            </div>
        </div>

        <!-- 2. Data Upload -->
        <div class="form-section">
            <h3 class="section-title">3. Expression Data</h3>
            <div class="form-group">
                <label for="expression_file">Upload RNA-Seq / Microarray Data</label>
                <div class="upload-area p-4 text-center border-dashed rounded" id="drop-area" style="background: #fafafa; border: 2px dashed #ddd; transition: all 0.3s;">
                    <input type="file" name="expression_file" id="expression_file" class="form-control" accept=".csv,.tsv,.txt" required>
                    <p class="text-muted mt-2 small">Accepted formats: <strong>CSV, TSV, TXT</strong> (Gene ID, Expression Value)</p>
                </div>
            </div>
        </div>

        <!-- 3. Method Parameters -->
        <div class="form-section">
            <h3 class="section-title">4. Integration Settings</h3>
            <div class="form-row" style="display: flex; gap: 20px; flex-wrap: wrap;">
                <div class="form-group" style="flex: 1; min-width: 250px;">
                    <label for="missing_strategy">Missing Gene Strategy</label>
                    <select name="missing_strategy" id="missing_strategy" class="form-select">
                        <option value="mean" selected>Mean (Global Distribution)</option>
                        <option value="median">Median (Global Distribution)</option>
                        <option value="min">Minimum (Conservative)</option>
                        <option value="max">Maximum (Optimistic)</option>
                    </select>
                    <small class="text-muted">Method to handle genes not present in your dataset.</small>
                </div>
                <div class="form-group" style="flex: 1; min-width: 200px; display: flex; align-items: center; padding-top: 1.5rem;">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="scale" id="scaleSwitch" checked>
                        <label class="form-check-label" for="scaleSwitch" style="font-weight: 600; cursor: pointer;">Scale bounds (0 - 1000)</label>
                    </div>
                </div>
            </div>
        </div>

        <footer class="form-footer">
            <button type="submit" class="btn-primary-large">
                <i class="fas fa-microchip"></i> Run Expression Integration
            </button>
        </footer>
    </form>
</div>

<!-- Standard Loading Overlay -->
<div id="simulation-overlay" class="loading-overlay">
    <div class="spinner-content">
        <div class="modern-spinner"></div>
        <div class="loading-text">Mapping Expression to GPR...</div>
        <p class="text-muted" style="color: rgba(255,255,255,0.6); margin-top: 10px;">
            Solving constrained FBA. This may take a moment for large models.
        </p>
    </div>
</div>

{block name="scripts"}
<script src="js/simulation.js"></script>
{literal}
<script>
document.addEventListener('DOMContentLoaded', function() {
    ANSEP.initSimulationForm('#expressionForm', 'simulation-overlay');
    
    // Simple drag-and-drop feedback
    const dropArea = document.getElementById('drop-area');
    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.style.borderColor = '#3b82f6', false);
    });
    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.style.borderColor = '#ddd', false);
    });
});
</script>
{/literal}
{/block}
{/block}
