<script>
  import { Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell, WidthType, ImageRun, BorderStyle } from 'docx';
  import { saveAs } from 'file-saver';
  import html2canvas from 'html2canvas';

  export let pageTitle = 'Report';
  export let buttonText = 'Export to Word';
  export let buttonClass = 'btn btn-primary';
  export let includeCharts = true;
  export let maxTableRows = 100;

  let isExporting = false;
  let exportStatus = '';

  async function exportToWord() {
    isExporting = true;
    exportStatus = 'Preparing export...';
    
    try {
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

      // Scroll to bottom to ensure all content is loaded (for virtual scrolling)
      const scrollableElements = main.querySelectorAll('[class*="scroll"], [class*="table"]');
      for (const el of scrollableElements) {
        if (el.scrollHeight > el.clientHeight) {
          el.scrollTop = el.scrollHeight;
          await new Promise(resolve => setTimeout(resolve, 100));
          el.scrollTop = 0;
        }
      }

      // Process direct children of main to maintain order and avoid duplicates
      const children = Array.from(main.children);
      
      for (const child of children) {
        await processElement(child, sections);
      }

      if (sections.length === 1) {
        sections.push(new Paragraph({ text: 'No content found to export.' }));
      }

      exportStatus = 'Generating Word document...';

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

      exportStatus = 'Saving file...';
      const blob = await Packer.toBlob(doc);
      const fileName = `${pageTitle.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_${new Date().toISOString().split('T')[0]}.docx`;
      saveAs(blob, fileName);
      
      exportStatus = 'Export complete!';
      setTimeout(() => { exportStatus = ''; }, 2000);
      
    } catch (error) {
      console.error('Error exporting to Word:', error);
      alert('Failed to export to Word. Please try again.\n\nError: ' + error.message);
      exportStatus = '';
    } finally {
      isExporting = false;
    }
  }

  async function processElement(element, sections, processedElements = new Set()) {
    const tagName = element.tagName?.toLowerCase();
    
    // Skip if already processed
    if (processedElements.has(element)) {
      return;
    }
    
    // Skip script, style, and hidden elements
    if (!element || !tagName || ['script', 'style', 'noscript', 'button'].includes(tagName)) {
      return;
    }
    
    // Check if element is visible
    const style = window.getComputedStyle(element);
    if (style.display === 'none' || style.visibility === 'hidden') {
      return;
    }

    // Mark as processed
    processedElements.add(element);

    // Headings
    if (tagName === 'h1') {
      const text = element.textContent.trim();
      if (text && text !== pageTitle) {
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
    } else if (tagName === 'h4') {
      const text = element.textContent.trim();
      if (text) {
        sections.push(new Paragraph({
          text: text,
          heading: HeadingLevel.HEADING_4,
          spacing: { before: 200, after: 100 }
        }));
      }
    }
    
    // Paragraphs
    else if (tagName === 'p') {
      const text = element.textContent.trim();
      if (text && text.length > 0 && text.length < 5000) {
        sections.push(new Paragraph({
          text: text,
          spacing: { after: 100 }
        }));
      }
    }
    
    // Tables - direct table element
    else if (tagName === 'table') {
      exportStatus = 'Extracting table data...';
      console.log('Found table element:', element);
      console.log('Table HTML:', element.outerHTML.substring(0, 500));
      
      const tableData = extractTableData(element);
      console.log('Extracted table data:', tableData);
      
      if (tableData && tableData.length > 0) {
        const docxTable = createDocxTable(tableData);
        if (docxTable) {
          sections.push(docxTable);
          sections.push(new Paragraph({ text: '', spacing: { after: 200 } }));
        }
      }
    }
    
    // Divs and sections - check for special content
    else if (tagName === 'div' || tagName === 'section') {
      // Check if this div directly contains a canvas (chart)
      const directCanvas = Array.from(element.children).find(child => child.tagName === 'CANVAS');
      if (includeCharts && directCanvas) {
        await captureChart(element, sections, processedElements);
        return;
      }
      
      // Check if this div contains a table
      const directTable = Array.from(element.children).find(child => child.tagName === 'TABLE');
      if (directTable && !processedElements.has(directTable)) {
        exportStatus = 'Extracting table data...';
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
      
      // Otherwise, process children
      const children = Array.from(element.children);
      for (const child of children) {
        await processElement(child, sections, processedElements);
      }
    }
    
    // Other container elements
    else if (['article', 'aside', 'header', 'footer', 'nav'].includes(tagName)) {
      const children = Array.from(element.children);
      for (const child of children) {
        await processElement(child, sections, processedElements);
      }
    }
  }

  async function captureChart(chartContainer, sections, processedElements) {
    try {
      // Find canvas
      const canvas = chartContainer.querySelector('canvas');
      if (!canvas || processedElements.has(canvas)) return;
      
      processedElements.add(canvas);
      processedElements.add(chartContainer);
      
      // Find title
      const titleEl = chartContainer.querySelector('[class*="title"]');
      const chartTitle = titleEl?.textContent?.trim() || '';
      
      if (chartTitle) {
        sections.push(new Paragraph({
          text: chartTitle,
          bold: true,
          spacing: { before: 200, after: 100 }
        }));
      }
      
      exportStatus = `Capturing chart: ${chartTitle || 'Untitled'}...`;
      
      // Capture chart
      const capturedCanvas = await html2canvas(canvas, {
        backgroundColor: '#ffffff',
        scale: 2,
        logging: false,
        useCORS: true
      });
      
      const imageData = capturedCanvas.toDataURL('image/png');
      const base64Data = imageData.split(',')[1];
      
      // Calculate dimensions
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
      sections.push(new Paragraph({
        text: '[Chart could not be captured]',
        italics: true,
        spacing: { after: 200 }
      }));
    }
  }

  function extractTableData(tableElement) {
    const rows = [];
    
    console.log('Extracting table data from:', tableElement);
    
    // Get ALL rows first
    const allRows = Array.from(tableElement.querySelectorAll('tr'));
    console.log('Total rows found:', allRows.length);
    
    if (allRows.length === 0) {
      console.log('No rows found in table');
      return rows;
    }
    
    // Process each row
    for (let i = 0; i < Math.min(allRows.length, maxTableRows + 1); i++) {
      const row = allRows[i];
      const cells = Array.from(row.querySelectorAll('td, th'));
      
      if (cells.length === 0) continue;
      
      const cellData = cells.map(cell => {
        // Get text content, handling nested elements
        let text = '';
        
        // Try innerText first (respects display:none)
        if (cell.innerText) {
          text = cell.innerText.trim();
        } else {
          text = cell.textContent.trim();
        }
        
        // Clean up whitespace
        text = text.replace(/\s+/g, ' ').trim();
        
        return text;
      });
      
      console.log(`Row ${i}:`, cellData);
      
      // Only add rows that have some content
      if (cellData.some(c => c && c.length > 0)) {
        rows.push(cellData);
      }
    }
    
    console.log('Total rows extracted:', rows.length);
    console.log('Extracted data:', rows);
    
    // Add notice if truncated
    if (allRows.length > maxTableRows + 1 && rows.length > 0) {
      const noticeRow = new Array(rows[0].length).fill('');
      noticeRow[0] = `... ${allRows.length - maxTableRows - 1} more rows`;
      rows.push(noticeRow);
    }
    
    return rows;
  }

  function createDocxTable(data) {
    if (!data || data.length === 0) {
      console.log('No data to create table');
      return null;
    }
    
    try {
      console.log('Creating table with data:', data);
      
      // Validate and normalize data
      const normalizedData = data.map((row, idx) => {
        if (!Array.isArray(row)) {
          console.log(`Row ${idx} is not an array:`, row);
          return [];
        }
        return row.map(cell => {
          const text = String(cell || '').substring(0, 1000);
          return text;
        });
      }).filter(row => row.length > 0);
      
      if (normalizedData.length === 0) {
        console.log('No valid rows after normalization');
        return null;
      }
      
      // Ensure all rows have same number of columns
      const maxCols = Math.max(...normalizedData.map(row => row.length));
      console.log('Max columns:', maxCols);
      
      const paddedData = normalizedData.map((row, idx) => {
        const padded = [...row];
        while (padded.length < maxCols) padded.push('');
        const result = padded.slice(0, maxCols);
        console.log(`Row ${idx} after padding:`, result);
        return result;
      });
      
      const rows = paddedData.map((rowData, rowIndex) => {
        const cells = rowData.map((cellText, cellIndex) => {
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

      console.log('Created table with', rows.length, 'rows');
      
      return new Table({
        rows: rows,
        width: { size: 100, type: WidthType.PERCENTAGE }
      });
    } catch (error) {
      console.error('Error creating table:', error, error.stack);
      return null;
    }
  }
</script>

<div class="export-container">
  <button 
    class={buttonClass}
    on:click={exportToWord}
    disabled={isExporting}
  >
    {#if isExporting}
      Exporting...
    {:else}
      {buttonText}
    {/if}
  </button>
  
  {#if exportStatus}
    <div class="export-status">{exportStatus}</div>
  {/if}
</div>

<style>
  .export-container {
    display: inline-flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  button {
    padding: 0.5rem 1rem;
    border-radius: 0.375rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    border: none;
    background-color: #3b82f6;
    color: white;
    font-size: 0.875rem;
  }

  button:hover:not(:disabled) {
    background-color: #2563eb;
  }

  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .export-status {
    font-size: 0.75rem;
    color: #6b7280;
    font-style: italic;
  }
</style>
