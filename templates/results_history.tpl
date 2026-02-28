{extends file="layout.tpl"}

{block name="title"}Results History - ANSEP3{/block}

{block name="content"}
    <div class="analysis-container-wide">
        <header class="page-header">
            <h1>Results History</h1>
            <p class="text-muted">Browse and re-examine your past FBA simulations.</p>
            
            {if isset($smarty.get.status)}
                <div class="alert alert-{if $smarty.get.status eq 'success'}success{else}danger{/if}" style="margin-top: 1.5rem;">
                    {$smarty.get.message|escape}
                </div>
            {/if}
        </header>

        <div class="card-style card-style-dense">
            {if $history}
                <table class="results-table">
                    <thead>
                        <tr>
                            <th class="nowrap"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg> Date & Time</th>
                            <th><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path><line x1="7" y1="7" x2="7.01" y2="7"></line></svg> Analysis Name</th>
                            <th class="text-center"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg> Type</th>
                            <th><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><path d="M2 22s1-4 4-4 4 4 4 4"></path><path d="M7 2a4 4 0 0 1 4 4c0 3-4 6-4 6s-4-3-4-6a4 4 0 0 1 4-4z"></path></svg> Model</th>
                            <th class="text-center"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg> Status</th>
                            <th class="text-center"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: middle; margin-right: 4px;"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"></path></svg> Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $history as $item}
                            <tr>
                                <td><span class="text-small">{$item.date|escape}</span></td>
                                <td>{$item.name|escape}</td>
                                <td class="text-center"><span class="badge badge-outline">{$item.type|escape}</span></td>
                                <td><code>{$item.model|escape}</code></td>
                                <td class="text-center">
                                    <div style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                                        {if $item.execution_status eq 'processing'}
                                            <span class="status-text status-text-info" title="Processing">⏳</span>
                                        {elseif $item.execution_status eq 'success'}
                                            <span class="status-text status-text-success" title="Execution Success">✓</span>
                                            {if $item.status}
                                                <span class="text-small {if $item.status eq 'Optimal'}text-success{else}text-warning{/if}" style="font-size: 0.75rem;">
                                                    ({$item.status|escape})
                                                </span>
                                            {/if}
                                        {elseif $item.execution_status eq 'error'}
                                            <span class="status-text status-text-danger" title="Simulation Failed">✗</span>
                                        {else}
                                            <span class="status-text status-text-muted">?</span>
                                        {/if}
                                    </div>
                                </td>
                                <td class="text-center nowrap">
                                    <a href="view_result.php?id={$item.analysis_id}" class="text-link" style="margin-right: 1.5rem;" title="View Results">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                    </a>
                                    <a href="delete_result.php?id={$item.analysis_id}" class="text-link" style="color: #e53e3e;" title="Delete Analysis" 
                                       onclick="return confirm('Are you sure you want to permanently delete this analysis?');">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                    </a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div style="text-align: center; padding: 3rem;">
                    <i class="fas fa-folder-open" style="font-size: 3rem; color: #cbd5e0; margin-bottom: 1rem; display: block;"></i>
                    <p>No past simulations found.</p>
                    <a href="fba_analysis.php" class="btn-primary-large" style="display: inline-block; margin-top: 1rem;">Run Your First Analysis</a>
                </div>
            {/if}
        </div>
    </div>
{/block}
