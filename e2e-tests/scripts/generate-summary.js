const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

const reportsDir = './downloaded-reports';
const files = fs.existsSync(reportsDir)
  ? fs.readdirSync(reportsDir).filter((f) => f.endsWith('.xlsx'))
  : [];

async function main() {
  let summary = '';

  if (files.length === 0) {
    summary = [
      '## 🏥 Medicate E2E Test Report',
      '',
      '> ⚠️ No Excel report found. Tests may have failed to run.',
      '',
      `**Build:** #${process.env.BUILD_NUMBER || 'unknown'}`,
      `**Branch:** ${process.env.BRANCH_NAME || 'unknown'}`,
    ].join('\n');
  } else {
    const reportFile = path.join(reportsDir, files[0]);
    const workbook = new ExcelJS.Workbook();

    try {
      await workbook.xlsx.readFile(reportFile);
      const sheet = workbook.getWorksheet('📊 Summary') || workbook.worksheets[0];
      const rows = [];
      sheet.eachRow((row) => rows.push(row.values));

      const valRow = rows[6] || [];

      summary = [
        `## 🏥 Medicate E2E Test Report — Build #${process.env.BUILD_NUMBER || 'unknown'}`,
        '',
        '| Metric | Value |',
        '|--------|-------|',
        `| 🔢 Total Tests | ${valRow[1] || 'N/A'} |`,
        `| ✅ Passed | ${valRow[2] || 'N/A'} |`,
        `| ❌ Failed | ${valRow[3] || 'N/A'} |`,
        `| ⏭ Skipped | ${valRow[4] || 'N/A'} |`,
        `| 📈 Pass Rate | ${valRow[5] || 'N/A'} |`,
        `| ⏱ Duration | ${valRow[6] || 'N/A'} |`,
        '',
        `**Branch:** \`${process.env.BRANCH_NAME || 'unknown'}\``,
        `**Platform:** \`${process.env.PLATFORM || 'android'}\``,
        `**Triggered by:** \`${process.env.TRIGGERED_BY || 'unknown'}\``,
        '',
        `📥 [Download Full Excel Report](https://github.com/${process.env.REPO}/actions/runs/${process.env.RUN_ID})`,
      ].join('\n');
    } catch (err) {
      summary = `## 🏥 Medicate E2E Report\n\n> ❌ Could not parse Excel report: ${err.message}\n`;
    }
  }

  fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY || '/dev/null', summary + '\n');
  console.log('✅ Summary written to GitHub Step Summary');
}

main().catch((err) => {
  console.error('Error generating summary:', err);
  process.exit(1);
});
