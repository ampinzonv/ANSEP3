{extends file="layout.tpl"}

{block name="title"}Execution Result - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Analysis Status</h1>
            {if $success}
                <div class="alert alert-success">
                    <strong>Success!</strong> The FBA simulation completed successfully.
                </div>
            {else}
                <div class="alert alert-danger">
                    <strong>Execution Error!</strong> There was a problem running the simulation.
                </div>
            {/if}
        </header>

        {if $result_data}
            <!-- 1. Hero Summary Section -->
            <div class="results-hero">
                <h3>Simulation Summary</h3>
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
                        <span class="label">Objective Value</span>
                        <span class="value">{$result_data.simulation_results.objective_value|string_format:"%.6f"}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Status</span>
                        <span class="value">{$result_data.simulation_results.status|escape}</span>
                    </div>
                </div>
            </div>

            <!-- 2. Visualization Thumbnails grid -->
            <div class="viz-thumbnails">
                {if isset($result_data.visualizations.flux_ranking)}
                    <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.flux_ranking}" target="_blank" class="viz-thumbnail-card">
                        <img src="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.flux_ranking}" class="viz-preview-img" alt="Flux Ranking">
                        <h4>Metabolic Flux Ranking</h4>
                        <span class="view-hint"><i class="fas fa-expand"></i> Click to enlarge</span>
                    </a>
                {/if}

                {if isset($result_data.visualizations.exchange_balance)}
                    <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.exchange_balance}" target="_blank" class="viz-thumbnail-card">
                        <img src="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.exchange_balance}" class="viz-preview-img" alt="Exchange Balance">
                        <h4>Exchange Balance (Barrier)</h4>
                        <span class="view-hint"><i class="fas fa-expand"></i> Click to enlarge</span>
                    </a>
                {/if}
            </div>

            <!-- 3. Detailed Flux List -->
            <div class="section-divider">
                <h2>Detailed Reaction Fluxes</h2>
            </div>
            
            <div class="flux-list-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <p class="text-muted" style="margin: 0;">
                        Showing Top {$result_data.simulation_results.displayed_fluxes|escape} 
                        of {$result_data.simulation_results.total_reactions|escape} metabolic fluxes (ordered by magnitude).
                    </p>
                    <div class="download-links">
                        {if isset($result_data.exports.tsv)}
                            <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.exports.tsv}" target="_blank" class="text-link" style="margin-right: 1.5rem;">
                                <i class="fas fa-file-csv"></i> Download TSV
                            </a>
                        {/if}
                        <a href="results_vault/{$user_id}/{$analysis_id}/{$result_file}" target="_blank" class="text-link">
                            <i class="fas fa-file-code"></i> Download JSON
                        </a>
                    </div>
                </div>
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>Reaction ID</th>
                            <th>Flux Value (mmol/gDW/hr)</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $result_data.fluxes as $rxn_id => $flux_info}
                            <tr>
                                <td><code title="{$flux_info.name|escape}">{$rxn_id}</code></td>
                                <td class="flux-cell">{$flux_info.value|string_format:"%.6f"}</td>
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
                <a href="fba_analysis.php" class="btn-primary-large">Run New Analysis</a>
                <a href="results_history.php" class="btn-secondary" style="margin-left: 1rem;">Back to History</a>
            </div>
        </div>
    </div>
{/block}

