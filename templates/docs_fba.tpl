{extends file="layout.tpl"}

{block name="title"}Documentation: Flux Balance Analysis - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Flux Balance Analysis (FBA)</h1>
            <p class="text-muted">A comprehensive guide to understanding and interpreting metabolic simulation results.</p>
        </header>

        <!-- 1. What is FBA? -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-info-circle"></i> What is FBA?</h2>
            <div style="line-height: 1.8; color: var(--primary); font-size: 1.1rem;">
                <p>
                    <strong>Flux Balance Analysis (FBA)</strong> is a mathematical approach used to simulate the flow of metabolites through a metabolic network. 
                    It allows researchers to predict the growth rate of an organism or the production rate of a specific metabolite without needing detailed kinetic parameters.
                </p>
                <p>
                    FBA operates under the <strong>Steady-State Assumption</strong>, which means the concentration of internal metabolites does not change over time. 
                    Mathematically, this is expressed as <code>S · v = 0</code>, where <code>S</code> is the stoichiometry matrix and <code>v</code> is the vector of metabolic fluxes.
                </p>
                <div style="background: #f8fafc; padding: 1.5rem; border-radius: 8px; border-left: 4px solid var(--accent); margin-top: 1.5rem;">
                    <h4 style="margin-top: 0;">Main Use Cases:</h4>
                    <ul style="margin-bottom: 0;">
                        <li>Predicting maximum theoretical growth rates (Biomass).</li>
                        <li>Evaluating the impact of nutrient availability (Uptake constraints).</li>
                        <li>Simulating gene deletions and metabolic engineering strategies.</li>
                    </ul>
                </div>
            </div>
        </section>

        <!-- 2. Understanding Results -->
        <section class="card-style mb-4">
            <h2 style="color: var(--primary);"><i class="fas fa-chart-line"></i> Interpreting Results</h2>
            
            <!-- Objective Value -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-bullseye"></i> Objective Value</h3>
                <p>This is the numerical solution to the optimization problem. If your objective function is set to <strong>Biomass</strong>, the value represents the theoretical growth rate, measured in <code>h⁻¹</code> (1/hour).</p>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Flux Ranking -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <div style="display: flex; gap: 2rem; align-items: start;">
                    <div style="flex: 1;">
                        <h3 style="color: var(--accent);"><i class="fas fa-sort-amount-down"></i> Metabolic Flux Ranking</h3>
                        <p>This chart displays the "metabolic highways" of the cell—the reactions that carry the most flux under the simulated conditions.</p>
                        <ul style="line-height: 1.6;">
                            <li><strong>Horizontal Bars</strong>: Represent the absolute magnitude of the flux (<code>|v|</code>).</li>
                            <li><strong>Colors</strong>: 
                                <ul>
                                    <li><span style="color: #2c3e50; font-weight: bold;">Dark Indigo</span>: The target Objective function.</li>
                                    <li><span style="color: #3498db; font-weight: bold;">Cyan Blue</span>: Positive flux (Forward direction).</li>
                                    <li><span style="color: #95a5a6; font-weight: bold;">Grey</span>: Negative flux (Reverse direction).</li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Exchange Balance -->
            <div class="doc-sub-section" style="margin-bottom: 3rem;">
                <h3 style="color: var(--accent);"><i class="fas fa-exchange-alt"></i> Exchange Balance (Barrier Analysis)</h3>
                <p>This visualization represents the <strong>Cell Membrane</strong> as a dashed vertical line. It shows how the cell interacts with its environment.</p>
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-top: 1.5rem;">
                    <div style="background: #fff5f5; padding: 1.5rem; border-radius: 12px; border: 1px solid #fed7d7;">
                        <h4 style="color: #c53030; margin-top: 0;"><i class="fas fa-arrow-right"></i> Left Side: Uptake (Inward)</h4>
                        <p>Metabolites entering the cell from the medium. These carry <strong>negative flux</strong> in the model convention.</p>
                    </div>
                    <div style="background: #f0fff4; padding: 1.5rem; border-radius: 12px; border: 1px solid #c6f6d5;">
                        <h4 style="color: #2f855a; margin-top: 0;"><i class="fas fa-sign-out-alt"></i> Right Side: Secretion (Outward)</h4>
                        <p>Metabolites being produced and released into the extracellular space. These carry <strong>positive flux</strong>.</p>
                    </div>
                </div>
                
                <p style="margin-top: 1.5rem;">
                    <strong>Arrow Thickness</strong>: Directly proportional to the flux magnitude. Thicker arrows represent major carbon sources or main waste products (like CO₂).
                </p>
            </div>

            <hr style="border: 0; border-top: 1px solid var(--border); margin: 2rem 0;">

            <!-- Detailed Table -->
            <div class="doc-sub-section">
                <h3 style="color: var(--accent);"><i class="fas fa-table"></i> Detailed Reaction Table</h3>
                <p>A granular view of every reaction that remains active in the optimal solution.</p>
                <ul>
                    <li><strong>Flux Value</strong>: Expressed in <code>mmol / gDW · hr</code> (millimoles per gram of Dry Weight per hour).</li>
                    <li><strong>Intensity Bar</strong>: A visual relative aid to quickly identify the most significant reactions without reading every number.</li>
                </ul>
            </div>
        </section>

        <!-- Final Call to Action -->
        <div style="text-align: center; margin-top: 3rem;">
            <a href="fba_analysis.php" class="btn-primary-large">
                <i class="fas fa-play" style="margin-right: 10px;"></i> Start Your Own FBA Simulation
            </a>
        </div>
    </div>
{/block}
