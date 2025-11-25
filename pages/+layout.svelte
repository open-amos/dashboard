<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	import { base } from '$app/paths';
	import ExportToWordButton from '$lib/ExportToWordButton.svelte';
	export let data;
</script>

<EvidenceDefaultLayout
	{data}
	logo={`${base}/amos.png`}
	neverShowQueries={true}
	hideTOC=true
	githubRepo="https://github.com/open-amos">
	<slot slot="content" />
</EvidenceDefaultLayout>

<ExportToWordButton />