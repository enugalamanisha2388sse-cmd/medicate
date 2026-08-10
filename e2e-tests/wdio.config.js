const path = require('path');

exports.config = {
  // ===================
  // Runner Configuration
  // ===================
  runner: 'local',
  port: 4723,

  // ==================
  // Specify Test Files
  // ==================
  specs: ['./tests/**/*.spec.js'],
  exclude: [],

  // ==================
  // Capabilities
  // ==================
  maxInstances: 1,
  capabilities: [
    {
      platformName: process.env.PLATFORM === 'ios' ? 'iOS' : 'Android',
      'appium:automationName': process.env.PLATFORM === 'ios' ? 'Flutter' : 'Flutter',
      'appium:deviceName': process.env.DEVICE_NAME || 'emulator-5554',
      'appium:app': path.resolve(
        process.env.PLATFORM === 'ios'
          ? '../medicate/build/ios/iphoneos/Runner.app'
          : '../medicate/build/app/outputs/flutter-apk/app-debug.apk'
      ),
      'appium:retryBackoffTime': 500,
      'appium:newCommandTimeout': 300,
      'appium:flutterElementWaitTimeout': 20000,
    },
  ],

  // ==================
  // Test Framework
  // ==================
  logLevel: 'info',
  bail: 0,
  waitforTimeout: 20000,
  connectionRetryTimeout: 120000,
  connectionRetryCount: 3,

  services: [
    [
      'appium',
      {
        command: 'appium',
        args: {
          relaxedSecurity: true,
          log: './logs/appium.log',
        },
      },
    ],
  ],

  framework: 'mocha',
  reporters: [
    'spec',
    [
      './reporters/excel-reporter.js',
      {
        outputDir: './reports',
        outputFile: `medicate-e2e-report-${new Date().toISOString().split('T')[0]}.xlsx`,
      },
    ],
  ],

  mochaOpts: {
    ui: 'bdd',
    timeout: 90000,
  },

  // ==================
  // Hooks
  // ==================
  onPrepare() {
    const fs = require('fs');
    ['./reports', './logs'].forEach((dir) => {
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    });
    console.log('\n🚀 Starting Medicate Appium E2E Test Suite...\n');
  },

  afterTest(test, context, { error, result, duration, passed }) {
    // Store test result globally for Excel reporter
    global.testResults = global.testResults || [];
    global.testResults.push({
      suite: test.parent,
      title: test.title,
      status: passed ? 'PASSED' : 'FAILED',
      duration: `${(duration / 1000).toFixed(2)}s`,
      error: error ? error.message : '',
      timestamp: new Date().toISOString(),
    });
  },

  onComplete() {
    console.log('\n✅ Tests completed! Excel report saved to ./reports/');
  },
};
