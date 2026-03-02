{extends file="layout.tpl"}

{block name="title"}Model Information - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Model Information</h1>
            <p>Explore detailed technical specifications for our curated metabolic models.</p>
        </header>

        <div class="model-explorer-layout">
            <!-- Sidebar: Model Selection -->
            <aside class="card-style model-sidebar">
                <h3>Available Models</h3>
                <nav class="model-nav-list">
                    {foreach $all_models as $m}
                        <a href="model_info.php?id={$m.Id}" 
                           class="model-nav-link {if $selected_id == $m.Id}active{/if}">
                            <i class="fas fa-microscope"></i>
                            {$m.model_name|escape}
                        </a>
                    {/foreach}
                </nav>
            </aside>

            <!-- Main Content: Model Details -->
            <section>
                {if $model}
                    <div class="card-style model-detail-card">
                        <div class="model-detail-header">
                            <div>
                                <h2>{$model.model_name|escape}</h2>
                                <p class="model-detail-author">
                                    <i class="fas fa-user-edit"></i> Author: <strong>{$model.model_author|escape|default:"COBRA Community"}</strong>
                                </p>
                            </div>
                            <div class="model-status-badge {if $file_exists}model-status-active{else}model-status-missing{/if}">
                                {if $file_exists}
                                    <i class="fas fa-check-circle"></i> SBML Active
                                {else}
                                    <i class="fas fa-exclamation-triangle"></i> SBML Missing
                                {/if}
                            </div>
                        </div>

                        <div class="model-description-section">
                            <h4>Description & Scope</h4>
                            <p class="model-description-text">{$model.model_description|escape|nl2br}</p>
                        </div>

                        <div class="model-meta-grid">
                            <!-- Publication Box -->
                            <div class="model-meta-box">
                                <h5>
                                    <i class="fas fa-book-open"></i> Reference Publication
                                </h5>
                                {if $model.model_publication && $model.model_publication != "NA"}
                                    <p>{$model.model_publication|escape}</p>
                                    <a href="https://pubmed.ncbi.nlm.nih.gov/?term={$model.model_publication|escape:url}" target="_blank" class="text-link">
                                        Find on PubMed <i class="fas fa-external-link-alt"></i>
                                    </a>
                                {else}
                                    <p class="text-muted" style="font-style: italic;">No publication linked to this model.</p>
                                {/if}
                            </div>

                            <!-- Technical Specs -->
                            <div class="model-meta-box">
                                <h5>
                                    <i class="fas fa-cogs"></i> Technical Specifications
                                </h5>
                                <ul class="model-spec-list">
                                    <li class="model-spec-item">
                                        <span class="text-muted">Filename:</span>
                                        <strong>{$model.model_filename|escape}</strong>
                                    </li>
                                    <li class="model-spec-item">
                                        <span class="text-muted">Format:</span>
                                        <strong>SBML Level 3</strong>
                                    </li>
                                    <li class="model-spec-item">
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
                            <a href="fba_analysis.php" class="btn-primary-large">
                                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Simulation with this Model
                            </a>
                        </div>
                    </div>
                {else}
                    <div class="card-style model-empty-state">
                        <i class="fas fa-mouse-pointer"></i>
                        <h2>Please select a model from the left to view details.</h2>
                        <p class="text-muted">Select an organism to explore its metabolic potential before running your FBA simulations.</p>
                    </div>
                {/if}
            </section>
        </div>
    </div>
{/block}

{block name="scripts"}
<!-- No additional styles needed here; all moved to platform.css -->
{/block}
