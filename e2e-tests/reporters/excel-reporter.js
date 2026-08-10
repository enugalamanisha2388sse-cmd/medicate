const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

/**
 * Custom WDIO Excel Reporter
 * Generates a detailed .xlsx report after test execution
 */
class ExcelReporter {
  constructor(options) {
    this.options = options;
    this.outputDir = options.outputDir || './reports';
    this.outputFile = options.outputFile || 'e2e-report.xlsx';
    this.testResults = [];
    this.suiteStats = {};
    this.startTime = new Date();
  }

  onTestPass(test) {
    this._recordResult(test, 'PASSED');
  }

  onTestFail(test) {
    this._recordResult(test, 'FAILED');
  }

  onTestSkip(test) {
    this._recordResult(test, 'SKIPPED');
  }

  _recordResult(test, status) {
    const suite = test.parent || 'Unknown Suite';
    this.testResults.push({
      suite,
      title: test.title,
      status,
      duration: test.duration ? `${(test.duration / 1000).toFixed(2)}s` : 'N/A',
      error: test.error ? test.error.message : '',
      timestamp: new Date().toISOString(),
    });

    if (!this.suiteStats[suite]) {
      this.suiteStats[suite] = { passed: 0, failed: 0, skipped: 0 };
    }
    this.suiteStats[suite][status.toLowerCase()]++;
  }

  async onComplete() {
    await this._generateExcelReport();
  }

  async _generateExcelReport() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Medicate Appium E2E';
    workbook.created = new Date();

    // ─────────────────────────────────────────────────
    // SHEET 1: Executive Summary
    // ─────────────────────────────────────────────────
    const summarySheet = workbook.addWorksheet('📊 Summary', {
      properties: { tabColor: { argb: '4472C4' } },
    });

    const endTime = new Date();
    const totalPassed = this.testResults.filter((r) => r.status === 'PASSED').length;
    const totalFailed = this.testResults.filter((r) => r.status === 'FAILED').length;
    const totalSkipped = this.testResults.filter((r) => r.status === 'SKIPPED').length;
    const total = this.testResults.length;
    const passRate = total > 0 ? ((totalPassed / total) * 100).toFixed(1) : '0';

    // Header banner
    summarySheet.mergeCells('A1:F1');
    const titleCell = summarySheet.getCell('A1');
    titleCell.value = '🏥 MEDICATE APP — E2E TEST REPORT';
    titleCell.font = { name: 'Calibri', size: 18, bold: true, color: { argb: 'FFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A3C6E' } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
    summarySheet.getRow(1).height = 40;

    // Sub header
    summarySheet.mergeCells('A2:F2');
    const subTitle = summarySheet.getCell('A2');
    subTitle.value = `Generated: ${endTime.toLocaleString()} | Platform: ${process.env.PLATFORM || 'Android'} | Build: ${process.env.BUILD_NUMBER || 'local'}`;
    subTitle.font = { name: 'Calibri', size: 11, color: { argb: 'FFFFFF' } };
    subTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2E5FA3' } };
    subTitle.alignment = { horizontal: 'center', vertical: 'middle' };
    summarySheet.getRow(2).height = 22;

    // Stats cards row
    const statsRow = 4;
    const statCards = [
      { label: 'Total Tests', value: total, color: '2E5FA3', textColor: 'FFFFFF' },
      { label: '✅ Passed', value: totalPassed, color: '1E8449', textColor: 'FFFFFF' },
      { label: '❌ Failed', value: totalFailed, color: 'C0392B', textColor: 'FFFFFF' },
      { label: '⏭ Skipped', value: totalSkipped, color: 'D4AC0D', textColor: 'FFFFFF' },
      { label: 'Pass Rate', value: `${passRate}%`, color: passRate >= 80 ? '1E8449' : 'C0392B', textColor: 'FFFFFF' },
      { label: 'Duration', value: `${((endTime - this.startTime) / 1000).toFixed(1)}s`, color: '7D3C98', textColor: 'FFFFFF' },
    ];

    statCards.forEach((card, i) => {
      const col = String.fromCharCode(65 + i); // A, B, C...
      const labelCell = summarySheet.getCell(`${col}${statsRow}`);
      const valueCell = summarySheet.getCell(`${col}${statsRow + 1}`);

      labelCell.value = card.label;
      labelCell.font = { name: 'Calibri', size: 10, bold: true, color: { argb: card.textColor } };
      labelCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: card.color } };
      labelCell.alignment = { horizontal: 'center', vertical: 'middle' };
      summarySheet.getRow(statsRow).height = 25;

      valueCell.value = card.value;
      valueCell.font = { name: 'Calibri', size: 20, bold: true, color: { argb: card.color } };
      valueCell.alignment = { horizontal: 'center', vertical: 'middle' };
      summarySheet.getRow(statsRow + 1).height = 45;
    });

    summarySheet.columns = [
      { width: 18 }, { width: 14 }, { width: 14 },
      { width: 14 }, { width: 14 }, { width: 14 },
    ];

    // Suite breakdown table
    const suiteHeaderRow = statsRow + 3;
    summarySheet.mergeCells(`A${suiteHeaderRow}:F${suiteHeaderRow}`);
    const suiteHeader = summarySheet.getCell(`A${suiteHeaderRow}`);
    suiteHeader.value = 'TEST SUITE BREAKDOWN';
    suiteHeader.font = { name: 'Calibri', size: 12, bold: true, color: { argb: 'FFFFFF' } };
    suiteHeader.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A3C6E' } };
    suiteHeader.alignment = { horizontal: 'center' };
    summarySheet.getRow(suiteHeaderRow).height = 22;

    const suiteColHeaders = ['Suite Name', 'Total', 'Passed', 'Failed', 'Skipped', 'Pass Rate'];
    const suiteColRow = suiteHeaderRow + 1;
    suiteColHeaders.forEach((h, i) => {
      const cell = summarySheet.getCell(suiteColRow, i + 1);
      cell.value = h;
      cell.font = { bold: true, color: { argb: 'FFFFFF' } };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2E5FA3' } };
      cell.alignment = { horizontal: 'center' };
    });

    let suiteDataRow = suiteColRow + 1;
    Object.entries(this.suiteStats).forEach(([suiteName, stats], idx) => {
      const suiteTotal = stats.passed + stats.failed + stats.skipped;
      const suitePassRate = suiteTotal > 0 ? ((stats.passed / suiteTotal) * 100).toFixed(1) : '0';
      const rowBg = idx % 2 === 0 ? 'EBF5FB' : 'FFFFFF';

      const rowData = [suiteName, suiteTotal, stats.passed, stats.failed, stats.skipped, `${suitePassRate}%`];
      rowData.forEach((val, i) => {
        const cell = summarySheet.getCell(suiteDataRow, i + 1);
        cell.value = val;
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: rowBg } };
        cell.alignment = { horizontal: i === 0 ? 'left' : 'center' };
        if (i === 3 && stats.failed > 0) {
          cell.font = { bold: true, color: { argb: 'C0392B' } };
        }
      });
      suiteDataRow++;
    });

    // ─────────────────────────────────────────────────
    // SHEET 2: Detailed Test Results
    // ─────────────────────────────────────────────────
    const detailSheet = workbook.addWorksheet('📋 Test Results', {
      properties: { tabColor: { argb: '1E8449' } },
    });

    detailSheet.mergeCells('A1:G1');
    const detailTitle = detailSheet.getCell('A1');
    detailTitle.value = 'DETAILED TEST RESULTS';
    detailTitle.font = { name: 'Calibri', size: 14, bold: true, color: { argb: 'FFFFFF' } };
    detailTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A3C6E' } };
    detailTitle.alignment = { horizontal: 'center', vertical: 'middle' };
    detailSheet.getRow(1).height = 30;

    const headers = ['#', 'Suite', 'Test Case', 'Status', 'Duration', 'Error Message', 'Timestamp'];
    const colWidths = [5, 28, 50, 12, 12, 45, 22];
    headers.forEach((h, i) => {
      const cell = detailSheet.getCell(2, i + 1);
      cell.value = h;
      cell.font = { bold: true, color: { argb: 'FFFFFF' } };
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2E5FA3' } };
      cell.alignment = { horizontal: 'center', vertical: 'middle', wrapText: true };
      detailSheet.getColumn(i + 1).width = colWidths[i];
    });
    detailSheet.getRow(2).height = 25;

    this.testResults.forEach((result, idx) => {
      const row = detailSheet.getRow(idx + 3);
      const rowBg = idx % 2 === 0 ? 'F2F3F4' : 'FFFFFF';
      const statusColor =
        result.status === 'PASSED' ? '1E8449' : result.status === 'FAILED' ? 'C0392B' : 'D4AC0D';

      const rowData = [
        idx + 1,
        result.suite,
        result.title,
        result.status,
        result.duration,
        result.error || '—',
        new Date(result.timestamp).toLocaleString(),
      ];

      rowData.forEach((val, i) => {
        const cell = row.getCell(i + 1);
        cell.value = val;
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: rowBg } };
        cell.alignment = { vertical: 'middle', wrapText: i === 2 || i === 5 };
        if (i === 3) {
          cell.font = { bold: true, color: { argb: statusColor } };
          cell.alignment = { horizontal: 'center', vertical: 'middle' };
        }
      });
      row.height = 22;
    });

    // Auto filter
    detailSheet.autoFilter = { from: 'A2', to: `G${this.testResults.length + 2}` };

    // ─────────────────────────────────────────────────
    // SHEET 3: Failed Tests (if any)
    // ─────────────────────────────────────────────────
    const failedTests = this.testResults.filter((r) => r.status === 'FAILED');
    if (failedTests.length > 0) {
      const failSheet = workbook.addWorksheet('❌ Failed Tests', {
        properties: { tabColor: { argb: 'C0392B' } },
      });

      failSheet.mergeCells('A1:E1');
      const failTitle = failSheet.getCell('A1');
      failTitle.value = `FAILED TESTS — Action Required (${failedTests.length} failures)`;
      failTitle.font = { name: 'Calibri', size: 13, bold: true, color: { argb: 'FFFFFF' } };
      failTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'C0392B' } };
      failTitle.alignment = { horizontal: 'center', vertical: 'middle' };
      failSheet.getRow(1).height = 30;

      ['Suite', 'Test Case', 'Duration', 'Error Message', 'Timestamp'].forEach((h, i) => {
        const cell = failSheet.getCell(2, i + 1);
        cell.value = h;
        cell.font = { bold: true, color: { argb: 'FFFFFF' } };
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '922B21' } };
        cell.alignment = { horizontal: 'center' };
      });
      failSheet.columns = [
        { width: 30 }, { width: 50 }, { width: 12 }, { width: 55 }, { width: 22 },
      ];

      failedTests.forEach((result, idx) => {
        const row = failSheet.getRow(idx + 3);
        [result.suite, result.title, result.duration, result.error || 'No message', new Date(result.timestamp).toLocaleString()].forEach(
          (val, i) => {
            const cell = row.getCell(i + 1);
            cell.value = val;
            cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: idx % 2 === 0 ? 'FDEDEC' : 'FFFFFF' } };
            cell.alignment = { vertical: 'middle', wrapText: true };
          }
        );
        row.height = 30;
      });
    }

    // Save workbook
    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
    }
    const outputPath = path.join(this.outputDir, this.outputFile);
    await workbook.xlsx.writeFile(outputPath);
    console.log(`\n📊 Excel report saved: ${outputPath}\n`);
  }
}

module.exports = ExcelReporter;
