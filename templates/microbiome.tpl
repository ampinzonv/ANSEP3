{extends file="layout.tpl"}

{block name="title"}Microbiomes - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Microbiota Metabolic Models</h1>
            <p class="text-muted">Explore the complex metabolic interactions within microbial communities and their impact on human health.</p>
        </header>

        <div class="card-style" style="display: flex; gap: 3rem; align-items: center; padding: 4rem;">
            <div style="flex: 0 0 250px;">
                <img src="img/MICROBIOMA_250px.png" alt="Microbiome" style="width: 100%; height: auto;">
            </div>
            <div style="flex: 1;">
                <h2 style="color: var(--primary); margin-top: 0; margin-bottom: 0.5rem; font-size: 2rem;">Understanding the Gut-Brain Axis</h2>
                <span class="badge badge-info" style="margin-bottom: 1.5rem; display: inline-block;">Coming Soon</span>
                <p style="font-size: 1.15rem; line-height: 1.8; color: var(--primary);">
                    The human microbiome is a vast and intricate ecosystem of microorganisms that plays a crucial role in our physiology. 
                    Recent scientific evidence has highlighted a profound connection between the gut microbiota and brain function, 
                    often referred to as the "Gut-Brain Axis."
                </p>
                <p style="font-size: 1.15rem; line-height: 1.8; color: var(--primary); margin-top: 1.5rem;">
                    Through genome-scale metabolic modeling of microbial communities, we can simulate the cross-feeding of metabolites, 
                    the production of neuroactive compounds, and the overall community dynamics under different dietary or clinical conditions.
                </p>
                
                <div style="margin-top: 2.5rem; display: flex; gap: 1rem;">
                    <a href="#" class="btn-primary-large" style="opacity: 0.6; cursor: not-allowed;">
                        <i class="fas fa-microscope" style="margin-right: 8px;"></i> Explore Microbiome Collections
                    </a>
                </div>
            </div>
        </div>

        <div class="cards-grid" style="margin-top: 3rem;">
            <div class="info-card" style="padding: 2rem;">
                <h3>Community Modeling</h3>
                <p>Simulate how different species interact, compete, and cooperate within a shared metabolic environment.</p>
            </div>
            <div class="info-card" style="padding: 2rem;">
                <h3>Metabolic Signatures</h3>
                <p>Identify specific microbial metabolites that may serve as biomarkers for neurodegenerative or inflammatory states.</p>
            </div>
            <div class="info-card" style="padding: 2rem;">
                <h3>Host-Microbe Interaction</h3>
                <p>Integrate human tissue models with microbiome reconstructions to study systemic metabolic effects.</p>
            </div>
        </div>
    </div>
{/block}
