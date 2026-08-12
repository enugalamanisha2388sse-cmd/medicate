'use strict';
const fs   = require('fs');
const path = require('path');

// ExcelJS is optional — graceful fallback if not installed
let ExcelJS;
try { ExcelJS = require('exceljs'); } catch (_) { ExcelJS = null; }

// ─── config ────────────────────────────────────────────────────────────────
const reportsDir     = path.resolve(__dirname, '..', '..', 'downloaded-reports');
const summaryFile    = process.env.GITHUB_STEP_SUMMARY;   // absolute path set by runner
const BUILD_NUMBER   = process.env.BUILD_NUMBER   || 'unknown';
const BRANCH_NAME    = process.env.BRANCH_NAME    || 'unknown';
const PLATFORM       = process.env.PLATFORM       || 'android';
const TRIGGERED_BY   = process.env.TRIGGERED_BY   || 'unknown';
const REPO           = process.env.REPO           || '';
const RUN_ID         = process.env.RUN_ID         || '';

// ─── helpers ────────────────────────────────────────────────────────────────
function writeSummary(text) {
  if (summaryFile) {
    try { fs.appendFileSync(summaryFile, text + '\n'); } catch (_) {}
  }
  console.log('─'.repeat(60));
  console.log(text);
  console.log('─'.repeat(60));
}

function noReportSummary() {
  return [
    '## 🏥 Medicate E2E Test Report',
    '',
    '> ⚠️ No Excel report found. Tests may not have run yet.',
    '',
    `**Build:** \`#${BUILD_NUMBER}\``,
    `**Branch:** \`${BRANCH_NAME}\``,
    `**Platform:** \`${PLATFORM}\``,
    `**Triggered by:** \`${TRIGGERED_BY}\``,
  ].join('\n');
}

async function parseExcelReport(filePath) {
  if (!ExcelJS) return null;
  try {
    const wb    = new ExcelJS.Workbook();
    await wb.xlsx.readFile(filePath);
    const sheet = wb.getWorksheet('📊 Executive Summary')
                || wb.getWorksheet('Summary')
                || wb.worksheets[0];
    if (!sheet) return null;

    const rows = [];
    sheet.eachRow((row) => rows.push(row.values));

    // Try to find the KPI row (usually row 6 or 7 with numeric values)
    let kpiRow = null;
    for (const row of rows) {
      if (row && typeof row[2] === 'number' && row[2] > 0) {
        kpiRow = row;
        break;
      }
    }

    return kpiRow ? {
      total:    kpiRow[1] || kpiRow[2] || 'N/A',
      passed:   kpiRow[2] || kpiRow[3] || 'N/A',
      failed:   kpiRow[3] || kpiRow[4] || 'N/A',
      skipped:  kpiRow[4] || kpiRow[5] || 'N/A',
      passRate: kpiRow[5] || kpiRow[6] || 'N/A',
      duration: kpiRow[6] || kpiRow[7] || 'N/A',
    } : null;
  } catch (err) {
    console.warn(`⚠️  Could not parse Excel report: ${err.message}`);
    return null;
  }
}

// ─── main ───────────────────────────────────────────────────────────────────
async function main() {
  console.log('📊 Generating GitHub Step Summary...');
  console.log(`   Reports dir : ${reportsDir}`);
  console.log(`   Summary file: ${summaryFile || '(not set — local run)'}`);

  // Find excel reports
  let xlsxFiles = [];
  if (fs.existsSync(reportsDir)) {
    xlsxFiles = fs.readdirSync(reportsDir).filter((f) => f.endsWith('.xlsx'));
  }

  let summaryText;

  if (xlsxFiles.length === 0) {
    summaryText = noReportSummary();
  } else {
    const reportFile = path.join(reportsDir, xlsxFiles[0]);
    console.log(`   Found report: ${path.basename(reportFile)}`);
    const stats = await parseExcelReport(reportFile);

    if (stats) {
      summaryText = [
        `## 🏥 Medicate E2E Test Report — Build #${BUILD_NUMBER}`,
        '',
        '| Metric | Value |',
        '|--------|-------|',
        `| 🔢 Total Tests | ${stats.total} |`,
        `| ✅ Passed      | ${stats.passed} |`,
        `| ❌ Failed      | ${stats.failed} |`,
        `| ⏭ Skipped     | ${stats.skipped} |`,
        `| 📈 Pass Rate   | ${stats.passRate} |`,
        `| ⏱ Duration    | ${stats.duration} |`,
        '',
        `**Branch:** \`${BRANCH_NAME}\``,
        `**Platform:** \`${PLATFORM}\``,
        `**Triggered by:** \`${TRIGGERED_BY}\``,
        '',
        REPO && RUN_ID
          ? `📥 [Download Full Excel Report](https://github.com/${REPO}/actions/runs/${RUN_ID})`
          : '',
      ].join('\n');
    } else {
      summaryText = [
        `## 🏥 Medicate E2E Test Report — Build #${BUILD_NUMBER}`,
        '',
        `> ✅ Excel report found: \`${path.basename(reportFile)}\``,
        '> Could not parse KPI data — open the artifact for full details.',
        '',
        `**Branch:** \`${BRANCH_NAME}\` | **Platform:** \`${PLATFORM}\``,
      ].join('\n');
    }
  }

  writeSummary(summaryText);
  console.log('✅ Summary written successfully');
}

main().catch((err) => {
  // Never fail CI just because summary generation failed
  console.error('⚠️  Summary generation error (non-fatal):', err.message);
  writeSummary(`## 🏥 Medicate E2E Report\n\n> ⚠️ Summary generation error: ${err.message}`);
  process.exit(0); // exit 0 — don't fail the CI pipeline
});
