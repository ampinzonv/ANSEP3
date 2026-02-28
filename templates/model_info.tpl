{extends file="layout.tpl"}

{block name="title"}Model Information - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Metabolic Reconstruction Hub</h1>
            <p>Explore detailed metadata and technical specifications for our curated metabolic models.</p>
        </header>

        <div style="display: grid; grid-template-columns: 300px 1fr; gap: 2rem; align-items: start;">
            <!-- Sidebar: Model Selection -->
            <aside class="card-style" style="padding: 1.5rem;">
                <h3 style="margin-top: 0; margin-bottom: 1.5rem; font-size: 1.2rem; color: var(--primary);">Available Models</h3>
                <nav class="model-nav-list" style="display: flex; flex-direction: column; gap: 0.5rem;">
                    {foreach $all_models as $m}
                        <a href="model_info.php?id={$m.Id}" 
                           class="model-nav-link {if $selected_id == $m.Id}active{/if}"
                           style="padding: 0.8rem 1rem; border-radius: 8px; text-decoration: none; color: var(--text); transition: all 0.2s; border: 1px solid transparent; {if $selected_id == $m.Id}background: var(--accent); color: white;{else}background: #f8fafc;{/if}">
                            <i class="fas fa-microscope" style="margin-right: 8px; opacity: 0.7;"></i>
                            {$m.model_name|escape}
                        </a>
                    {/foreach}
                </nav>
            </aside>

            <!-- Main Content: Model Details -->
            <section>
                {if $model}
                    <div class="card-style" style="padding: 2.5rem; border-radius: 12px; border: 1px solid var(--border); background: var(--white); box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 2rem; border-bottom: 2px solid #f1f5f9; padding-bottom: 1.5rem;">
                            <div>
                                <h2 style="margin: 0; font-size: 2.2rem; color: var(--primary);">{$model.model_name|escape}</h2>
                                <p style="margin: 0.5rem 0 0; color: var(--text-muted); font-size: 1.1rem;">
                                    <i class="fas fa-user-edit" style="margin-right: 5px;"></i> Author: <strong>{$model.model_author|escape|default:"COBRA Community"}</strong>
                                </p>
                            </div>
                            <div class="badge {if $file_exists}badge-success{else}badge-error{/if}" style="padding: 0.5rem 1rem; border-radius: 20px; font-weight: bold; font-size: 0.9rem; {if $file_exists}background: #dcfce7; color: #166534;{else}background: #fee2e2; color: #991b1b;{/if}">
                                {if $file_exists}
                                    <i class="fas fa-check-circle"></i> SBML Active
                                {else}
                                    <i class="fas fa-exclamation-triangle"></i> SBML Missing
                                {/if}
                            </div>
                        </div>

                        <div class="model-description" style="line-height: 1.8; color: var(--text); margin-bottom: 2.5rem;">
                            <h4 style="color: var(--primary); text-transform: uppercase; letter-spacing: 0.05em; font-size: 0.9rem; margin-bottom: 1rem;">Description & Scope</h4>
                            <p style="font-size: 1.05rem;">{$model.model_description|escape|nl2br}</p>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                            <!-- Publication Box -->
                            <div style="background: #f8fafc; padding: 1.5rem; border-radius: 10px; border: 1px solid #e2e8f0;">
                                <h4 style="margin-top: 0; color: var(--primary); font-size: 0.95rem; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-book-open"></i> Reference Publication
                                </h4>
                                {if $model.model_publication && $model.model_publication != "NA"}
                                    <p style="margin-bottom: 0;">{$model.model_publication|escape}</p>
                                    <a href="https://pubmed.ncbi.nlm.nih.gov/?term={$model.model_publication|escape:url}" target="_blank" class="text-link" style="margin-top: 10px; display: inline-block;">
                                        Find on PubMed <i class="fas fa-external-link-alt" style="font-size: 0.8rem;"></i>
                                    </a>
                                {else}
                                    <p class="text-muted" style="font-style: italic;">No publication linked to this model.</p>
                                {/if}
                            </div>

                            <!-- Technical Specs -->
                            <div style="background: #f8fafc; padding: 1.5rem; border-radius: 10px; border: 1px solid #e2e8f0;">
                                <h4 style="margin-top: 0; color: var(--primary); font-size: 0.95rem; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-cogs"></i> Technical Specifications
                                </h4>
                                <ul style="list-style: none; padding: 0; margin: 0; font-size: 0.95rem;">
                                    <li style="display: flex; justify-content: space-between; padding: 0.4rem 0; border-bottom: 1px solid #edf2f7;">
                                        <span class="text-muted">Filename:</span>
                                        <strong>{$model.model_filename|escape}</strong>
                                    </li>
                                    <li style="display: flex; justify-content: space-between; padding: 0.4rem 0; border-bottom: 1px solid #edf2f7;">
                                        <span class="text-muted">Format:</span>
                                        <strong>SBML Level 3</strong>
                                    </li>
                                    <li style="display: flex; justify-content: space-between; padding: 0.4rem 0;">
                                        <span class="text-muted">File Size:</span>
                                        <strong>
                                            {if $file_exists}
                                                {($file_size / 1024)|string_format:"%.1f"} KB
                                            {else}
                                                N/A
                                            {/if}
                                        </strong>
                                    </li>
                                </ul>
                            </div>
                        </div>

                        <div style="margin-top: 3rem; text-align: center;">
                            <a href="fba_analysis.php" class="btn-primary-large" style="padding: 1rem 2.5rem;">
                                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Simulation with this Model
                            </a>
                        </div>
                    </div>
                {else}
                    <div class="card-style" style="text-align: center; padding: 8rem 2rem; border-style: dashed; background: #fdfdfd;">
                        <i class="fas fa-mouse-pointer" style="font-size: 4rem; color: #cbd5e1; margin-bottom: 2rem;"></i>
                        <h2 style="color: var(--text-muted);">Please select a model from the left to view details.</h2>
                        <p class="text-muted">Select an organism to explore its metabolic potential before running your FBA simulations.</p>
                    </div>
                {/if}
            </section>
        </div>
    </div>
{/block}

{block name="scripts"}
<style>
.model-nav-link:hover:not(.active) {
    background: #f1f5f9 !important;
    border-color: #e2e8f0 !important;
    transform: translateX(5px);
}
.model-nav-link {
    display: block;
    position: relative;
}
.model-nav-link.active::after {
    content: '';
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    width: 8px;
    height: 8px;
    background: white;
    border-radius: 50%;
}
</style>
{/block}
