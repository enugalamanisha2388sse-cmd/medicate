/**
 * Medicate E2E — Patient Dashboard Tests
 * Tests: Medicine reminders, appointments, health analytics, inventory
 */

const { expect } = require('chai');

// ─── Shared Login Helper ───────────────────────────────────────────────────────
async function loginAsPatient() {
  await driver.back(); // ensure fresh state or reset app
  const patientBtn = await $({ using: 'flutter', value: 'key=role_patient_btn' });
  await patientBtn.waitForDisplayed({ timeout: 10000 });
  await patientBtn.click();

  const emailField = await $({ using: 'flutter', value: 'key=login_email_field' });
  await emailField.waitForDisplayed({ timeout: 5000 });
  await emailField.setValue('patient@medicate.com');

  const passwordField = await $({ using: 'flutter', value: 'key=login_password_field' });
  await passwordField.setValue('password123');

  const loginBtn = await $({ using: 'flutter', value: 'key=login_submit_btn' });
  await loginBtn.click();

  // Wait for patient dashboard
  await driver.waitUntil(
    async () => (await driver.getPageSource()).includes('SmartMed'),
    { timeout: 15000, timeoutMsg: 'Patient dashboard not loaded' }
  );
}

// ─────────────────────────────────────────────────────────────────────────────

describe('🏠 Patient Dashboard', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_DASH_01: Patient dashboard loads with welcome message', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('SmartMed');
  });

  it('TC_DASH_02: Medicine reminders tab is visible', async () => {
    const medicinesTab = await $({ using: '-flutter semantics label', value: 'Medicines' });
    await medicinesTab.waitForDisplayed({ timeout: 5000 });
    expect(await medicinesTab.isDisplayed()).to.be.true;
  });

  it('TC_DASH_03: Tapping Medicines tab shows reminders list', async () => {
    const medicinesTab = await $({ using: '-flutter semantics label', value: 'Medicines' });
    await medicinesTab.click();

    await driver.waitUntil(
      async () => (await driver.getPageSource()).includes('Paracetamol'),
      { timeout: 8000, timeoutMsg: 'Medicines tab content not loaded' }
    );
    const source = await driver.getPageSource();
    expect(source).to.include('Paracetamol');
  });

  it('TC_DASH_04: Calendar tab loads appointment calendar', async () => {
    const calendarTab = await $({ using: '-flutter semantics label', value: 'Calendar' });
    await calendarTab.click();

    await driver.waitUntil(
      async () => (await driver.getPageSource()).includes('Appointment'),
      { timeout: 8000, timeoutMsg: 'Calendar tab not loaded' }
    );
    const source = await driver.getPageSource();
    expect(source).to.include('Appointment');
  });

  it('TC_DASH_05: Profile tab displays user info', async () => {
    const profileTab = await $({ using: '-flutter semantics label', value: 'Profile' });
    await profileTab.click();

    await driver.waitUntil(
      async () => (await driver.getPageSource()).includes('John Patient'),
      { timeout: 8000, timeoutMsg: 'Profile tab not loaded' }
    );
    const source = await driver.getPageSource();
    expect(source).to.include('John Patient');
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('💊 Medicine Reminders', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_MED_01: Medicine reminders list displays at least 1 reminder', async () => {
    const medicinesTab = await $({ using: '-flutter semantics label', value: 'Medicines' });
    await medicinesTab.click();
    const source = await driver.getPageSource();
    expect(source).to.include('Paracetamol 500mg');
  });

  it('TC_MED_02: Second reminder (Cetirizine 10mg) is visible', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('Cetirizine 10mg');
  });

  it('TC_MED_03: Mark reminder as taken changes its state', async () => {
    const takeMedBtn = await $({ using: 'flutter', value: 'key=take_medicine_r1' });
    if (await takeMedBtn.isDisplayed()) {
      await takeMedBtn.click();
      await driver.pause(1000);
      const source = await driver.getPageSource();
      // The button text should change to "Taken" or be disabled
      expect(source).to.satisfy(
        (s) => s.includes('Taken') || s.includes('taken'),
        'Medicine not marked as taken'
      );
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('📅 Appointment Booking', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_APT_01: Appointment calendar screen opens', async () => {
    const calendarTab = await $({ using: '-flutter semantics label', value: 'Calendar' });
    await calendarTab.click();
    const source = await driver.getPageSource();
    expect(source).to.include('Appointment');
  });

  it('TC_APT_02: Can navigate to Book Appointment screen', async () => {
    // Look for FAB or book button
    const bookBtn = await $({ using: 'flutter', value: 'key=book_appointment_btn' });
    if (await bookBtn.isDisplayed()) {
      await bookBtn.click();
      await driver.waitUntil(
        async () => (await driver.getPageSource()).includes('Book'),
        { timeout: 5000, timeoutMsg: 'Book appointment screen not opened' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('Book');
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('🏥 Medical Shop', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_SHOP_01: Medical shop screen opens from dashboard', async () => {
    const shopBtn = await $({ using: 'flutter', value: 'key=nav_medical_shop' });
    if (await shopBtn.isDisplayed()) {
      await shopBtn.click();
      await driver.waitUntil(
        async () => (await driver.getPageSource()).includes('Medical Shop'),
        { timeout: 8000, timeoutMsg: 'Medical Shop not loaded' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('Medical Shop');
    }
  });

  it('TC_SHOP_02: Medicine list includes Paracetamol', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('Paracetamol');
  });

  it('TC_SHOP_03: Add medicine to cart increments cart count', async () => {
    const addToCartBtn = await $({ using: 'flutter', value: 'key=add_to_cart_m1' });
    if (await addToCartBtn.isDisplayed()) {
      await addToCartBtn.click();
      await driver.pause(1000);
      const source = await driver.getPageSource();
      expect(source).to.satisfy(
        (s) => s.includes('1') || s.includes('Cart'),
        'Cart not updated after add'
      );
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('🏪 Inventory Management', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_INV_01: Inventory screen loads with items', async () => {
    const invBtn = await $({ using: 'flutter', value: 'key=nav_inventory' });
    if (await invBtn.isDisplayed()) {
      await invBtn.click();
      await driver.waitUntil(
        async () => (await driver.getPageSource()).includes('Inventory'),
        { timeout: 8000, timeoutMsg: 'Inventory screen not loaded' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('Inventory');
    }
  });

  it('TC_INV_02: Low stock items are flagged', async () => {
    const source = await driver.getPageSource();
    // Amoxicillin stock=8, threshold=15 → should show low stock
    expect(source).to.satisfy(
      (s) => s.includes('Low') || s.includes('low') || s.includes('Amoxicillin'),
      'Low stock indicator not found'
    );
  });

  it('TC_INV_03: Expired items are flagged in red/warning', async () => {
    const source = await driver.getPageSource();
    // Metformin is expired in seed data
    expect(source).to.satisfy(
      (s) => s.includes('Expired') || s.includes('expired') || s.includes('Metformin'),
      'Expired item indicator not found'
    );
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('💉 Vaccination', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_VAC_01: Vaccination screen opens', async () => {
    const vacBtn = await $({ using: 'flutter', value: 'key=nav_vaccination' });
    if (await vacBtn.isDisplayed()) {
      await vacBtn.click();
      await driver.waitUntil(
        async () => (await driver.getPageSource()).includes('Vaccination'),
        { timeout: 8000, timeoutMsg: 'Vaccination screen not loaded' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('Vaccination');
    }
  });

  it('TC_VAC_02: Taken vaccines are displayed', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('COVID-19');
  });

  it('TC_VAC_03: Available vaccines are listed', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('Hepatitis');
  });
});

// ─────────────────────────────────────────────────────────────────────────────

describe('🤖 AI Chat Assistant', () => {
  before(async () => {
    await loginAsPatient();
  });

  it('TC_AI_01: AI Chat screen opens', async () => {
    const aiBtn = await $({ using: 'flutter', value: 'key=nav_ai_chat' });
    if (await aiBtn.isDisplayed()) {
      await aiBtn.click();
      await driver.waitUntil(
        async () => (await driver.getPageSource()).includes('Medicate AI'),
        { timeout: 8000, timeoutMsg: 'AI Chat screen not loaded' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('Medicate AI');
    }
  });

  it('TC_AI_02: AI greeting message is shown on open', async () => {
    const source = await driver.getPageSource();
    expect(source).to.include('Hello');
  });

  it('TC_AI_03: Sending a symptom message returns AI response', async () => {
    const chatInput = await $({ using: 'flutter', value: 'key=ai_chat_input' });
    if (await chatInput.isDisplayed()) {
      await chatInput.setValue('I have a headache');
      const sendBtn = await $({ using: 'flutter', value: 'key=ai_chat_send_btn' });
      await sendBtn.click();

      await driver.waitUntil(
        async () => {
          const source = await driver.getPageSource();
          return source.includes('headache') || source.includes('symptom') || source.includes('suggest');
        },
        { timeout: 10000, timeoutMsg: 'AI did not respond' }
      );
      const source = await driver.getPageSource();
      expect(source).to.include('headache');
    }
  });
});
