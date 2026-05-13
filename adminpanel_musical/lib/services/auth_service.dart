import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // LISTA DE EMAILS ADMIN AUTORIZADOS
  static const List<String> adminEmails = [
    'esneyderj.ibarra221@gmail.com',
    'esneydribarra1970@gmail.com',
    'sofia.burbanoba221@umariana.edu.co',
    'admin@musical.com' // ← el de prueba que tienes
  ];

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar si está logueado
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // VERIFICAR SI EL USUARIO ES ADMIN (POR EMAIL)
  static bool isUserAdmin(User? user) {
    return user != null && adminEmails.contains(user.email);
  }

  // VALIDAR ACCESO ADMIN - LANZA EXCEPCIÓN SI NO ES ADMIN
  static void validateAdminAccess(User? user) {
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    
    if (!isUserAdmin(user)) {
      throw Exception('Acceso denegado. Solo administradores autorizados pueden acceder al panel.');
    }
  }

  // Login con email y contraseña
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Intentar iniciar sesión con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;

      // ✅ VALIDAR SI ES ADMIN POR EMAIL (EN LUGAR DE ROLE)
      if (!isUserAdmin(user)) {
        // Si no es admin, cerrar sesión
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Acceso denegado. Solo administradores autorizados.',
        };
      }

      // Obtener datos del usuario desde Firestore (si existen)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      return {
        'success': true,
        'message': 'Login exitoso',
        'user': {
          'id': user.uid,
          'name': userData?['name'] ?? user.email?.split('@')[0] ?? 'Administrador',
          'email': user.email,
          'role': 'admin', // Siempre será admin si pasa la validación
        },
      };

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No existe un usuario con este email';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'Email inválido';
          break;
        case 'user-disabled':
          message = 'Usuario deshabilitado';
          break;
        case 'invalid-credential':
          message = 'Credenciales inválidas';
          break;
        default:
          message = 'Error de autenticación: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  // Guardar token (Firebase lo maneja automáticamente)
  Future<void> saveToken(String token) async {
    // No necesario con Firebase
  }
}