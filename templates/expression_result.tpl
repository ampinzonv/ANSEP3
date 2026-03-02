{extends file="layout.tpl"}

{block name="title"}Expression Result - ANSEP3{/block}

{block name="content"}
<div class="analysis-container">
    <header class="page-header">
        <h1>Expression Integration Results</h1>
        {if $success}
            <div class="alert alert-success">
                <strong>Optimal!</strong> The RNA-Seq data was successfully mapped to the metabolic network.
            </div>
        {else}
            <div class="alert alert-danger">
                <strong>Optimization Error!</strong> The integration failed or the model reached an infeasible state.
            </div>
        {/if}
    </header>

    {if $result_data}
        <!-- 1. Hero Summary Section -->
        <div class="results-hero">
            <h3>Simulation Metrics</h3>
            <div class="hero-stats">
                <div class="stat-group">
                    <span class="label">Analysis Name</span>
                    <span class="value">{$result_data.analysis_identity.name|escape}</span>
                </div>
                <div class="stat-group">
                    <span class="label">Methodology</span>
                    <span class="value"><code>{$result_data.analysis_identity.method|upper}</code></span>
                </div>
                <div class="stat-group text-success">
                    <span class="label">Objective Value</span>
                    <span class="value font-weight-bold">{$result_data.simulation_results.objective_value|string_format:"%.6f"}</span>
                </div>
                <div class="stat-group">
                    <span class="label">Missing Data</span>
                    <span class="value">{$result_data.simulation_results.missing_strategy|capitalize}</span>
                </div>
                <div class="stat-group">
                    <span class="label">Scaling</span>
                    <span class="value">{if $result_data.simulation_results.scaled}Enabled (0-1000){else}Standard{/if}</span>
                </div>
            </div>
        </div>

        <!-- 2. Methodology Legend -->
        <div class="section-divider">
            <h2>Metabolic Flow Mapping</h2>
        </div>

        <div class="flux-list-section">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <p class="text-muted" style="margin: 0; font-size: 0.9rem;">
                    Showing top 20 reactions by absolute flux intensity.
                </p>
                <div class="download-links">
                    {if isset($result_data.exports.tsv)}
                        <a href="results_vault/{$user_id}/{$analysis_id}/{$result_data.exports.tsv}" target="_blank" class="text-link">
                            <i class="fas fa-file-csv"></i> Download Full Flux TSV
                        </a>
                    {/if}
                </div>
            </div>

            <table class="results-table">
                <thead>
                    <tr>
                        <th>Reaction ID</th>
                        <th class="text-end">Flux Value</th>
                        <th class="text-center" style="width: 30%">Intensity</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$result_data.simulation_results.top_fluxes key=rid item=val}
                        <tr>
                            <td><code class="text-primary">{$rid}</code></td>
                            <td class="text-end flux-cell">{$val|string_format:"%.4f"}</td>
                            <td class="text-center">
                                {assign var="max_f" value=0.000001}
                                {foreach $result_data.simulation_results.top_fluxes as $f}
                                    {if $f.value|abs > $max_f}
                                        {assign var="max_f" value=$f.value|abs}
                                    {/if}
                                {/foreach}
                                {assign var="perc" value=($val.value|abs / $max_f) * 100}
                                <div class="progress" style="height: 8px; background: #eef2f7; border-radius: 4px; overflow: hidden;">
                                    <div class="progress-bar" style="width: {$perc}%; background: var(--primary); transition: width 0.6s ease;"></div>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {/if}

    <div class="card-style mt-4">
        <h3>Technical Execution Details</h3>
        <p class="text-muted small mb-3">Below is the raw output from the Python integration engine (exp2flux).</p>
        <pre class="log-box">{$output}</pre>

        <div class="result-actions" style="margin-top: 2.5rem; text-align: center; border-top: 1px solid #efefef; padding-top: 2rem;">
            <a href="expression_analysis.php" class="btn-primary-large">
                <i class="fas fa-redo"></i> Integrate New Data
            </a>
            <a href="results_history.php" class="btn-secondary" style="margin-left: 1.5rem;">
                <i class="fas fa-history"></i> Full History
            </a>
        </div>
    </div>
</div>
{/block}
