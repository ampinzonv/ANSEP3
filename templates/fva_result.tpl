{extends file="layout.tpl"}

{block name="title"}FVA Result - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>FVA Analysis Status</h1>
            {if $success}
                <div class="alert alert-success">
                    <strong>Success!</strong> The Flux Variability Analysis completed successfully.
                </div>
            {else}
                <div class="alert alert-danger">
                    <strong>Execution Error!</strong> There was a problem running the variability study.
                </div>
            {/if}
        </header>

        {if $result_data}
            <!-- 1. Hero Summary Section -->
            <div class="results-hero">
                <h3>Variability Summary</h3>
                <div class="hero-stats">
                    <div class="stat-group">
                        <span class="label">Analysis Name</span>
                        <span class="value">{$result_data.analysis_identity.name|escape}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Model</span>
                        <span class="value">{$result_data.model_info.filename|escape}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Max Growth (100%)</span>
                        <span class="value">{$result_data.simulation_results.objective_value|string_format:"%.4f"}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Constraint ({($result_data.simulation_results.fraction_optimum * 100)|string_format:"%d"}%)</span>
                        <span class="value">{$result_data.simulation_results.constrained_target|string_format:"%.4f"}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Loopless</span>
                        <span class="value">{if $result_data.simulation_results.loopless}Yes{else}No{/if}</span>
                    </div>
                </div>
            </div>

            <!-- 2. Visualization Thumbnails grid -->
            <div class="viz-thumbnails">
                {if isset($result_data.visualizations.range_plot)}
                    <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.range_plot}" target="_blank" class="viz-thumbnail-card">
                        <img src="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.range_plot}" class="viz-preview-img" alt="FVA Ranges">
                        <h4>Flux Variability Ranges (Top 20)</h4>
                        <span class="view-hint"><i class="fas fa-expand"></i> Click to enlarge</span>
                    </a>
                {/if}

                {if isset($result_data.visualizations.uncertainty_hist)}
                    <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.uncertainty_hist}" target="_blank" class="viz-thumbnail-card">
                        <img src="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.uncertainty_hist}" class="viz-preview-img" alt="Uncertainty Histogram">
                        <h4>Metabolic Redundancy (Histogram)</h4>
                        <span class="view-hint"><i class="fas fa-expand"></i> Click to enlarge</span>
                    </a>
                {/if}
            </div>

            <!-- 3. Detailed Range List -->
            <div class="section-divider">
                <h2>Variability Range Details</h2>
            </div>
            
            <div class="flux-list-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <p class="text-muted" style="margin: 0;">
                        Showing Top 20 reactions by variability width (Maximum - Minimum).
                    </p>
                    <div class="download-links">
                        {if isset($result_data.exports.tsv)}
                            <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.exports.tsv}" target="_blank" class="text-link" style="margin-right: 1.5rem;">
                                <i class="fas fa-file-csv"></i> Download Full TSV
                            </a>
                        {/if}
                    </div>
                </div>
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>Reaction ID</th>
                            <th>Minimum Flux</th>
                            <th>Maximum Flux</th>
                            <th>Width</th>
                            <th>Classification</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $result_data.ranges as $rxn_id => $range_info}
                            <tr>
                                <td><code title="{$range_info.name|escape}">{$rxn_id}</code></td>
                                <td class="flux-cell">{$range_info.min|string_format:"%.6f"}</td>
                                <td class="flux-cell">{$range_info.max|string_format:"%.6f"}</td>
                                <td class="flux-cell" style="font-weight: 600;">{$range_info.width|string_format:"%.6f"}</td>
                                <td class="text-center">
                                    <span class="status-text {if $range_info.class eq 'Rigid'}status-text-muted{elseif $range_info.class eq 'Low Flexibility'}status-text-info{elseif $range_info.class eq 'Moderate Redundancy'}status-text-success{else}status-text-warning{/if}">
                                        {$range_info.class|escape}
                                    </span>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}

        <div class="card-style">
            <h3>Technical Execution Log</h3>
            <pre class="log-box">{$output}</pre>

            <div class="result-actions" style="margin-top: 2rem; text-align: center;">
                <a href="fva_analysis.php" class="btn-primary-large">Run New FVA</a>
                <a href="results_history.php" class="btn-secondary" style="margin-left: 1rem;">Back to History</a>
            </div>
        </div>
    </div>
{/block}
