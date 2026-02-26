{* Reusable Model Selector Component *}
<div class="model-selector-container">
    <label for="model_id" class="form-label">Select Metabolic Model for Analysis:</label>
    <select name="model_id" id="model_id" class="form-select" onchange="updateModelDetails()">
        <option value="">-- Choose a model --</option>
        {foreach $models as $model}
            <option value="{$model.Id}" 
                    data-description="{$model.model_description|escape}" 
                    data-author="{$model.model_author|escape}"
                    data-publication="{$model.model_publication|escape}">
                {$model.model_name}
            </option>
        {/foreach}
    </select>

    <div id="model-details-box" class="model-info-box" style="display: none;">
        <h4 id="detail-title">Model Details</h4>
        <p id="detail-author" class="text-small"></p>
        <p id="detail-description"></p>
        <a id="detail-link" href="#" target="_blank" class="text-link">View Publication</a>
    </div>
</div>

<script>
function updateModelDetails() {
    const select = document.getElementById('model_id');
    const box = document.getElementById('model-details-box');
    const selected = select.options[select.selectedIndex];
    
    if (selected.value === "") {
        box.style.display = 'none';
        return;
    }
    
    document.getElementById('detail-author').innerHTML = "<strong>Author:</strong> " + selected.getAttribute('data-author');
    document.getElementById('detail-description').innerText = selected.getAttribute('data-description');
    
    const pub = selected.getAttribute('data-publication');
    const link = document.getElementById('detail-link');
    if (pub && pub !== 'NA' && pub !== '') {
        link.href = pub;
        link.style.display = 'inline-block';
    } else {
        link.style.display = 'none';
    }
    
    box.style.display = 'block';
}
</script>

