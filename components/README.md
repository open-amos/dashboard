# Custom Components

## ExportToWord Component

A reusable Svelte component that exports Evidence pages to Microsoft Word (.docx) format.

### Quick Start

```markdown
<script>
  import ExportToWord from '$lib/ExportToWord.svelte';
</script>

<ExportToWord pageTitle="My Report" />
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `pageTitle` | string | 'Report' | Title for the exported document and filename |
| `buttonText` | string | 'Export to Word' | Text displayed on the button |
| `buttonClass` | string | 'btn btn-primary' | CSS classes for button styling |
| `includeCharts` | boolean | true | Whether to capture and include charts as images |
| `maxTableRows` | number | 100 | Maximum number of table rows to export |

### Examples

#### Basic Usage
```markdown
<ExportToWord pageTitle="Quarterly Report" />
```

#### Custom Button Text
```markdown
<ExportToWord 
  pageTitle="Financial Analysis" 
  buttonText="📊 Download Report"
/>
```

#### Custom Styling
```markdown
<ExportToWord 
  pageTitle="Dashboard Export"
  buttonText="Export"
  buttonClass="custom-btn-class"
/>
```

#### Fast Export (No Charts)
```markdown
<ExportToWord 
  pageTitle="Data Report"
  includeCharts={false}
/>
```

#### Large Tables
```markdown
<ExportToWord 
  pageTitle="Full Dataset"
  maxTableRows={500}
/>
```

### What Gets Exported

✅ **Included:**
- Headings (H1-H4)
- Paragraphs and text
- Tables (up to 100 rows by default, with borders and styling)
- BigValue metrics
- Charts (captured as PNG images)

❌ **Not Included:**
- Interactive elements (dropdowns, filters)
- Custom CSS styling
- Real-time data updates

### Technical Details

**Dependencies:**
- `docx` - Word document generation
- `file-saver` - Browser file download
- `html2canvas` - Chart image capture

**File Naming:**
```
{page_title}_{YYYY-MM-DD}.docx
```

**Performance:**
- Tables limited to 100 rows by default (configurable)
- Charts captured at 2x scale for quality
- Async export with status updates
- Error handling with user feedback

### Browser Compatibility

Works in all modern browsers that support:
- ES6+ JavaScript
- Blob API
- File download

### See Also

- [Full Documentation](../EXPORT_TO_WORD_FEATURE.md)
- [Demo Page](../pages/export-demo.md)
