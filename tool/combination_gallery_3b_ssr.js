const fs = require('fs');
const path = require('path');
const { fileURLToPath } = require('url');

const outputDir = process.argv[2] ?? '.dart_tool/combination-gallery-3b-ssr';
const onlyId = process.argv[3];
const config = JSON.parse(fs.readFileSync('.dart_tool/package_config.json', 'utf8'));
const graphify = config.packages.find((entry) => entry.name === 'graphify');
if (!graphify) throw new Error('Graphify package not found');
const root = fileURLToPath(graphify.rootUri);
const dartBundle = fs.readFileSync(path.join(root, 'lib/src/resources/lib/echarts.min.dart'), 'utf8');
const marker = 'const echartsMin = r"""';
const start = dartBundle.indexOf(marker) + marker.length;
const end = dartBundle.indexOf('""";', start);
if (start < marker.length || end < 0) throw new Error('ECharts bundle markers not found');
const bundlePath = path.resolve(outputDir, 'echarts.min.js');
fs.writeFileSync(bundlePath, dartBundle.slice(start, end));
const echarts = require(bundlePath);
const options = JSON.parse(fs.readFileSync(path.join(outputDir, 'options.json'), 'utf8'));
for (const [id, option] of Object.entries(options)) {
  if (onlyId && id !== onlyId) continue;
  const chart = echarts.init(null, null, { renderer: 'svg', ssr: true, width: 720, height: 420 });
  try {
    chart.setOption(option);
    const svg = chart.renderToSVGString();
    if (!svg.includes('<svg') || svg.length < 1000) throw new Error('empty SVG');
    fs.writeFileSync(path.join(outputDir, `${id}.svg`), svg);
    console.log(`${id}: ${svg.length} SVG bytes`);
  } catch (error) {
    console.error(`${id}: ${error.message}`);
    process.exitCode = 1;
    break;
  } finally {
    chart.dispose();
  }
}
