<script>
  import { exportPageToWord } from './exportToWordUtil.js';

  export let pageTitle = '';
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
  class="menu-item"
>
  {#if isExporting}
    Exporting...
  {:else}
    Export to Word
  {/if}
</button>

<style>
  .menu-item {
    width: 100%;
    text-align: left;
    padding: 0.5rem 1rem;
    background: none;
    border: none;
    cursor: pointer;
    font-size: 0.875rem;
    color: inherit;
    transition: background-color 0.2s;
  }

  .menu-item:hover:not(:disabled) {
    background-color: rgba(0, 0, 0, 0.05);
  }

  .menu-item:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  :global(.dark) .menu-item:hover:not(:disabled) {
    background-color: rgba(255, 255, 255, 0.1);
  }
</style>
