{extends file="layout.tpl"}

{block name="title"}Robustness Result - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Robustness Analysis Status</h1>
            {if $success}
                <div class="alert alert-success">
                    <strong>Success!</strong> The Metabolic Robustness Analysis completed successfully.
                </div>
            {else}
                <div class="alert alert-danger">
                    <strong>Execution Error!</strong> There was a problem running the robustness study.
                </div>
            {/if}
        </header>

        {if $result_data}
            <!-- 1. Hero Summary Section -->
            <div class="results-hero">
                <h3>Robustness Summary</h3>
                <div class="hero-stats">
                    <div class="stat-group">
                        <span class="label">Analysis Name</span>
                        <span class="value">{$result_data.analysis_identity.name|escape}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Control Reaction</span>
                        <span class="value"><code>{$result_data.simulation_results.control_reaction|escape}</code></span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Objective</span>
                        <span class="value"><code>{$result_data.simulation_results.objective_id|escape}</code></span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Range</span>
                        <span class="value">{$result_data.simulation_results.range[0]} to {$result_data.simulation_results.range[1]}</span>
                    </div>
                    <div class="stat-group">
                        <span class="label">Steps</span>
                        <span class="value">{$result_data.simulation_results.steps|escape} points</span>
                    </div>
                </div>
            </div>

            <!-- 2. Visualization Thumbnail -->
            <div class="viz-thumbnails">
                {if isset($result_data.visualizations.robustness_plot)}
                    <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.robustness_plot}" target="_blank" class="viz-thumbnail-card">
                        <img src="results_vault/{$user_id}/{$analysis_id}/{$result_data.visualizations.robustness_plot}" class="viz-preview-img" alt="Robustness Plot">
                        <h4>Robustness Curve: {$result_data.simulation_results.control_reaction|escape}</h4>
                        <span class="view-hint"><i class="fas fa-expand"></i> Click to enlarge</span>
                    </a>
                {/if}
            </div>

            <!-- 3. Detailed Data Points -->
            <div class="section-divider">
                <h2>Data Points Summary</h2>
            </div>
            
            <div class="flux-list-section">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <p class="text-muted" style="margin: 0;">
                        Showing key sampling points. View full dataset in the exported TSV.
                    </p>
                    <div class="download-links">
                        {if isset($result_data.exports.tsv)}
                            <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.exports.tsv}" target="_blank" class="text-link">
                                <i class="fas fa-file-csv"></i> Download Full TSV
                            </a>
                        {/if}
                    </div>
                </div>
                <table class="results-table">
                    <thead>
                        <tr>
                            <th>Flux ({$result_data.simulation_results.control_reaction|escape})</th>
                            <th>Objective Value</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        {assign var="points" value=$result_data.points}
                        {foreach from=$points item=point name=point_loop}
                            {* Show first 5 and last 5 points *}
                            {if $smarty.foreach.point_loop.index < 5 || $smarty.foreach.point_loop.index > (count($points) - 6)}
                            <tr>
                                <td class="flux-cell">{$point.flux|string_format:"%.4f"}</td>
                                <td class="flux-cell" style="font-weight: 600;">{$point.objective|string_format:"%.6f"}</td>
                                <td>
                                    <span class="status-text {if $point.status eq 'optimal'}status-text-success{else}status-text-warning{/if}">
                                        {$point.status|escape}
                                    </span>
                                </td>
                            </tr>
                            {elseif $smarty.foreach.point_loop.index eq 5}
                            <tr>
                                <td colspan="3" class="text-center text-muted" style="padding: 1rem; font-style: italic; background: #f8fafc;">
                                    ... middle points hidden for brevity ...
                                </td>
                            </tr>
                            {/if}
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}

        <div class="card-style">
            <h3>Technical Execution Log</h3>
            <pre class="log-box">{$output}</pre>

            <div class="result-actions" style="margin-top: 2rem; text-align: center;">
                <a href="robustness_analysis.php" class="btn-primary-large">Run New Analysis</a>
                <a href="results_history.php" class="btn-secondary" style="margin-left: 1rem;">Back to History</a>
            </div>
        </div>
    </div>
{/block}
