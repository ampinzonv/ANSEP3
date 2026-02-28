/**
 * ANSEP3 Simulation Engine - Shared JavaScript
 * Provides AJAX submission and status polling for background tasks.
 */

const ANSEP = {
    /**
     * Initializes a simulation form to use AJAX and Polling
     * @param {string} formSelector - CSS selector for the form
     * @param {string} overlayId - ID of the loading overlay element
     */
    initSimulationForm: function (formSelector, overlayId) {
        const form = document.querySelector(formSelector);
        const overlay = document.getElementById(overlayId);

        if (form && overlay) {
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                overlay.classList.add('active');

                const formData = new FormData(form);
                fetch(form.action, {
                    method: 'POST',
                    body: formData
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'launched') {
                            this.startPolling(data.analysis_id, overlayId);
                        } else {
                            alert('Error starting simulation: ' + (data.message || 'Unknown error'));
                            overlay.classList.remove('active');
                        }
                    })
                    .catch(error => {
                        console.error('Submission error:', error);
                        alert('Critical error launching simulation. Please check server logs.');
                        overlay.classList.remove('active');
                    });
            });
        }
    },

    /**
     * Polls the status API until completion
     * @param {string} analysisId - The unique ID of the analysis
     * @param {string} overlayId - ID of the loading overlay to hide on completion (if needed)
     */
    startPolling: function (analysisId, overlayId) {
        const loadingText = document.querySelector('.loading-text');
        let attempts = 0;

        const pollInterval = setInterval(() => {
            attempts++;
            if (attempts > 300) { // Safety timeout: 10 minutes
                clearInterval(pollInterval);
                alert('Simulation timed out. Please check Results History later.');
                location.reload();
                return;
            }

            fetch(`check_simulation_status.php?id=${analysisId}`)
                .then(response => response.json())
                .then(data => {
                    if (data.status === 'success' || data.status === 'error') {
                        clearInterval(pollInterval);
                        // Redirect to the result viewer
                        window.location.href = `view_result.php?id=${analysisId}`;
                    }

                    // Visual feedback for long-running tasks
                    if (loadingText && attempts % 5 === 0) {
                        loadingText.innerText = `Processing simulation... (Step ${attempts})`;
                    }
                })
                .catch(err => console.warn('Polling check failed (will retry):', err));
        }, 2000);
    }
};
