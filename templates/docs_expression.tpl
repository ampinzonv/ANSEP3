{extends file="layout.tpl"}

{block name="title"}Documentation: Expression Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Expression Data Integration</h1>
            <p class="text-muted">Bridge the gap between omics data and metabolic flux predictions.</p>
        </header>

        <!-- 1. What is Expression Analysis? -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-microscope"></i> Integration &quot;Exp2Flux&quot;</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    Standard FBA assumes all reactions have a maximum capacity (e.g., 1000 mmol/gDW&middot;hr). However, in reality, the capacity of a reaction is often limited by the abundance of the enzymes that catalyze it.
                </p>
                <p>
                    ANSEP3 implements the <strong>exp2flux</strong> method, which uses transcriptomics or proteomics data to constrain the flux boundaries of each reaction. This results in a "context-specific" model that reflects the actual metabolic state of the cell under specific conditions.
                </p>
                <div style="background: #f8fafc; padding: 1.5rem; border-radius: 8px; border-left: 4px solid var(--accent); margin-top: 1.5rem;">
                    <h4 style="margin-top: 0;">Key Benefits:</h4>
                    <ul style="margin-bottom: 0;">
                        <li>Higher predictive accuracy compared to generic FBA.</li>
                        <li>Captures tissue-specific or environment-specific metabolic behaviors.</li>
                        <li>Identifies active vs. inactive pathways based on real biological measurements.</li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 2. GPR Rules: The Biological Bridge -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-dna"></i> GPR Logic (Gene-Protein-Reaction)</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    Metabolic models contain <strong>GPR rules</strong>—mathematical descriptions of how genes cooperate to form functional enzymes. We map gene expression to reactions using the following logic:
                </p>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin: 1.5rem 0;">
                    <div style="background: #eef2f7; padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
                        <h4 style="color: var(--primary); margin-top: 0;">AND Logic (Complexes)</h4>
                        <p style="font-size: 0.9rem;">Used when multiple proteins must work together (Subunits). We use the <strong>Minimum</strong> expression value, as the least abundant component limits the whole complex.</p>
                        <code style="font-size: 0.8rem; background: #fff; padding: 2px 5px;">limit = min(G1, G2)</code>
                    </div>
                    <div style="background: #eef2f7; padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
                        <h4 style="color: var(--primary); margin-top: 0;">OR Logic (Isozymes)</h4>
                        <p style="font-size: 0.9rem;">Used when different genes can catalyze the same reaction independently. We use the <strong>Sum</strong> of their expression levels.</p>
                        <code style="font-size: 0.8rem; background: #fff; padding: 2px 5px;">capacity = sum(G1, G2)</code>
                    </div>
                </div>
            </div>
        </section>

        <!-- 3. Handling Irregular Data -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-magic"></i> Missing Data Strategies</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>It is common for experimental datasets to be incomplete. ANSEP3 allows you to choose how to treat reactions that have no corresponding gene data:</p>
                <ul>
                    <li><strong>Mean/Median</strong>: Assigns the average activity level of the rest of the network to missing reactions (Recommended).</li>
                    <li><strong>Min/Max</strong>: Assigns the lowest or highest observed values, making the model more or less constrained respectively.</li>
                </ul>
            </div>
        </section>

        <!-- 4. Visualizing Influence -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-chart-pie"></i> Interpretation of Results</h2>
            <p style="line-height: 1.6;">The results of this analysis highlight which parts of the metabolism are actively being driven by the observed gene expression profile.</p>
            <ul>
                <li><strong>Flux Ranking</strong>: Shows the reactions that are carrying the highest metabolic weight, considering both the biological constraints and the metabolic network structure.</li>
                <li><strong>Intensity Bars</strong>: In the result table, these help you quickly identify the "hottest" metabolic hubs under your specific experimental condition.</li>
            </ul>
        </section>

        <!-- Final Call to Action -->
        <div style="text-align: center; margin-top: 3rem;">
            <a href="expression_analysis.php" class="btn-primary-large">
                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Expression Integration
            </a>
        </div>
    </div>
{/block}
