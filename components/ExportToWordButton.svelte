<script>
  import { exportPageToWord } from './exportToWordUtil.js';

  export let pageTitle = '';
  export let buttonText = '📄 Export to Word';
  export let includeCharts = true;
  export let maxTableRows = 100;

  let isExporting = false;

  async function handleExport() {
    if (isExporting) return;
    
    isExporting = true;
    
    try {
      await exportPageToWord({ includeCharts, maxTableRows, pageTitle });
    } catch (error) {
      alert('Failed to export to Word. Please try again.');
    } finally {
      isExporting = false;
    }
  }
</script>

<button 
  on:click={handleExport}
  disabled={isExporting}
  class="export-button"
  title="Export to Word"
>
  {#if isExporting}
    <span class="spinner"></span>
    <span>Exporting...</span>
  {:else}
    {buttonText}
  {/if}
</button>

<style>
  .export-button {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: #2563eb;
    color: white;
    border: none;
    border-radius: 0.375rem;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
    transition: background-color 0.2s;
    white-space: nowrap;
  }

  .export-button:hover:not(:disabled) {
    background: #1d4ed8;
  }

  .export-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .spinner {
    width: 14px;
    height: 14px;
    border: 2px solid white;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
