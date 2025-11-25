# Quick Start: Export to Word Feature

## What Was Added

A reusable component that exports Evidence pages to Microsoft Word (.docx) format.

## Files Created

1. **Component**: `components/ExportToWord.svelte` - The main export component
2. **Demo Page**: `pages/export-demo.md` - Example page showing the feature
3. **Documentation**: 
   - `EXPORT_TO_WORD_FEATURE.md` - Full feature documentation
   - `components/README.md` - Component reference guide

## Files Modified

1. **pages/funds/[id].md** - Added export button to fund detail pages
2. **pages/cashflows.md** - Added export button to cashflows page
3. **package.json** - Added dependencies: `docx`, `file-saver`, `html-to-docx`

## How to Use

### Add to Any Page

```markdown
<script>
  import ExportToWord from '$lib/ExportToWord.svelte';
</script>

# Your Page Title

<ExportToWord pageTitle="Your Page Title" />

<!-- Your page content -->
```

### Test It

1. Navigate to http://localhost:3000/dashboard-example/export-demo
2. Click the "Export to Word" button
3. A Word document will download automatically

## What Gets Exported

✅ Headings (H1-H4)
✅ Text and paragraphs  
✅ Data tables (up to 100 rows, with borders and styling)
✅ Key metrics (BigValue components)
✅ Charts (captured as PNG images)

❌ Interactive elements (dropdowns, filters)
❌ Real-time data updates

## Examples in Project

- **Fund Details**: `/funds/[id]` - Export individual fund reports
- **Cashflows**: `/cashflows` - Export cashflow analysis
- **Demo**: `/export-demo` - See all features in action

## Dependencies Added

```json
{
  "docx": "^9.5.1",
  "file-saver": "^2.0.5",
  "html-to-docx": "^1.8.0",
  "html2canvas": "^1.4.1"
}
```

## Advanced Options

### Customize Export Behavior

```markdown
<ExportToWord 
  pageTitle="My Report"
  includeCharts={true}
  maxTableRows={200}
/>
```

### Fast Export (No Charts)

For faster exports when you only need data:

```markdown
<ExportToWord 
  pageTitle="Data Export"
  includeCharts={false}
/>
```

## Next Steps

1. Test the export on different pages
2. Customize button styling if needed
3. Add export buttons to other pages as required
4. Consider adding PDF export in the future

## Support

See full documentation in `EXPORT_TO_WORD_FEATURE.md` for:
- Detailed usage examples
- Customization options
- Troubleshooting guide
- Future enhancement ideas
