<script>
  import { onMount } from 'svelte';
  import { Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell, WidthType, ImageRun, AlignmentType, BorderStyle, ShadingType } from 'docx';
  import { saveAs } from 'file-saver';
  import html2canvas from 'html2canvas';

  export let includeCharts = true;
  export let maxTableRows = 100;

  let isExporting = false;
  let buttonElement;

  onMount(() => {
    // Wait for DOM to be fully ready
    setTimeout(() => {
      // Try multiple selectors to find the header actions area
      let targetContainer = null;
      
      const githubLink = document.querySelector('a[href*="github"]');
      if (githubLink) {
        targetContainer = githubLink.parentElement;
      }
      
      if (!targetContainer) {
        targetContainer = document.querySelector('header nav') || 
                         document.querySelector('header [class*="right"]') ||
                         document.querySelector('header > div:last-child');
      }
      
      if (targetContainer && buttonElement) {
        buttonElement.style.display = 'inline-flex';
        
        if (githubLink) {
          targetContainer.insertBefore(buttonElement, githubLink);
        } else {
          targetContainer.insertBefore(buttonElement, targetContainer.firstChild);
        }
      } else {
        // Fallback: show as floating button
        buttonElement.style.display = 'inline-flex';
        buttonElement.style.position = 'fixed';
        buttonElement.style.top = '1rem';
        buttonElement.style.right = '1rem';
        buttonElement.style.zIndex = '1000';
        document.body.appendChild(buttonElement);
      }
    }, 100);
  });

  async function exportToWord() {
    if (isExporting) return;
    
    isExporting = true;
    
    try {
      // Wait longer for content to be fully rendered
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const h1 = document.querySelector('main h1');
      const pageTitle = h1?.textContent?.trim() || 'Report';
      
      const sections = [];
      sections.push(
        new Paragraph({
          children: [new TextRun({ 
            text: pageTitle, 
            font: 'Arial', 
            size: 36, 
            bold: true 
          })],
          spacing: { after: 400 }
        })
      );

      const main = document.querySelector('main');
      if (!main) throw new Error('Could not find main content area');

      const scrollableElements = main.querySelectorAll('[class*="scroll"], [class*="table"]');
      for (const el of scrollableElements) {
        if (el.scrollHeight > el.clientHeight) {
          el.scrollTop = el.scrollHeight;
          await new Promise(resolve => setTimeout(resolve, 100));
          el.scrollTop = 0;
        }
      }

      const children = Array.from(main.children);
      const processedElements = new Set();
      
      for (const child of children) {
        await processElement(child, sections, processedElements);
      }

      if (sections.length === 1) {
        sections.push(new Paragraph({ 
          children: [new TextRun({ 
            text: 'No content found to export.', 
            font: 'Arial', 
            size: 22 
          })]
        }));
      }

      const validSections = sections.filter(s => s != null);
      if (validSections.length === 0) throw new Error('No valid content to export');

      const doc = new Document({
        sections: [{
          properties: { page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
          children: validSections
        }]
      });

      const blob = await Packer.toBlob(doc);
      const fileName = `${pageTitle.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${new Date().toISOString().split('T')[0]}.docx`;
      saveAs(blob, fileName);
      
    } catch (error) {
      console.error('Error exporting to Word:', error);
      alert('Failed to export to Word. Please try again.');
    } finally {
      isExporting = false;
    }
  }

  async function processElement(element, sections, processedElements) {
    const tagName = element.tagName?.toLowerCase();
    
    if (processedElements.has(element)) return;
    if (!element || !tagName || ['script', 'style', 'noscript', 'button'].includes(tagName)) return;
    
    const style = window.getComputedStyle(element);
    if (style.display === 'none' || style.visibility === 'hidden') return;
    
    processedElements.add(element);

    if (tagName === 'h1') {
      const text = element.textContent.trim();
      if (text) sections.push(new Paragraph({ 
        children: [new TextRun({ text, font: 'Arial', size: 32, bold: true })],
        spacing: { before: 400, after: 200 }
      }));
    } else if (tagName === 'h2') {
      const text = element.textContent.trim();
      if (text) sections.push(new Paragraph({ 
        children: [new TextRun({ text, font: 'Arial', size: 26, bold: true })],
        spacing: { before: 300, after: 200 }
      }));
    } else if (tagName === 'h3') {
      const text = element.textContent.trim();
      if (text) sections.push(new Paragraph({ 
        children: [new TextRun({ text, font: 'Arial', size: 24, bold: true })],
        spacing: { before: 200, after: 100 }
      }));
    } else if (tagName === 'h4') {
      const text = element.textContent.trim();
      if (text) sections.push(new Paragraph({ 
        children: [new TextRun({ text, font: 'Arial', size: 22, bold: true })],
        spacing: { before: 200, after: 100 }
      }));
    } else if (tagName === 'p') {
      const text = element.textContent.trim();
      if (text && text.length > 0 && text.length < 5000) {
        sections.push(new Paragraph({ 
          children: [new TextRun({ text, font: 'Arial', size: 22 })],
          spacing: { after: 100 }
        }));
      }
    } else if (tagName === 'ul' || tagName === 'ol') {
      // Handle lists
      const listItems = element.querySelectorAll('li');
      listItems.forEach((li, index) => {
        const text = li.textContent.trim();
        if (text) {
          sections.push(new Paragraph({
            children: [new TextRun({ text, font: 'Arial', size: 22 })],
            bullet: tagName === 'ul' ? { level: 0 } : undefined,
            numbering: tagName === 'ol' ? { reference: 'default-numbering', level: 0 } : undefined,
            spacing: { after: 50 }
          }));
        }
      });
    } else if (tagName === 'table') {
      const tableData = extractTableData(element);
      if (tableData?.length > 0) {
        const docxTable = createDocxTable(tableData);
        if (docxTable) {
          sections.push(docxTable);
          sections.push(new Paragraph({ text: '', spacing: { after: 200 } }));
        }
      }
    } else if (tagName === 'div' || tagName === 'section' || tagName === 'article') {
      // Check for BigValue component
      if (element.classList?.contains('big-value') || element.querySelector('[class*="big-value"]')) {
        const titleEl = element.querySelector('[class*="title"]');
        const valueEl = element.querySelector('[class*="number"], [class*="value"]');
        
        const title = titleEl?.textContent?.trim() || '';
        const value = valueEl?.textContent?.trim() || '';
        
        if (title && value) {
          sections.push(new Paragraph({
            children: [
              new TextRun({ text: title + ': ', font: 'Arial', size: 22, bold: true }),
              new TextRun({ text: value, font: 'Arial', size: 28, bold: true, color: '2563EB' })
            ],
            spacing: { after: 150 }
          }));
        }
        return;
      }
      
      const directCanvas = Array.from(element.children).find(child => child.tagName === 'CANVAS');
      if (includeCharts && directCanvas) {
        await captureChart(element, sections, processedElements);
        return;
      }
      
      const directTable = Array.from(element.children).find(child => child.tagName === 'TABLE');
      if (directTable && !processedElements.has(directTable)) {
        const tableData = extractTableData(directTable);
        if (tableData?.length > 0) {
          const docxTable = createDocxTable(tableData);
          if (docxTable) {
            sections.push(docxTable);
            sections.push(new Paragraph({ children: [new TextRun({ text: '', font: 'Arial' })], spacing: { after: 200 } }));
          }
        }
        processedElements.add(directTable);
        return;
      }
      
      for (const child of Array.from(element.children)) {
        await processElement(child, sections, processedElements);
      }
    }
  }

  async function captureChart(chartContainer, sections, processedElements) {
    try {
      const canvas = chartContainer.querySelector('canvas');
      if (!canvas || processedElements.has(canvas)) return;
      
      processedElements.add(canvas);
      processedElements.add(chartContainer);
      
      const titleEl = chartContainer.querySelector('[class*="title"]');
      const chartTitle = titleEl?.textContent?.trim() || '';
      
      if (chartTitle) {
        sections.push(new Paragraph({ 
          children: [new TextRun({ 
            text: chartTitle, 
            font: 'Arial', 
            size: 22, 
            bold: true 
          })],
          spacing: { before: 200, after: 100 }
        }));
      }
      
      const capturedCanvas = await html2canvas(canvas, {
        backgroundColor: '#ffffff',
        scale: 2,
        logging: false,
        useCORS: true
      });
      
      const imageData = capturedCanvas.toDataURL('image/png');
      const base64Data = imageData.split(',')[1];
      
      const maxWidth = 550;
      const aspectRatio = capturedCanvas.height / capturedCanvas.width;
      const width = Math.min(capturedCanvas.width, maxWidth);
      const height = width * aspectRatio;
      
      sections.push(new Paragraph({
        children: [
          new ImageRun({
            data: Uint8Array.from(atob(base64Data), c => c.charCodeAt(0)),
            transformation: { width, height }
          })
        ],
        spacing: { after: 200 }
      }));
    } catch (error) {
      console.warn('Failed to capture chart:', error);
    }
  }

  function extractTableData(tableElement) {
    const rows = [];
    const allRows = Array.from(tableElement.querySelectorAll('tr'));
    if (allRows.length === 0) return rows;
    
    for (let i = 0; i < Math.min(allRows.length, maxTableRows + 1); i++) {
      const row = allRows[i];
      const cells = Array.from(row.querySelectorAll('td, th'));
      if (cells.length === 0) continue;
      
      const cellData = cells.map(cell => {
        let text = cell.innerText || cell.textContent || '';
        return text.replace(/\s+/g, ' ').trim();
      });
      
      if (cellData.some(c => c && c.length > 0)) {
        rows.push(cellData);
      }
    }
    return rows;
  }

  function createDocxTable(data) {
    if (!data || data.length === 0) return null;
    
    try {
      const normalizedData = data.map(row => {
        if (!Array.isArray(row)) return [];
        return row.map(cell => String(cell || '').substring(0, 1000));
      }).filter(row => row.length > 0);
      
      if (normalizedData.length === 0) return null;
      
      const maxCols = Math.max(...normalizedData.map(row => row.length));
      const paddedData = normalizedData.map(row => {
        const padded = [...row];
        while (padded.length < maxCols) padded.push('');
        return padded.slice(0, maxCols);
      });
      
      const rows = paddedData.map((rowData, rowIndex) => {
        const isHeader = rowIndex === 0;
        const cells = rowData.map(cellText => {
          return new TableCell({
            children: [new Paragraph({ 
              children: [new TextRun({ 
                text: cellText || '', 
                font: 'Arial',
                size: 22,
                bold: isHeader,
                color: isHeader ? 'FFFFFF' : '000000'
              })],
              alignment: isHeader ? AlignmentType.CENTER : AlignmentType.LEFT
            })],
            shading: isHeader ? { 
              fill: '304C89'
            } : (rowIndex % 2 === 0 ? { fill: 'F9FAFB' } : { fill: 'FFFFFF' }),
            margins: {
              top: 100,
              bottom: 100,
              left: 100,
              right: 100
            },
            borders: {
              top: { style: BorderStyle.SINGLE, size: 1, color: 'E5E7EB' },
              bottom: { style: BorderStyle.SINGLE, size: 1, color: 'E5E7EB' },
              left: { style: BorderStyle.SINGLE, size: 1, color: 'E5E7EB' },
              right: { style: BorderStyle.SINGLE, size: 1, color: 'E5E7EB' }
            }
          });
        });
        return new TableRow({ 
          children: cells,
          height: { value: 400, rule: 'atLeast' }
        });
      });

      return new Table({
        rows,
        width: { size: 9000, type: WidthType.DXA },
        layout: 'autofit',
        margins: {
          top: 200,
          bottom: 200
        }
      });
    } catch (error) {
      console.error('Error creating table:', error);
      return null;
    }
  }
</script>

<button 
  bind:this={buttonElement}
  on:click={exportToWord}
  disabled={isExporting}
  class="export-button"
  title="Export to Word"
  style="display: none;"
>
  {#if isExporting}
    <span class="spinner"></span>
  {:else}
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
      <polyline points="7 10 12 15 17 10"></polyline>
      <line x1="12" y1="15" x2="12" y2="3"></line>
    </svg>
    <span class="button-text">Word</span>
  {/if}
</button>

<style>
  .export-button {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.375rem 0.75rem;
    background: transparent;
    border: 1px solid transparent;
    border-radius: 0.375rem;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
    color: currentColor;
    transition: all 0.15s;
    white-space: nowrap;
  }

  .export-button:hover:not(:disabled) {
    background-color: rgba(0, 0, 0, 0.05);
  }

  .export-button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  .export-button svg {
    flex-shrink: 0;
    width: 16px;
    height: 16px;
  }

  .button-text {
    font-size: 0.875rem;
  }

  .spinner {
    width: 14px;
    height: 14px;
    border: 2px solid currentColor;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.6s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  /* Dark mode support */
  :global(.dark) .export-button:hover:not(:disabled) {
    background-color: rgba(255, 255, 255, 0.1);
  }
</style>
