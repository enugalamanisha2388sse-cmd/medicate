/**
 * Medicate E2E — Login & Role Selection Tests
 * Tests the authentication flow: Role → Login/Signup → Dashboard
 */

const { expect } = require('chai');

describe('🔐 Authentication Flow', () => {
  // ─── Helper Locators ───────────────────────────────────────────────────────
  const Selectors = {
    // Role Selection Screen
    patientBtn: { using: 'flutter', value: 'key=role_patient_btn' },
    doctorBtn: { using: 'flutter', value: 'key=role_doctor_btn' },
    adminBtn: { using: 'flutter', value: 'key=role_admin_btn' },

    // Login Screen
    emailField: { using: 'flutter', value: 'key=login_email_field' },
    passwordField: { using: 'flutter', value: 'key=login_password_field' },
    loginBtn: { using: 'flutter', value: 'key=login_submit_btn' },
    signupTab: { using: 'flutter', value: 'key=signup_tab_btn' },
    errorText: { using: 'flutter', value: 'key=login_error_text' },

    // Dashboard identifiers
    patientDashboardTitle: { using: '-flutter semantics label', value: 'SmartMed Portal' },
    doctorDashboardTitle: { using: '-flutter semantics label', value: 'Doctor Dashboard' },
  };

  // ─── Test Cases ────────────────────────────────────────────────────────────

  it('TC_AUTH_01: Role Selection screen displays all 3 role cards', async () => {
    const patientBtn = await $(Selectors.patientBtn);
    const doctorBtn = await $(Selectors.doctorBtn);
    const adminBtn = await $(Selectors.adminBtn);

    await expect(await patientBtn.isDisplayed()).to.be.true;
    await expect(await doctorBtn.isDisplayed()).to.be.true;
    await expect(await adminBtn.isDisplayed()).to.be.true;
  });

  it('TC_AUTH_02: Tap Patient role navigates to Login screen', async () => {
    const patientBtn = await $(Selectors.patientBtn);
    await patientBtn.click();
    const emailField = await $(Selectors.emailField);
    await emailField.waitForDisplayed({ timeout: 5000 });
    await expect(await emailField.isDisplayed()).to.be.true;
  });

  it('TC_AUTH_03: Patient login with valid credentials succeeds', async () => {
    const emailField = await $(Selectors.emailField);
    const passwordField = await $(Selectors.passwordField);
    const loginBtn = await $(Selectors.loginBtn);

    await emailField.setValue('patient@medicate.com');
    await passwordField.setValue('password123');
    await loginBtn.click();

    // Should navigate to patient dashboard
    const dashTitle = await $(Selectors.patientDashboardTitle);
    await dashTitle.waitForDisplayed({ timeout: 10000 });
    await expect(await dashTitle.isDisplayed()).to.be.true;
  });

  it('TC_AUTH_04: Login with wrong password shows error', async () => {
    // Navigate back to role selection and re-enter
    await driver.back();
    await driver.back();

    const patientBtn = await $(Selectors.patientBtn);
    await patientBtn.click();

    const emailField = await $(Selectors.emailField);
    const passwordField = await $(Selectors.passwordField);
    const loginBtn = await $(Selectors.loginBtn);

    await emailField.setValue('patient@medicate.com');
    await passwordField.setValue('wrongpassword');
    await loginBtn.click();

    const errorText = await $(Selectors.errorText);
    await errorText.waitForDisplayed({ timeout: 5000 });
    await expect(await errorText.isDisplayed()).to.be.true;
  });

  it('TC_AUTH_05: Doctor login with valid credentials succeeds', async () => {
    await driver.back();

    const doctorBtn = await $(Selectors.doctorBtn);
    await doctorBtn.click();

    const emailField = await $(Selectors.emailField);
    const passwordField = await $(Selectors.passwordField);
    const loginBtn = await $(Selectors.loginBtn);

    await emailField.setValue('doctor@medicate.com');
    await passwordField.setValue('password123');
    await loginBtn.click();

    const dashTitle = await $(Selectors.doctorDashboardTitle);
    await dashTitle.waitForDisplayed({ timeout: 10000 });
    await expect(await dashTitle.isDisplayed()).to.be.true;
  });

  it('TC_AUTH_06: Admin login with valid credentials succeeds', async () => {
    await driver.back();
    await driver.back();

    const adminBtn = await $(Selectors.adminBtn);
    await adminBtn.click();

    const emailField = await $(Selectors.emailField);
    const passwordField = await $(Selectors.passwordField);
    const loginBtn = await $(Selectors.loginBtn);

    await emailField.setValue('admin@medicate.com');
    await passwordField.setValue('password123');
    await loginBtn.click();

    await driver.waitUntil(
      async () => (await driver.getPageSource()).includes('Admin'),
      { timeout: 10000, timeoutMsg: 'Admin dashboard not loaded' }
    );
  });

  it('TC_AUTH_07: Empty email & password shows validation error', async () => {
    await driver.back();
    await driver.back();

    const patientBtn = await $(Selectors.patientBtn);
    await patientBtn.click();

    const loginBtn = await $(Selectors.loginBtn);
    await loginBtn.click();

    const errorText = await $(Selectors.errorText);
    await errorText.waitForDisplayed({ timeout: 5000 });
    await expect(await errorText.isDisplayed()).to.be.true;
  });
});
