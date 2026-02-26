{extends file="layout.tpl"}

{block name="title"}Dashboard - ANSEP3{/block}

{block name="content"}
    <h1>Welcome Back, {$user_name}</h1>
    <p style="color: var(--text-muted); margin-bottom: 2.5rem;">Use the navigation menu above to start exploring and analyzing models, or browse our specialized modeling areas below.</p>

    <div class="cards-grid">
        <!-- Card 1: Brain Cell Metabolic Models -->
        <div class="info-card">
            <div class="card-icon">
                <img src="img/GEM_100px.png" alt="Brain Cell Models">
            </div>
            <h2>Brain Cell Metabolic Models</h2>
            <p>Designed to simulate the biochemical processes within neurons and glial cells, providing insights into their metabolic interactions and energy dynamics.<br><br>
            These models help researchers explore how cellular metabolism contributes to brain function and its role in neurodegenerative diseases, paving the way for targeted therapeutic strategies.</p>
            <a href="#" class="btn-card-info">More info on our brain cell models</a>
        </div>

        <!-- Card 2: Microbiota Metabolic Models -->
        <div class="info-card">
            <div class="card-icon">
                <img src="img/MICROBIOMA_100px.png" alt="Microbiota Models">
            </div>
            <h2>Microbiota Metabolic Models</h2>
            <p>By simulating metabolic exchanges and community dynamics, our microbiota models provide valuable insights into the relationships between the human microbiota and the brain.<br><br>
            This research is at the forefront of understanding how microbial imbalances may contribute to neurodegenerative conditions, paving the way for innovative treatments and preventive strategies.</p>
            <a href="#" class="btn-card-info">More info on our Microbiome models</a>
        </div>

        <!-- Card 3: Online metabolic modeling -->
        <div class="info-card">
            <div class="card-icon">
                <img src="img/HEATMAP_100px.png" alt="Online Modeling">
            </div>
            <h2>Online metabolic modeling</h2>
            <p>ANSeP provides a powerful platform for performing online metabolic analyses, enabling researchers to simulate and explore metabolic networks directly from their web browser.<br><br>
            With tools like Flux Balance Analysis (FBA), Flux Variability Analysis (FVA), and gene knockout simulations, ANSeP allows users to investigate metabolic pathways, optimize objectives, and study the effects of genetic or environmental changes on metabolic systems.</p>
            <a href="#" class="btn-card-info">More info on Metabolic modeling</a>
        </div>
    </div>
{/block}
