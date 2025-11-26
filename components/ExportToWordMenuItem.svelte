<script>
  import { onMount } from 'svelte';
  import { exportPageToWord } from './exportToWordUtil.js';

  export let pageTitle = '';
  export let includeCharts = true;
  export let maxTableRows = 100;

  let isExporting = false;
  let menuItemElement;

  onMount(() => {
    setTimeout(() => {
      // Find the Print PDF button in the dropdown menu
      const printButton = document.querySelector('button[title="Print PDF"]') || 
                         document.querySelector('button:has(svg)');
      
      if (printButton && menuItemElement) {
        const dropdownMenu = printButton.closest('[role="menu"]') || 
                            printButton.parentElement;
        
        if (dropdownMenu) {
          // Insert after the Print PDF button
          if (printButton.nextSibling) {
            dropdownMenu.insertBefore(menuItemElement, printButton.nextSibling);
          } else {
            dropdownMenu.appendChild(menuItemElement);
          }
          menuItemElement.style.display = 'block';
        }
      }
      
      // Fallback: if we can't find the menu, don't show the button
      if (!menuItemElement.parentElement || menuItemElement.parentElement === document.body) {
        menuItemElement.style.display = 'none';
      }
    }, 100);
  });

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
  bind:this={menuItemElement}
  on:click={handleExport}
  disabled={isExporting}
  class="menu-item"
  style="display: none;"
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
