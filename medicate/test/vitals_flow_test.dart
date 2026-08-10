import 'package:flutter_test/flutter_test.dart';
import 'package:medicate/core/services/services.dart';

void main() {
  group('Bluetooth Vitals Integration Tests', () {
    test('Initial Bluetooth Connection Status is disconnected', () {
      final provider = MedicateProvider();
      expect(provider.btStatus, equals(BluetoothConnectionStatus.disconnected));
      expect(provider.connectedDevice, isNull);
    });

    test('startScanning changes state to scanning', () {
      final provider = MedicateProvider();
      provider.startScanning();
      expect(provider.btStatus, equals(BluetoothConnectionStatus.scanning));
    });

    test('connectDevice successfully pairs device and starts streaming', () async {
      final provider = MedicateProvider();
      final device = BluetoothSensorDevice(
        id: 'test_dev',
        name: 'Test Smart Ring',
        type: BluetoothDeviceType.ring,
      );

      // Connect device
      provider.connectDevice(device);
      expect(provider.btStatus, equals(BluetoothConnectionStatus.connecting));

      // Wait for 1.5s simulated connection delay
      await Future.delayed(const Duration(milliseconds: 1600));

      expect(provider.btStatus, equals(BluetoothConnectionStatus.connected));
      expect(provider.connectedDevice, isNotNull);
      expect(provider.connectedDevice!.name, equals('Test Smart Ring'));

      // Check notification is added
      expect(provider.notifications.first.text, contains('Connected to Test Smart Ring'));

      // Clean up/disconnect
      provider.disconnectDevice();
      expect(provider.btStatus, equals(BluetoothConnectionStatus.disconnected));
      expect(provider.connectedDevice, isNull);
    });
  });
}
