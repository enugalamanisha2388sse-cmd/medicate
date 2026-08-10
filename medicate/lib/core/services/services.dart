import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

// ==========================================
// MODELS
// ==========================================

enum UserRole { patient, doctor, admin }

enum BluetoothDeviceType { watch, ring, none }
enum BluetoothConnectionStatus { disconnected, scanning, connecting, connected }

class BluetoothSensorDevice {
  final String id;
  final String name;
  final BluetoothDeviceType type;
  final int batteryLevel;
  final int signalStrength; // RSSI in dBm

  BluetoothSensorDevice({
    required this.id,
    required this.name,
    required this.type,
    this.batteryLevel = 85,
    this.signalStrength = -60,
  });
}

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final String bio;
  final String licenseNumber;
  final String specialty;
  final double rating;
  final double consultFee;
  final String hospitalId;
  final String hospitalName;
  final List<int> patientsThisWeek; // length 7, mon to sun

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '+1 (555) 000-0000',
    this.bio = 'No bio provided.',
    this.licenseNumber = 'N/A',
    this.specialty = 'General Practice',
    this.rating = 4.8,
    this.consultFee = 50.0,
    this.hospitalId = '',
    this.hospitalName = '',
    List<int>? patientsThisWeek,
  }) : this.patientsThisWeek = patientsThisWeek ?? [5, 8, 6, 7, 5, 2, 0];
}

class AppNotification {
  final String id;
  final String text;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

class VaccineRecord {
  final String id;
  final String name;
  final String status; // 'Taken', 'Scheduled', 'Available'
  final DateTime? date;

  VaccineRecord({
    required this.id,
    required this.name,
    required this.status,
    this.date,
  });
}

class Hospital {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String contact;
  int vacancy;
  final int totalBeds;

  Hospital({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.contact,
    required this.vacancy,
    required this.totalBeds,
  });

  Hospital copyWith({int? vacancy}) {
    return Hospital(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      contact: contact,
      vacancy: vacancy ?? this.vacancy,
      totalBeds: totalBeds,
    );
  }
}

class Medicine {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  int stock;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.stock,
  });

  Medicine copyWith({int? stock, double? price}) {
    return Medicine(
      id: id,
      name: name,
      category: category,
      price: price ?? this.price,
      description: description,
      stock: stock ?? this.stock,
    );
  }
}

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});
}

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String department;
  final DateTime dateTime;
  String status; // 'Pending', 'Approved', 'Cancelled', 'Completed'

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.department,
    required this.dateTime,
    this.status = 'Pending',
  });
}

class MedicineReminder {
  final String id;
  final String medicineName;
  final String dosage;
  final String time; // e.g., "08:00 AM"
  bool isTaken;

  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });
}

class SymptomLog {
  final String id;
  final String symptom;
  final double severity; // 1.0 to 10.0
  final DateTime timestamp;

  SymptomLog({
    required this.id,
    required this.symptom,
    required this.severity,
    required this.timestamp,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class Prescription {
  final String id;
  final String patientId;
  final String doctorName;
  final String medicineName;
  final String dosage;
  final DateTime date;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.medicineName,
    required this.dosage,
    required this.date,
  });
}

class LiveVehicle {
  final String id;
  final String type; // 'Ambulance' or 'Med-Drone'
  final String status; // 'Responding', 'Returning', 'Dispatched'
  double lat;
  double lng;
  final String targetHospital;

  LiveVehicle({
    required this.id,
    required this.type,
    required this.status,
    required this.lat,
    required this.lng,
    required this.targetHospital,
  });
}

// ==========================================
// NEW MODELS — SmartMed Premium
// ==========================================

class InventoryItem {
  final String id;
  final String name;
  final String category;
  int stock;
  final int threshold; // low stock alert below this
  final DateTime expiryDate;
  final String unit; // tablets, ml, capsules

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.threshold,
    required this.expiryDate,
    this.unit = 'tablets',
  });

  bool get isLowStock => stock <= threshold;
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
}

class VitalReading {
  final String id;
  final String type; // 'bp_systolic', 'bp_diastolic', 'heart_rate', 'temperature', 'spo2', 'weight'
  final double value;
  final String unit;
  final DateTime timestamp;
  final String? note;

  VitalReading({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.note,
  });
}

class HealthReport {
  final String id;
  final String title;
  final String type; // 'weekly', 'monthly'
  final DateTime date;
  final String summary;
  final Map<String, dynamic> data;

  HealthReport({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.summary,
    required this.data,
  });
}

// ==========================================
// CENTRAL STATE & SERVICE PROVIDER
// ==========================================

class PatientRecord {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String medicalHistory;
  final String allergies;

  PatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.allergies,
  });
}

class MedicateProvider with ChangeNotifier {
  MedicateProvider() {
    startRealTimeSimulation();
  }

  // Theme State
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    AppTheme.updateThemeMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Patient Records CRUD State
  final List<PatientRecord> _patients = [
    PatientRecord(id: 'p1', name: 'Alice Smith', age: 34, gender: 'Female', medicalHistory: 'Chronic Asthma, Migraine', allergies: 'Penicillin, Dust'),
    PatientRecord(id: 'p2', name: 'Robert Johnson', age: 45, gender: 'Male', medicalHistory: 'Type 2 Diabetes, Hypertension', allergies: 'Peanuts'),
    PatientRecord(id: 'p3', name: 'Emily Davis', age: 29, gender: 'Female', medicalHistory: 'Seasonal Rhinitis', allergies: 'Sulfonamides'),
  ];

  List<PatientRecord> get patients => _patients;

  void addPatient(String name, int age, String gender, String medicalHistory, String allergies) {
    _patients.add(PatientRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      allergies: allergies,
    ));
    addNotification("SUCCESS: Added patient record for $name.");
    notifyListeners();
  }

  void updatePatient(String id, String name, int age, String gender, String medicalHistory, String allergies) {
    final idx = _patients.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _patients[idx] = PatientRecord(
        id: id,
        name: name,
        age: age,
        gender: gender,
        medicalHistory: medicalHistory,
        allergies: allergies,
      );
      addNotification("SUCCESS: Updated patient record for $name.");
      notifyListeners();
    }
  }

  void deletePatient(String id) {
    final idx = _patients.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final name = _patients[idx].name;
      _patients.removeAt(idx);
      addNotification("WARNING: Deleted patient record for $name.");
      notifyListeners();
    }
  }

  // Drug Interaction Checker
  Map<String, String> checkDrugInteraction(String drugA, String drugB) {
    final da = drugA.trim().toLowerCase();
    final db = drugB.trim().toLowerCase();
    
    if ((da.contains('aspirin') && db.contains('ibuprofen')) || (da.contains('ibuprofen') && db.contains('aspirin'))) {
      return {
        'status': 'High Risk',
        'color': 'red',
        'details': 'Combining Aspirin and Ibuprofen can increase the risk of stomach ulcers and gastrointestinal bleeding. They should not be taken together without professional supervision.'
      };
    } else if ((da.contains('metformin') && db.contains('contrast')) || (da.contains('contrast') && db.contains('metformin'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Contrast dye used in imaging scans combined with Metformin can increase risks of lactic acidosis. Monitor kidney function.'
      };
    } else if ((da.contains('paracetamol') && db.contains('alcohol')) || (da.contains('alcohol') && db.contains('paracetamol'))) {
      return {
        'status': 'Moderate Risk',
        'color': 'orange',
        'details': 'Taking Paracetamol with regular alcohol use increases the risk of severe liver damage.'
      };
    } else if (da.isNotEmpty && db.isNotEmpty) {
      return {
        'status': 'No Known Interaction',
        'color': 'green',
        'details': 'No severe interactions found between $drugA and $drugB. However, always consult with a doctor for personalized medical advice.'
      };
    }
    return {
      'status': 'Select Drugs',
      'color': 'blue',
      'details': 'Enter or select two drugs to check for potential clinical interactions.'
    };
  }

  // OCR Prescription Scanner Mock
  bool _isOcrScanning = false;
  bool get isOcrScanning => _isOcrScanning;

  Future<void> runOcrPrescriptionScan(String filename) async {
    _isOcrScanning = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    final random = Random();
    final medList = ['Amoxicillin 250mg', 'Montelukast 10mg', 'Amlodipine 5mg', 'Atorvastatin 10mg'];
    final selectedMed = medList[random.nextInt(medList.length)];
    final selectedTime = random.nextBool() ? '08:00 AM' : '09:00 PM';
    
    addMedicineReminder(selectedMed, '1 tablet daily', selectedTime);
    addNotification("SUCCESS: OCR Scanner extracted '$selectedMed' prescription and created a reminder.");
    
    _isOcrScanning = false;
    notifyListeners();
  }
  // Databases (Simulating Firebase Storage)
  final List<UserAccount> _users = [
    UserAccount(
      id: '1', 
      name: 'John Patient', 
      email: 'patient@medicate.com', 
      password: 'password123', 
      role: UserRole.patient,
      phone: '+1 (555) 246-8101',
      bio: 'Regular patient since 2024. Hypertension management.',
    ),
    UserAccount(
      id: '2', 
      name: 'Dr. Sarah Connor', 
      email: 'doctor@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 123-9876',
      bio: 'Senior Cardiologist with 15+ years of diagnostic experience. Specializes in heart valve repairs and coronary artery diseases.',
      licenseNumber: 'MD-998877',
      specialty: 'Cardiology',
      rating: 4.9,
      consultFee: 500.0,
      hospitalId: 'h2',
      hospitalName: 'St. Jude Cardiac Institute',
      patientsThisWeek: [8, 12, 10, 14, 9, 4, 1],
    ),
    UserAccount(
      id: '3', 
      name: 'Elena Admin', 
      email: 'admin@medicate.com', 
      password: 'password123', 
      role: UserRole.admin,
      phone: '+1 (555) 555-1234',
      bio: 'Lead Operations Director for Central Medicate Hub.',
      licenseNumber: 'LIC-ADMIN-01',
    ),
    UserAccount(
      id: '4', 
      name: 'Dr. Reed Richards', 
      email: 'reed@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 234-5678',
      bio: 'Director of Advanced Medical Diagnostics. Developer of holographic biometrics trackers and telemetry networks.',
      licenseNumber: 'MD-112233',
      specialty: 'General Diagnostics',
      rating: 4.8,
      consultFee: 400.0,
      hospitalId: 'h1',
      hospitalName: 'City Central General Hospital',
      patientsThisWeek: [6, 8, 7, 9, 8, 3, 0],
    ),
    UserAccount(
      id: '5', 
      name: 'Dr. Stephen Strange', 
      email: 'strange@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 876-5432',
      bio: 'Acclaimed neurosurgeon with expertise in cognitive mapping, nerve recovery, and complex brain surgeries.',
      licenseNumber: 'MD-445566',
      specialty: 'Neurology & Neuro-surgery',
      rating: 4.9,
      consultFee: 600.0,
      hospitalId: 'h3',
      hospitalName: 'Apex Multi-Specialty Care',
      patientsThisWeek: [4, 5, 5, 6, 4, 2, 0],
    ),
    UserAccount(
      id: '6', 
      name: 'Dr. Bruce Banner', 
      email: 'bruce@medicate.com', 
      password: 'password123', 
      role: UserRole.doctor,
      phone: '+1 (555) 345-6789',
      bio: 'Expert pediatrician and cellular biophysicist. Specializes in child genetics, growth telemetry, and hormone treatments.',
      licenseNumber: 'MD-778899',
      specialty: 'Pediatrics & Biochemistry',
      rating: 4.7,
      consultFee: 350.0,
      hospitalId: 'h4',
      hospitalName: 'Metro Children Clinic',
      patientsThisWeek: [5, 6, 4, 5, 5, 1, 0],
    ),
  ];

  final List<Hospital> _hospitals = [
    Hospital(id: 'h1', name: 'City Central General Hospital', lat: 12.9716, lng: 77.5946, contact: '+1 (555) 123-4567', vacancy: 12, totalBeds: 50),
    Hospital(id: 'h2', name: 'St. Jude Cardiac Institute', lat: 12.9800, lng: 77.6000, contact: '+1 (555) 987-6543', vacancy: 4, totalBeds: 30),
    Hospital(id: 'h3', name: 'Apex Multi-Specialty Care', lat: 12.9600, lng: 77.5800, contact: '+1 (555) 456-7890', vacancy: 0, totalBeds: 25),
    Hospital(id: 'h4', name: 'Metro Children Clinic', lat: 12.9900, lng: 77.6200, contact: '+1 (555) 321-7654', vacancy: 28, totalBeds: 60),
    Hospital(id: 'h5', name: 'Green Valley Trauma Center', lat: 12.9500, lng: 77.6100, contact: '+1 (555) 654-0987', vacancy: 15, totalBeds: 40),
  ];

  final List<Medicine> _medicines = [
    // Analgesics
    Medicine(id: 'm1', name: 'Paracetamol 500mg (Crocin)', category: 'Analgesics', price: 18.00, description: 'Quick relief for mild pain, headache, fever, and common cold symptoms.', stock: 120),
    Medicine(id: 'm2', name: 'Ibuprofen 400mg (Combiflam)', category: 'Analgesics', price: 25.00, description: 'Targets source-level inflammatory triggers to mitigate muscular aches and joint pains.', stock: 80),
    Medicine(id: 'm3', name: 'Aspirin 75mg (Loprin)', category: 'Analgesics', price: 15.00, description: 'Low-dose aspirin used as a blood thinner to prevent cardiovascular episodes.', stock: 150),
    
    // Antibiotics
    Medicine(id: 'm4', name: 'Amoxicillin 250mg (Novamox)', category: 'Antibiotics', price: 65.00, description: 'Broad-spectrum penicillin antibiotic used to treat bacterial infections.', stock: 45),
    Medicine(id: 'm5', name: 'Azithromycin 500mg (Azithral)', category: 'Antibiotics', price: 120.00, description: 'Macrolide antibiotic used for respiratory tract, throat, and skin infections.', stock: 60),
    
    // Antihistamines
    Medicine(id: 'm6', name: 'Cetirizine 10mg (Okacet)', category: 'Antihistamines', price: 35.00, description: 'Non-drowsy 24-hour allergy defense against dust, running nose, and sneezing.', stock: 95),
    Medicine(id: 'm7', name: 'Montelukast 10mg (Montair)', category: 'Antihistamines', price: 98.00, description: 'Used to prevent asthma attacks and relieve seasonal allergic rhinitis.', stock: 70),
    
    // Gastrointestinal
    Medicine(id: 'm8', name: 'Loperamide 2mg (Lopamide)', category: 'Antidiarrheals', price: 22.00, description: 'Assists in restoring physiological balance and slowing intestinal motility.', stock: 65),
    Medicine(id: 'm9', name: 'Pantoprazole 40mg (Pan-40)', category: 'Antacids', price: 115.00, description: 'Proton pump inhibitor that reduces excess stomach acid, treating GERD and acidity.', stock: 110),
    Medicine(id: 'm10', name: 'Digene Gel Tablets', category: 'Antacids', price: 30.00, description: 'Chewable antacid tablets for fast relief from gas, bloating, and heartburn.', stock: 200),
    
    // Antidiabetics
    Medicine(id: 'm11', name: 'Metformin 500mg (Glycomet)', category: 'Antidiabetics', price: 42.00, description: 'Improves insulin sensitivity and glycemic controls for Type-2 Diabetes management.', stock: 110),
    
    // Cardiovascular
    Medicine(id: 'm12', name: 'Amlodipine 5mg (Amlokind)', category: 'Cardiovascular', price: 28.00, description: 'Calcium channel blocker used to treat high blood pressure (hypertension).', stock: 90),
    Medicine(id: 'm13', name: 'Atorvastatin 10mg (Lipvas)', category: 'Cardiovascular', price: 75.00, description: 'Statins used to lower cholesterol and prevent risk of heart attacks.', stock: 85),
    
    // Vitamins & Supplements
    Medicine(id: 'm14', name: 'Vitamin C 500mg (Limcee)', category: 'Vitamins', price: 25.00, description: 'Chewable orange-flavored tablets containing Ascorbic Acid for immunity.', stock: 300),
    Medicine(id: 'm15', name: 'Calcium + Vit D3 (Shelcal)', category: 'Vitamins', price: 95.00, description: 'Supports bone health, joint density, and manages calcium deficiencies.', stock: 130),
    Medicine(id: 'm16', name: 'Salbutamol Inhaler (Asthalin)', category: 'Respiratory', price: 145.00, description: 'Bronchodilator inhaler providing fast relief from asthma spasms and coughing.', stock: 50),
  ];

  // ── Inventory ──────────────────────────────────
  final List<InventoryItem> _inventory = [
    InventoryItem(id: 'inv1', name: 'Paracetamol 500mg', category: 'Analgesics', stock: 45, threshold: 20, expiryDate: DateTime.now().add(const Duration(days: 180)), unit: 'tablets'),
    InventoryItem(id: 'inv2', name: 'Amoxicillin 250mg', category: 'Antibiotics', stock: 8, threshold: 15, expiryDate: DateTime.now().add(const Duration(days: 25)), unit: 'capsules'),
    InventoryItem(id: 'inv3', name: 'Cetirizine 10mg', category: 'Antihistamines', stock: 60, threshold: 20, expiryDate: DateTime.now().add(const Duration(days: 365)), unit: 'tablets'),
    InventoryItem(id: 'inv4', name: 'Amlodipine 5mg', category: 'Cardiovascular', stock: 5, threshold: 10, expiryDate: DateTime.now().add(const Duration(days: 90)), unit: 'tablets'),
    InventoryItem(id: 'inv5', name: 'Metformin 500mg', category: 'Antidiabetics', stock: 30, threshold: 15, expiryDate: DateTime.now().subtract(const Duration(days: 5)), unit: 'tablets'),
    InventoryItem(id: 'inv6', name: 'Vitamin C 500mg', category: 'Vitamins', stock: 120, threshold: 30, expiryDate: DateTime.now().add(const Duration(days: 730)), unit: 'tablets'),
  ];

  // ── Vital Readings ──────────────────────────────
  final List<VitalReading> _vitalReadings = [
    VitalReading(id: 'vr1', type: 'heart_rate', value: 72, unit: 'bpm', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    VitalReading(id: 'vr2', type: 'heart_rate', value: 78, unit: 'bpm', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    VitalReading(id: 'vr3', type: 'heart_rate', value: 68, unit: 'bpm', timestamp: DateTime.now().subtract(const Duration(days: 1))),
    VitalReading(id: 'vr4', type: 'bp_systolic', value: 120, unit: 'mmHg', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    VitalReading(id: 'vr5', type: 'bp_diastolic', value: 80, unit: 'mmHg', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    VitalReading(id: 'vr6', type: 'temperature', value: 98.6, unit: '°F', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    VitalReading(id: 'vr7', type: 'spo2', value: 98, unit: '%', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    VitalReading(id: 'vr8', type: 'weight', value: 70.5, unit: 'kg', timestamp: DateTime.now().subtract(const Duration(days: 2))),
  ];

  final List<Appointment> _appointments = [];
  final List<MedicineReminder> _reminders = [
    MedicineReminder(id: 'r1', medicineName: 'Paracetamol 500mg', dosage: '1 tablet', time: '08:00 AM'),
    MedicineReminder(id: 'r2', medicineName: 'Cetirizine 10mg', dosage: '1 tablet', time: '09:00 PM'),
  ];
  final List<SymptomLog> _symptoms = [
    SymptomLog(id: 's1', symptom: 'Headache', severity: 4.0, timestamp: DateTime.now().subtract(Duration(days: 2))),
    SymptomLog(id: 's2', symptom: 'Fatigue', severity: 6.0, timestamp: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<ChatMessage> _chatMessages = [
    ChatMessage(id: 'c1', text: 'Hello! I am Medicate AI. How can I help you track your symptoms or health today?', isUser: false, timestamp: DateTime.now()),
  ];

  final List<CartItem> _cart = [];
  final List<Prescription> _prescriptions = [
    Prescription(id: 'pr1', patientId: '1', doctorName: 'Dr. Sarah Connor', medicineName: 'Paracetamol 500mg', dosage: '1 tablet twice daily', date: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<AppNotification> _notifications = [
    AppNotification(id: 'n1', text: 'Dr. Sarah Connor approved your Cardiology Consultation.', timestamp: DateTime.now().subtract(Duration(hours: 2))),
    AppNotification(id: 'n2', text: 'Simulated Drone Delivery: Your Paracetamol has been dispatched!', timestamp: DateTime.now().subtract(Duration(hours: 5))),
    AppNotification(id: 'n3', text: 'Urgent: Keep tracking your ECG vitals regularly today.', timestamp: DateTime.now().subtract(Duration(days: 1))),
  ];

  final List<VaccineRecord> _vaccines = [
    VaccineRecord(id: 'v1', name: 'COVID-19 mRNA Vaccine (Pfizer)', status: 'Taken', date: DateTime.now().subtract(Duration(days: 180))),
    VaccineRecord(id: 'v2', name: 'Influenza Annual Shot', status: 'Taken', date: DateTime.now().subtract(Duration(days: 45))),
    VaccineRecord(id: 'v3', name: 'Hepatitis B Recombinant', status: 'Available'),
    VaccineRecord(id: 'v4', name: 'Tetanus-Diphtheria Booster', status: 'Available'),
  ];

  // Active Sessions
  UserAccount? _currentUser;
  String? _otpVerificationEmail;
  String? _generatedOtp;
  bool _isVerifyingOtp = false;

  // Active Call Status
  bool _isCallActive = false;
  String? _activeCallDoctor;
  String? _activeCallChannel;

  // E-Commerce Delivery Tracking Simulation
  double _deliveryProgress = 0.0;
  String _deliveryStatus = 'Idle';
  Timer? _deliveryTimer;

  // Live Vehicle Telemetry Simulation
  final List<LiveVehicle> _liveVehicles = [
    LiveVehicle(id: 'v1', type: 'Ambulance', status: 'Responding', lat: 12.9750, lng: 77.5900, targetHospital: 'City Central General Hospital'),
    LiveVehicle(id: 'v2', type: 'Med-Drone', status: 'Dispatched', lat: 12.9650, lng: 77.6050, targetHospital: 'St. Jude Cardiac Institute'),
    LiveVehicle(id: 'v3', type: 'Ambulance', status: 'Returning', lat: 12.9850, lng: 77.5850, targetHospital: 'Apex Multi-Specialty Care'),
  ];
  Timer? _realTimeSimulationTimer;

  // Bluetooth Sensor State
  BluetoothConnectionStatus _btStatus = BluetoothConnectionStatus.disconnected;
  BluetoothSensorDevice? _connectedDevice;
  List<BluetoothSensorDevice> _discoveredDevices = [];
  double _glucoseValue = 98.0; // mg/dL
  final List<double> _glucoseHistory = [95.0, 97.0, 96.0, 98.0, 100.0, 98.0, 97.0, 99.0, 98.0, 101.0, 99.0, 98.0];
  int _bpmValue = 76;
  Timer? _vitalsSimulationTimer;

  // Getters
  UserAccount? get currentUser => _currentUser;
  List<Hospital> get hospitals => _hospitals;
  List<UserAccount> get doctors => _users.where((u) => u.role == UserRole.doctor).toList();
  List<LiveVehicle> get liveVehicles => _liveVehicles;
  List<InventoryItem> get inventory => _inventory;
  List<VitalReading> get vitalReadings => _vitalReadings;
  List<Medicine> get medicines => _medicines;
  List<Appointment> get appointments => _appointments;
  List<MedicineReminder> get reminders => _reminders;
  List<SymptomLog> get symptoms => _symptoms;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<CartItem> get cart => _cart;
  List<Prescription> get prescriptions => _prescriptions;
  List<AppNotification> get notifications => _notifications;
  List<VaccineRecord> get vaccines => _vaccines;
  bool get isCallActive => _isCallActive;
  String? get activeCallDoctor => _activeCallDoctor;
  String? get activeCallChannel => _activeCallChannel;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get generatedOtp => _generatedOtp;
  double get deliveryProgress => _deliveryProgress;
  String get deliveryStatus => _deliveryStatus;

  List<UserAccount> getDoctorsForHospital(String hospitalId, String hospitalName) {
    // 1. Filter local accounts list for doctors who belong to this hospital
    final localDocs = _users.where((u) => u.role == UserRole.doctor && u.hospitalId == hospitalId).toList();
    if (localDocs.isNotEmpty) {
      return localDocs;
    }
    
    // 2. Fallback / dynamic generation for OSM or other hospitals:
    // Deterministically assign 1-2 doctors from our real doctor list based on the hospital name
    final allDoctors = _users.where((u) => u.role == UserRole.doctor).toList();
    if (allDoctors.isEmpty) return [];
    
    final int hash = hospitalName.hashCode.abs();
    final int count = (hash % 2) + 1; // 1 or 2 doctors
    final List<UserAccount> assigned = [];
    for (int i = 0; i < count; i++) {
      assigned.add(allDoctors[(hash + i) % allDoctors.length]);
    }
    return assigned;
  }

  // Bluetooth Getters
  BluetoothConnectionStatus get btStatus => _btStatus;
  BluetoothSensorDevice? get connectedDevice => _connectedDevice;
  List<BluetoothSensorDevice> get discoveredDevices => _discoveredDevices;
  double get glucoseValue => _glucoseValue;
  List<double> get glucoseHistory => _glucoseHistory;
  int get bpmValue => _bpmValue;

  // Calculated Getters
  double get cartTotal => _cart.fold(0.0, (total, item) => total + (item.medicine.price * item.quantity));

  // ==========================================
  // AUTHENTICATION LOGIC (with OTP and Checks)
  // ==========================================

  // Check if duplicate email exists
  bool checkEmailExists(String email) {
    return _users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
  }

  // Request Registration OTP
  void requestSignUpOtp(String email) {
    if (checkEmailExists(email)) {
      throw Exception('Already have an account with this email.');
    }
    _otpVerificationEmail = email.trim();
    // Simulate OTP Generator
    final random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();
    _isVerifyingOtp = true;
    notifyListeners();
  }

  // Verify OTP & Register Account
  bool verifyOtpAndRegister(String name, String email, String password, UserRole role, String enteredOtp) {
    if (enteredOtp == _generatedOtp && email.trim().toLowerCase() == _otpVerificationEmail?.toLowerCase()) {
      final newAcc = UserAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
      );
      _users.add(newAcc);
      _currentUser = newAcc;
      _isVerifyingOtp = false;
      _generatedOtp = null;
      _otpVerificationEmail = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Login
  bool login(String email, String password, UserRole role) {
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase() && 
               u.password == password && 
               u.role == role
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _cart.clear();
    _isCallActive = false;
    notifyListeners();
  }

  // ==========================================
  // HOSPITAL ADMIN EDITS
  // ==========================================

  void updateHospitalVacancy(String id, int newVacancy) {
    final idx = _hospitals.indexWhere((h) => h.id == id);
    if (idx != -1) {
      _hospitals[idx].vacancy = newVacancy.clamp(0, _hospitals[idx].totalBeds);
      notifyListeners();
    }
  }

  // ==========================================
  // MEDICAL SHOP OPERATIONS
  // ==========================================

  void addToCart(Medicine med) {
    final idx = _cart.indexWhere((item) => item.medicine.id == med.id);
    if (idx != -1) {
      if (_cart[idx].quantity < med.stock) {
        _cart[idx].quantity++;
      }
    } else {
      _cart.add(CartItem(medicine: med));
    }
    notifyListeners();
  }

  void removeFromCart(String medId) {
    _cart.removeWhere((item) => item.medicine.id == medId);
    notifyListeners();
  }

  void adjustCartQuantity(String medId, int change) {
    final idx = _cart.indexWhere((item) => item.medicine.id == medId);
    if (idx != -1) {
      final newQty = _cart[idx].quantity + change;
      if (newQty <= 0) {
        _cart.removeAt(idx);
      } else if (newQty <= _cart[idx].medicine.stock) {
        _cart[idx].quantity = newQty;
      }
    }
    notifyListeners();
  }

  void checkoutCart() {
    for (var item in _cart) {
      final medIdx = _medicines.indexWhere((m) => m.id == item.medicine.id);
      if (medIdx != -1) {
        _medicines[medIdx].stock = max(0, _medicines[medIdx].stock - item.quantity);
      }
    }
    _cart.clear();
    notifyListeners();
  }

  void restockMedicine(String medId, int amount) {
    final idx = _medicines.indexWhere((m) => m.id == medId);
    if (idx != -1) {
      _medicines[idx].stock += amount;
      notifyListeners();
    }
  }

  // ==========================================
  // APPOINTMENT CALENDAR
  // ==========================================

  void bookAppointment(String doctor, String department, DateTime dateTime) {
    if (_currentUser == null) return;
    _appointments.add(
      Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: _currentUser!.id,
        patientName: _currentUser!.name,
        doctorName: doctor,
        department: department,
        dateTime: dateTime,
      ),
    );
    notifyListeners();
  }

  void updateAppointmentStatus(String id, String status) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _appointments[idx].status = status;
      notifyListeners();
    }
  }

  // ==========================================
  // TRACKERS (MEDICINE & PATIENT)
  // ==========================================

  void addSymptom(String symptom, double severity) {
    _symptoms.add(
      SymptomLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symptom: symptom,
        severity: severity,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addMedicineReminder(String name, String dosage, String time) {
    _reminders.add(
      MedicineReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medicineName: name,
        dosage: dosage,
        time: time,
      ),
    );
    notifyListeners();
  }

  void toggleReminderTaken(String id) {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reminders[idx].isTaken = !_reminders[idx].isTaken;
      notifyListeners();
    }
  }

  void removeReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Today's schedule — non-taken reminders
  List<MedicineReminder> getTodaysSchedule() => _reminders;

  // Adherence rate — % taken this week
  double getAdherenceRate() {
    if (_reminders.isEmpty) return 1.0;
    final taken = _reminders.where((r) => r.isTaken).length;
    return taken / _reminders.length;
  }

  // ==========================================
  // INVENTORY MANAGEMENT
  // ==========================================

  void addInventoryItem(String name, String category, int stock, int threshold, DateTime expiry, String unit) {
    _inventory.add(InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      stock: stock,
      threshold: threshold,
      expiryDate: expiry,
      unit: unit,
    ));
    addNotification('Inventory: $name added to stock.');
    notifyListeners();
  }

  void updateInventoryStock(String id, int newStock) {
    final idx = _inventory.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _inventory[idx].stock = newStock;
      notifyListeners();
    }
  }

  void deleteInventoryItem(String id) {
    _inventory.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  List<InventoryItem> get lowStockItems => _inventory.where((i) => i.isLowStock).toList();
  List<InventoryItem> get expiredItems => _inventory.where((i) => i.isExpired).toList();
  List<InventoryItem> get expiringSoonItems => _inventory.where((i) => i.isExpiringSoon && !i.isExpired).toList();

  // ==========================================
  // VITAL READINGS
  // ==========================================

  void addVitalReading(String type, double value, String unit, {String? note}) {
    _vitalReadings.insert(0, VitalReading(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      note: note,
    ));
    notifyListeners();
  }

  List<VitalReading> getVitalReadings(String type) =>
      _vitalReadings.where((r) => r.type == type).toList();

  VitalReading? getLatestVital(String type) {
    final readings = getVitalReadings(type);
    return readings.isNotEmpty ? readings.first : null;
  }

  // ==========================================
  // FORGOT PASSWORD (Simulated)
  // ==========================================

  bool sendPasswordReset(String email) {
    final exists = _users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) {
      addNotification('Password reset link sent to $email. Check your inbox.');
    }
    return exists;
  }


  // ==========================================
  // BLUETOOTH VITALS CONTROLLER & SIMULATOR
  // ==========================================

  void startScanning() {
    _btStatus = BluetoothConnectionStatus.scanning;
    _discoveredDevices.clear();
    notifyListeners();

    // Simulate finding devices after a short delay
    Timer(Duration(seconds: 2), () {
      if (_btStatus == BluetoothConnectionStatus.scanning) {
        _discoveredDevices = [
          BluetoothSensorDevice(id: 'd1', name: 'MediWatch Active 4', type: BluetoothDeviceType.watch, batteryLevel: 92, signalStrength: -58),
          BluetoothSensorDevice(id: 'd2', name: 'Aura Smart Ring Gen 4', type: BluetoothDeviceType.ring, batteryLevel: 87, signalStrength: -65),
          BluetoothSensorDevice(id: 'd3', name: 'VitalsBand S5', type: BluetoothDeviceType.watch, batteryLevel: 76, signalStrength: -72),
          BluetoothSensorDevice(id: 'd4', name: 'Circular Ring Slim', type: BluetoothDeviceType.ring, batteryLevel: 94, signalStrength: -60),
        ];
        _btStatus = BluetoothConnectionStatus.disconnected;
        notifyListeners();
      }
    });
  }

  void connectDevice(BluetoothSensorDevice device) {
    _btStatus = BluetoothConnectionStatus.connecting;
    notifyListeners();

    Timer(Duration(milliseconds: 1500), () {
      _btStatus = BluetoothConnectionStatus.connected;
      _connectedDevice = device;
      addNotification("SUCCESS: Connected to ${device.name} via Bluetooth.");
      
      // Start vitals telemetry simulation
      _startVitalsSimulation();
      notifyListeners();
    });
  }

  void disconnectDevice() {
    if (_connectedDevice != null) {
      addNotification("INFO: Disconnected from ${_connectedDevice!.name}.");
    }
    _btStatus = BluetoothConnectionStatus.disconnected;
    _connectedDevice = null;
    _discoveredDevices.clear();
    _stopVitalsSimulation();
    notifyListeners();
  }

  void _startVitalsSimulation() {
    _vitalsSimulationTimer?.cancel();
    final random = Random();
    _vitalsSimulationTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_btStatus == BluetoothConnectionStatus.connected) {
        // Fluctuate glucose +/- 1.5, bounds [75, 145]
        final double glucoseChange = (random.nextDouble() * 3.0) - 1.5;
        _glucoseValue = (_glucoseValue + glucoseChange).clamp(75.0, 145.0);
        
        // Append to history, keeping last 15 readings
        _glucoseHistory.add(_glucoseValue);
        if (_glucoseHistory.length > 15) {
          _glucoseHistory.removeAt(0);
        }

        // Fluctuate BPM +/- 3, bounds [60, 110]
        final int bpmChange = random.nextInt(7) - 3;
        _bpmValue = (_bpmValue + bpmChange).clamp(60, 110);

        notifyListeners();
      }
    });
  }

  void _stopVitalsSimulation() {
    _vitalsSimulationTimer?.cancel();
    _vitalsSimulationTimer = null;
  }

  // ==========================================
  // AI MEDICAL CHATBOT
  // ==========================================

  void sendPatientMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(userMsg);
    notifyListeners();

    // Trigger Smart AI Response
    Timer(Duration(milliseconds: 1500), () {
      final aiResponse = _generateAIResponse(text);
      _chatMessages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    });
  }

  String _generateAIResponse(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return "Hello! I am your Medicate AI medical assistant. How can I help you with your symptoms, medication reminders, or search for clinics today?";
    } else if (lower.contains('headache') || lower.contains('migraine')) {
      return "Headaches can stem from stress, dehydration, lack of sleep, or eye strain. I recommend resting in a dark room and drinking plenty of water. If you log this in your Symptom Tracker, you can monitor its frequency. If it is severe, consider booking an appointment with a General Physician.";
    } else if (lower.contains('fever') || lower.contains('temperature')) {
      return "A fever is typically a sign that your body is fighting an infection. Rest, stay hydrated, and you may take Paracetamol if appropriate. Please monitor your temperature. If it exceeds 103°F (39.4°C) or lasts more than 3 days, you should consult a doctor.";
    } else if (lower.contains('appointment') || lower.contains('doctor')) {
      return "To book an appointment, please head to the 'Calendar' tab. There, you can filter by department, select your preferred doctor, and pick an available date and time.";
    } else if (lower.contains('hospital') || lower.contains('map') || lower.contains('beds')) {
      return "To find nearby medical facilities, navigate to our 'Hospitals' screen. It displays a real-time locator map along with emergency contacts and bed vacancy numbers.";
    } else if (lower.contains('shop') || lower.contains('medicine') || lower.contains('buy')) {
      return "You can buy over-the-counter medicines in our 'Medical Shop' tab. Add items to your cart and proceed to checkout, and the system will update the stock inventory automatically.";
    } else if (lower.contains('cough') || lower.contains('cold') || lower.contains('sore throat')) {
      return "Colds and sore throats are usually viral. Warm fluids, honey, and salt-water gargles can soothe irritation. If you experience shortness of breath, please consult a doctor immediately.";
    } else {
      return "I have noted that. To ensure your safety, please log any symptoms in the Symptom Tracker and consult with our registered doctors via the Video Consultation option for a proper diagnosis.";
    }
  }

  // ==========================================
  // VIDEO CONSULTATION CONTROLLER
  // ==========================================

  void startCall(String doctorName, String department) {
    _isCallActive = true;
    _activeCallDoctor = doctorName;
    _activeCallChannel = department;
    notifyListeners();
  }

  void endCall() {
    _isCallActive = false;
    _activeCallDoctor = null;
    _activeCallChannel = null;
    notifyListeners();
  }

  // ==========================================
  // PRESCRIPTION LINKING & DELIVERY SYSTEM
  // ==========================================

  void addPrescription(String patientId, String docName, String medicineName, String dosage) {
    _prescriptions.add(
      Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        doctorName: docName,
        medicineName: medicineName,
        dosage: dosage,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void startDeliverySimulation() {
    _deliveryTimer?.cancel();
    _deliveryProgress = 0.0;
    _deliveryStatus = 'Packaging';
    notifyListeners();

    _deliveryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _deliveryProgress += 0.05;
      if (_deliveryProgress >= 1.0) {
        _deliveryProgress = 1.0;
        _deliveryStatus = 'Delivered';
        timer.cancel();
      } else if (_deliveryProgress >= 0.8) {
        _deliveryStatus = 'Arriving';
      } else if (_deliveryProgress >= 0.4) {
        _deliveryStatus = 'Out for Delivery';
      } else if (_deliveryProgress >= 0.15) {
        _deliveryStatus = 'Dispatched';
      }
      notifyListeners();
    });
  }

  // ==========================================
  // NOTIFICATIONS, VACCINATION & PROFILE SETTINGS
  // ==========================================

  void addNotification(String text) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void dismissNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void bookVaccine(String name, DateTime date) {
    final idx = _vaccines.indexWhere((v) => v.name == name);
    if (idx != -1) {
      _vaccines[idx] = VaccineRecord(
        id: _vaccines[idx].id,
        name: name,
        status: 'Scheduled',
        date: date,
      );
      addNotification("Vaccination appointment for $name has been scheduled successfully.");
    } else {
      _vaccines.add(
        VaccineRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          status: 'Scheduled',
          date: date,
        ),
      );
      addNotification("Vaccination appointment for $name has been scheduled successfully.");
    }
    notifyListeners();
  }

  void updateUserProfile({required String name, required String email, required String phone, required String bio, String? password}) {
    if (_currentUser == null) return;
    
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      final updatedUser = UserAccount(
        id: _currentUser!.id,
        name: name,
        email: email,
        password: password != null && password.isNotEmpty ? password : _currentUser!.password,
        role: _currentUser!.role,
        phone: phone,
        bio: bio,
        licenseNumber: _currentUser!.licenseNumber,
        specialty: _currentUser!.specialty,
        rating: _currentUser!.rating,
        consultFee: _currentUser!.consultFee,
        patientsThisWeek: _currentUser!.patientsThisWeek,
      );
      _users[idx] = updatedUser;
      _currentUser = updatedUser;
      addNotification("Profile updated successfully.");
      notifyListeners();
    }
  }

  void startRealTimeSimulation() {
    _realTimeSimulationTimer?.cancel();
    final random = Random();
    _realTimeSimulationTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      // 1. Fluctuate hospital vacancies
      for (var hospital in _hospitals) {
        final change = random.nextInt(3) - 1; // -1, 0, 1
        if (change != 0) {
          final oldVacancy = hospital.vacancy;
          hospital.vacancy = (hospital.vacancy + change).clamp(0, hospital.totalBeds);
          if (oldVacancy != hospital.vacancy) {
            if (hospital.vacancy == 0) {
              addNotification("ALERT: ${hospital.name} is now at FULL bed capacity.");
            } else if (oldVacancy == 0 && hospital.vacancy > 0) {
              addNotification("UPDATE: Beds have freed up at ${hospital.name}.");
            }
          }
        }
      }

      // 2. Animate live vehicles towards their targets
      for (var vehicle in _liveVehicles) {
        final targetHosp = _hospitals.firstWhere((h) => h.name == vehicle.targetHospital, orElse: () => _hospitals[0]);
        final double speedFactor = 0.0004; // Adjust speed of coordinate simulation
        final double dLat = targetHosp.lat - vehicle.lat;
        final double dLng = targetHosp.lng - vehicle.lng;
        final double distance = sqrt(dLat * dLat + dLng * dLng);

        if (distance < 0.001) {
          // Reached! Reset coordinates randomly to drift again
          vehicle.lat = 12.95 + random.nextDouble() * 0.04;
          vehicle.lng = 77.57 + random.nextDouble() * 0.05;
        } else {
          vehicle.lat += (dLat / distance) * speedFactor;
          vehicle.lng += (dLng / distance) * speedFactor;
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _realTimeSimulationTimer?.cancel();
    _deliveryTimer?.cancel();
    _vitalsSimulationTimer?.cancel();
    super.dispose();
  }
}
