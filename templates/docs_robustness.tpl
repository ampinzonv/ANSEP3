{extends file="layout.tpl"}

{block name="title"}Documentation: Robustness Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Metabolic Robustness Analysis</h1>
            <p class="text-muted">Evaluate the sensitivity and resilience of your metabolic model to flux variations.</p>
        </header>

        <!-- 1. What is Robustness Analysis? -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-info-circle"></i> What is Robustness Analysis?</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    <strong>Robustness Analysis</strong> is a computational technique used to determine how a specific metabolic process (the objective function, usually growth) responds to changes in the activity of a single reaction.
                </p>
                <p>
                    By performing a "parameter sweep," the platform fixes the flux of a <strong>Control Reaction</strong> at different values within a range and re-calculates the optimal objective. 
                    This reveals the degree of dependency between that reaction and the overall metabolic performance.
                </p>
                <div style="background: #f8fafc; padding: 1.5rem; border-radius: 8px; border-left: 4px solid var(--accent); margin-top: 1.5rem;">
                    <h4 style="margin-top: 0;">Main Use Cases:</h4>
                    <ul style="margin-bottom: 0;">
                        <li>Determining <strong>Limiting Nutrients</strong> (e.g., how Oxygen levels affect Biomass).</li>
                        <li>Identifying <strong>Metabolic Thresholds</strong> (where a critical drop in performance occurs).</li>
                        <li>Assessing the impact of enzymatic over-expression or inhibition.</li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 2. Understanding Results -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-chart-line"></i> Interpreting the Robustness Curve</h2>
            
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-wave-square"></i> The Graph Structure</h3>
                <p>The resulting plot shows the <strong>Control Flux</strong> on the X-axis and the <strong>Objective Value</strong> on the Y-axis.</p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-top: 1.5rem;">
                    <div style="background: #eef2f7; padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
                        <h4 style="color: var(--primary); margin-top: 0;">Positive Correlation</h4>
                        <p style="font-size: 0.9rem;">If the curve goes up, the reaction is <strong>limiting</strong>. Increasing its flux allows for a higher objective value (e.g., more nutrients &rarr; more growth).</p>
                    </div>
                    <div style="background: #eef2f7; padding: 1.5rem; border-radius: 12px; border: 1px solid var(--border);">
                        <h4 style="color: var(--primary); margin-top: 0;">Negative Correlation</h4>
                        <p style="font-size: 0.9rem;">If the curve goes down, the reaction is <strong>detrimental</strong> to the objective. Usually seen in byproduct removal or competing pathways.</p>
                    </div>
                </div>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Specific Patterns -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-search-plus"></i> Common Patterns</h3>
                <ul style="line-height: 1.8;">
                    <li><strong>The Plateau</strong>: When the curve becomes flat, it means the reaction is no longer a bottleneck. Other reactions in the system have reached their maximum capacity.</li>
                    <li><strong>The Optimal Peak</strong>: In some cases, there is an "intermediate" flux value that yields the highest objective. This is common in complex co-factor recycling systems.</li>
                    <li><strong>Infeasibility Regions</strong>: If the curve drops to zero abruptly, it indicates that the system cannot sustain itself at those specific flux levels (e.g., too little O&infin; for an aerobic organism).</li>
                </ul>
            </div>

        </section>

        <!-- 3. Configuring the Sweep -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-sliders-h"></i> Configuration Parameters</h2>
            <div style="line-height: 1.6; color: var(--primary);">
                <ul>
                    <li><strong>Number of Steps</strong>: Defines the resolution of the curve. More steps (e.g., 50+) result in a smoother line but take longer to compute.</li>
                    <li><strong>Flux Range (Min/Max)</strong>: The boundaries within which you want to explore the reaction's behavior.</li>
                    <li><strong>Step Size</strong>: Instead of a fixed number of points, you can define a specific increment (e.g., 1.0 mmol/gDW&middot;hr) between samples.</li>
                </ul>
            </div>
        </section>

        <!-- Final Call to Action -->
        <div style="text-align: center; margin-top: 3rem;">
            <a href="robustness_analysis.php" class="btn-primary-large">
                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Robustness Analysis
            </a>
        </div>
    </div>
{/block}
