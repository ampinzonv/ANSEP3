{extends file="layout.tpl"}

{block name="title"}Documentation: Flux Variability Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Flux Variability Analysis (FVA)</h1>
            <p class="text-muted">Explore metabolic redundancy and define the boundaries of the metabolic solution space.</p>
        </header>

        <!-- 1. What is FVA? -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-info-circle"></i> What is FVA?</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    While <strong>Flux Balance Analysis (FBA)</strong> finds a single optimal solution, <strong>Flux Variability Analysis (FVA)</strong> explores all possible solutions that satisfy the optimization objective. 
                    It determines the minimum and maximum possible flux for each reaction in the network while maintaining a required level of performance (e.g., 90% or 100% of maximum growth).
                </p>
                <div style="background: #f8fafc; padding: 1.5rem; border-radius: 8px; border-left: 4px solid var(--accent); margin-top: 1.5rem;">
                    <h4 style="margin-top: 0;">Main Use Cases:</h4>
                    <ul style="margin-bottom: 0;">
                        <li>Identifying <strong>Essential Reactions</strong> (those with no variability at all).</li>
                        <li>Characterizing <strong>Metabolic Redundancy</strong> (alternative pathways to achieve the same result).</li>
                        <li>Identifying <strong>Blocked Reactions</strong> (those that cannot carry flux under certain nutrient conditions).</li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 2. The Concept of Fraction of Optimum -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-percentage"></i> Fraction of Optimum</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    In ANSEP3, you can set a <strong>Fraction of Optimum</strong> (default: 0.9 or 90%). 
                    This setting relaxes the growth constraint, allowing the cell to behave slightly sub-optimally.
                </p>
                <ul>
                    <li><strong>1.0 (100%)</strong>: Only solutions that achieve the absolute maximum growth are considered. The solution space is very narrow.</li>
                    <li><strong>0.9 (90%)</strong>: Solutions that achieve at least 90% of the maximum growth are considered. This reveals more alternative pathways and "metabolic flexibility."</li>
                </ul>
            </div>
        </section>

        <!-- 3. Understanding Results -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-chart-bar"></i> Interpreting FVA Results</h2>
            
            <!-- Range Plot -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-arrows-alt-h"></i> Flux Variability Ranges (Tornado Plot)</h3>
                <p>This chart shows the reactions with the highest flexibility. Each horizontal line represents the interval between the minimum and maximum possible flux.</p>
                <ul style="line-height: 1.6;">
                    <li><strong>Blue Bar</strong>: The allowed range for that reaction ID.</li>
                    <li><strong>Width (&Delta;v)</strong>: A larger width indicates higher flexibility or redundancy for that specific metabolic step.</li>
                </ul>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Redundancy Histogram -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-columns"></i> Uncertainty Histogram (Redundancy)</h3>
                <p>We categorize all reactions into four levels of redundancy based on their flux interval width (&Delta;v):</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 1.5rem;">
                    <div class="info-card" style="border-top: 4px solid #95a5a6; padding: 1.5rem;">
                        <h4 style="margin-top: 0; color: #7f8c8d;">Rigid</h4>
                        <p style="font-size: 0.9rem;">Width &lt; 10<sup>-6</sup>. These reactions carry a fixed flux. They are critical and have no alternative routes.</p>
                    </div>
                    <div class="info-card" style="border-top: 4px solid #3498db; padding: 1.5rem;">
                        <h4 style="margin-top: 0; color: #2980b9;">Low Flexibility</h4>
                        <p style="font-size: 0.9rem;">Width between 10<sup>-6</sup> and 1. Small adjustments are possible but the reaction is mostly constrained.</p>
                    </div>
                    <div class="info-card" style="border-top: 4px solid #2980b9; padding: 1.5rem;">
                        <h4 style="margin-top: 0; color: #1a5276;">Moderate</h4>
                        <p style="font-size: 0.9rem;">Width between 1 and 100. Significant alternative paths exist for the metabolites processed here.</p>
                    </div>
                    <div class="info-card" style="border-top: 4px solid #e67e22; padding: 1.5rem;">
                        <h4 style="margin-top: 0; color: #d35400;">High Redundancy</h4>
                        <p style="font-size: 0.9rem;">Width &gt; 100. These often represent loops or highly redundant cycles within the network structure.</p>
                    </div>
                </div>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Table -->
            <div class="doc-sub-section">
                <h3 style="color: var(--accent);"><i class="fas fa-list-ol"></i> Variability Data Table</h3>
                <ul>
                    <li><strong>Minimum Flux</strong>: The lowest sustainable flow for this reaction.</li>
                    <li><strong>Maximum Flux</strong>: The highest sustainable flow.</li>
                    <li><strong>Classification</strong>: Automatically assigned based on the width to help you prioritize your research.</li>
                </ul>
            </div>
        </section>

        <!-- Final Call to Action -->
        <div style="text-align: center; margin-top: 3rem;">
            <a href="fva_analysis.php" class="btn-primary-large">
                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Your Flux Variability Study
            </a>
        </div>
    </div>
{/block}
