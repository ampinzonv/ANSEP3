{extends file="layout.tpl"}

{block name="title"}Contact Us - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container">
        <header class="page-header">
            <h1>Contact & Collaboration</h1>
            <p class="text-muted">ANSEP3 is a collaborative effort between major research institutions in Colombia.</p>
        </header>

        <div class="card-style" style="margin-bottom: 3rem; padding: 3rem; border-left: 5px solid var(--accent);">
            <h2 style="color: var(--primary); margin-top: 0;">Institutional Partnership</h2>
            <p style="font-size: 1.1rem; line-height: 1.6; color: var(--primary);">
                This platform was developed as a joint initiative between the <strong>Pontificia Universidad Javeriana</strong> and the 
                <strong>Universidad Nacional de Colombia (Sede Bogotá)</strong>. Our goal is to provide the scientific community with advanced 
                tools for interrogating genome-scale metabolic models.
            </p>
        </div>

        <div class="cards-grid">
            <!-- Contact 1: Javeriana -->
            <div class="info-card" style="align-items: flex-start; text-align: left; padding: 2.5rem;">
                <div style="margin-bottom: 1.5rem; display: flex; align-items: center; gap: 1rem;">
                    <i class="fas fa-university" style="font-size: 2rem; color: var(--accent);"></i>
                    <h3 style="margin: 0; color: var(--primary);">Pontificia Universidad Javeriana</h3>
                </div>
                
                <h4 style="margin-bottom: 0.5rem; color: var(--primary);">Janneth Gonzalez Ph.D.</h4>
                <p class="text-muted" style="margin-bottom: 1.5rem;">
                    Departamento de Nutrición y Bioquímica<br>
                    Facultad de Ciencias
                </p>
                
                <a href="mailto:janneth.gonzalez@javeriana.edu.co" class="text-link" style="font-size: 1rem;">
                    <i class="fas fa-envelope"></i> janneth.gonzalez@javeriana.edu.co
                </a>
            </div>

            <!-- Contact 2: Nacional -->
            <div class="info-card" style="align-items: flex-start; text-align: left; padding: 2.5rem;">
                <div style="margin-bottom: 1.5rem; display: flex; align-items: center; gap: 1rem;">
                    <i class="fas fa-graduation-cap" style="font-size: 2rem; color: var(--accent);"></i>
                    <h3 style="margin: 0; color: var(--primary);">Universidad Nacional de Colombia</h3>
                </div>
                
                <h4 style="margin-bottom: 0.5rem; color: var(--primary);">Andrés Pinzón Ph.D.</h4>
                <p class="text-muted" style="margin-bottom: 1.5rem;">
                    Instituto de Genética<br>
                    Sede Bogotá
                </p>
                
                <a href="mailto:ampinzonv@unal.edu.co" class="text-link" style="font-size: 1rem;">
                    <i class="fas fa-envelope"></i> ampinzonv@unal.edu.co
                </a>
            </div>
        </div>

        <div style="margin-top: 4rem; text-align: center; border-top: 1px solid var(--border); padding-top: 2rem;">
            <p class="text-muted">For technical support or feature requests, please contact our researchers directly via the emails provided above.</p>
        </div>
    </div>
{/block}
