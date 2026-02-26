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

        <div class="card-style">
            <h3>Technical Execution Log</h3>
            <pre class="log-box">{$output}</pre>

            {if $success}
                <div class="result-actions" style="margin-top: 2rem;">
                    <a href="results_vault/{$user_id}/{$result_file}" target="_blank" class="btn-primary-large">Download Raw Result File (.txt)</a>
                    <a href="fba_analysis.php" class="btn-secondary" style="margin-left: 1rem;">Run Another Analysis</a>
                </div>
            {else}
                 <div class="result-actions" style="margin-top: 2rem;">
                    <a href="fba_analysis.php" class="btn-primary-large">Try Again / Adjust Parameters</a>
                </div>
            {/if}
        </div>
    </div>
{/block}

