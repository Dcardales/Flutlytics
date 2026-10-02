// Run after: flutter test tool/financial_planning_ssr_export_test.dart
const fs = require('fs');
const path = require('path');
const { fileURLToPath } = require('url');

const config = JSON.parse(fs.readFileSync('.dart_tool/package_config.json', 'utf8'));
const graphify = config.packages.find((entry) => entry.name === 'graphify');
if (!graphify) throw new Error('Graphify package not found');
const root = fileURLToPath(graphify.rootUri);
const dartBundle = fs.readFileSync(path.join(root, 'lib/src/resources/lib/echarts.min.dart'), 'utf8');
const marker = 'const echartsMin = r"""';
const start = dartBundle.indexOf(marker) + marker.length;
const end = dartBundle.indexOf('""";', start);
if (start < marker.length || end < 0) throw new Error('ECharts bundle markers not found');
const bundlePath = path.resolve('.dart_tool/batch10-ssr/echarts.min.js');
fs.writeFileSync(bundlePath, dartBundle.slice(start, end));
const echarts = require(bundlePath);
const options = JSON.parse(fs.readFileSync('.dart_tool/batch10-ssr/options.json', 'utf8'));
for (const [id, option] of Object.entries(options)) {
  const chart = echarts.init(null, null, { renderer: 'svg', ssr: true, width: 320, height: 300 });
  chart.setOption(option);
  const svg = chart.renderToSVGString();
  if (!svg.includes('<svg') || svg.length < 1000) throw new Error(`${id}: empty SVG`);
  console.log(`${id}: ${svg.length} SVG bytes`);
  chart.dispose();
}
