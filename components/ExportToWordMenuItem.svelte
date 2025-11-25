<script>
  import { Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell, WidthType, ImageRun } from 'docx';
  import { saveAs } from 'file-saver';
  import html2canvas from 'html2canvas';
  import { page } from '$app/stores';

  export let includeCharts = true;
  export let maxTableRows = 100;

  let isExporting = false;

  async function exportToWord() {
    if (isExporting) return;
    
    isExporting = true;
    
    try {
      // Get page title from the page data or h1
      const h1 = document.querySelector('main h1');
      const pageTitle = h1?.textContent?.trim() || 'Report';
      
      // Wait a moment for any lazy-loaded content
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const sections = [];
      
      // Add title
      sections.push(
        new Paragraph({
          text: pageTitle,
          heading: HeadingLevel.HEADING_1,
          spacing: { after: 400 }
        })
      );

      // Get main content
      const main = document.querySelector('main');
      if (!main) {
        throw new Error('Could not find main content area');
      }

      // Scroll to bottom to ensure all content is loaded
      const scrollableElements = main.querySelectorAll('[class*="scroll"], [class*="table"]');
      for (const el of scrollableElements) {
        if (el.scrollHeight > el.clientHeight) {
          el.scrollTop = el.scrollHeight;
          await new Promise(resolve => setTimeout(resolve, 100));
          el.scrollTop = 0;
        }
      }

      // Process content
      const children = Array.from(main.children);
      const processedElements = new Set();
      
      for (const child of children) {
        await processElement(child, sections, processedElements);
      }

      if (sections.length === 1) {
        sections.push(new Paragraph({ text: 'No content found to export.' }));
      }

      // Filter out any null/undefined sections
      const validSections = sections.filter(s => s != null);
      
      if (validSections.length === 0) {
        throw new Error('No valid content to export');
      }

      // Create the document
      const doc = new Document({
        sections: [{
          properties: {
            page: {
              margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
            }
          },
          children: validSections
        }]
      });

      const blob = await Packer.toBlob(doc);
      const fileName = `${pageTitle.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${new Date().toISOString().split('T')[0]}.docx`;
      saveAs(blob, fileName);
      
    } catch (error) {
      console.error('Error exporting to Word:', error);
      alert('Failed to export to Word. Please try again.\n\nError: ' + error.message);
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
      if (text) {
        sections.push(new Paragraph({
          text: text,
          heading: HeadingLevel.HEADING_1,
          spacing: { before: 400, after: 200 }
        }));
      }
    } else if (tagName === 'h2') {
      const text = element.textContent.trim();
      if (text) {
        sections.push(new Paragraph({
          text: text,
          heading: HeadingLevel.HEADING_2,
          spacing: { before: 300, after: 200 }
        }));
      }
    } else if (tagName === 'h3') {
      const text = element.textContent.trim();
      if (text) {
        sections.push(new Paragraph({
          text: text,
          heading: HeadingLevel.HEADING_3,
          spacing: { before: 200, after: 100 }
        }));
      }
    } else if (tagName === 'p') {
      const text = element.textContent.trim();
      if (text && text.length > 0 && text.length < 5000) {
        sections.push(new Paragraph({
          text: text,
          spacing: { after: 100 }
        }));
      }
    } else if (tagName === 'table') {
      const tableData = extractTableData(element);
      if (tableData && tableData.length > 0) {
        const docxTable = createDocxTable(tableData);
        if (docxTable) {
          sections.push(docxTable);
          sections.push(new Paragraph({ text: '', spacing: { after: 200 } }));
        }
      }
    } else if (tagName === 'div' || tagName === 'section') {
      const directCanvas = Array.from(element.children).find(child => child.tagName === 'CANVAS');
      if (includeCharts && directCanvas) {
        await captureChart(element, sections, processedElements);
        return;
      }
      
      const directTable = Array.from(element.children).find(child => child.tagName === 'TABLE');
      if (directTable && !processedElements.has(directTable)) {
        const tableData = extractTableData(directTable);
        if (tableData && tableData.length > 0) {
          const docxTable = createDocxTable(tableData);
          if (docxTable) {
            sections.push(docxTable);
            sections.push(new Paragraph({ text: '', spacing: { after: 200 } }));
          }
        }
        processedElements.add(directTable);
        return;
      }
      
      const children = Array.from(element.children);
      for (const child of children) {
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
          text: chartTitle,
          bold: true,
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
            transformation: { width: width, height: height }
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
        const cells = rowData.map(cellText => {
          return new TableCell({
            children: [new Paragraph({
              text: cellText || '',
              bold: rowIndex === 0
            })],
            shading: rowIndex === 0 ? { fill: 'E5E7EB' } : undefined
          });
        });
        
        return new TableRow({ children: cells });
      });

      return new Table({
        rows: rows,
        width: { size: 100, type: WidthType.PERCENTAGE }
      });
    } catch (error) {
      console.error('Error creating table:', error);
      return null;
    }
  }
</script>

<button 
  on:click={exportToWord}
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
