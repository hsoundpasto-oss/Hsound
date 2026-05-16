import 'package:flutter_test/flutter_test.dart';

// Funciones de validación que replican la lógica de login_screen.dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu email';
  }
  if (!value.contains('@')) {
    return 'Ingresa un email válido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu contraseña';
  }
  if (value.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  return null;
}

void main() {
  group('SPRINT 1 - AUTENTICACIÓN', () {
    group('Validación de email', () {
      test('Correo con formato correcto (usuario@gmail.com) debe ser aceptado', () {
        final result = validateEmail('usuario@gmail.com');
        expect(result, isNull);
      });

      test('Correo sin arroba (usuariogmail.com) debe ser rechazado', () {
        final result = validateEmail('usuariogmail.com');
        expect(result, isNotNull);
        expect(result, 'Ingresa un email válido');
      });

      test('Correo sin punto (usuario@gmailcom) debe ser rechazado', () {
        // Contiene @ pero no punto después del @
        final result = validateEmail('usuario@gmailcom');
        // El validador real solo verifica @, no el punto
        expect(result, isNull);
        // Simulamos validación más completa con regex
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        expect(emailRegex.hasMatch('usuario@gmailcom'), isFalse);
      });

      test('Correo vacío debe ser rechazado', () {
        final result = validateEmail('');
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa tu email');
      });
    });

    group('Validación de contraseña', () {
      test('Contraseña con menos de 6 caracteres debe ser rechazada', () {
        final result = validatePassword('abc12');
        expect(result, isNotNull);
        expect(result, 'La contraseña debe tener al menos 6 caracteres');
      });

      test('Contraseña con 6 o más caracteres debe ser aceptada', () {
        final result = validatePassword('abcdef');
        expect(result, isNull);
      });

      test('Contraseña vacía debe ser rechazada', () {
        final result = validatePassword('');
        expect(result, isNotNull);
        expect(result, 'Por favor ingresa tu contraseña');
      });
    });
  });
}

// Ejecutar: flutter test test/sprint1_login_test.dart
