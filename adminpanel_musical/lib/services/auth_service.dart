import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // EMAILS ADMIN DE RESPALDO (hardcoded por si Firestore falla)
  static const List<String> _fallbackAdminEmails = [
    'hsoundpasto@gmail.com',
    'esneyderj.ibarra221@gmail.com',
    'esneydribarra1970@gmail.com',
    'sofia.burbanoba221@umariana.edu.co',
    'admin@hsound.com',
    'admin@musical.com',
  ];

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // VERIFICAR SI EL USUARIO ES ADMIN (checkea Firestore + fallback)
  static Future<bool> isUserAdmin(User? user) async {
    if (user == null) return false;

    // Primero checkear fallback hardcoded
    if (_fallbackAdminEmails.contains(user.email)) return true;

    // Luego checkear campo isAdmin en users/{uid}
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data()?['isAdmin'] == true) return true;
    } catch (_) {}

    return false;
  }

  static Future<void> validateAdminAccess(User? user) async {
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    if (!await isUserAdmin(user)) {
      throw Exception('Acceso denegado. Solo administradores autorizados.');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;

      if (!await isUserAdmin(user)) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Acceso denegado. Solo administradores autorizados.',
        };
      }

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
          'role': 'admin',
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

  // Crear nuevo administrador
  Future<Map<String, dynamic>> createAdmin(String email, String password, String name) async {
    try {
      // 1. Crear usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Guardar en Firestore users/{uid} con isAdmin: true
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'isAdmin': true,
        'isArtist': false,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Administrador creado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Error al crear admin'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<void> saveToken(String token) async {
    // No necesario con Firebase
  }
}
