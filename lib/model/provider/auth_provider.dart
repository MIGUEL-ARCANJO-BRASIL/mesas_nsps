import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mesasnsps/model/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isOrganizador => _currentUser?.isOrganizador ?? false;
  String? get uid => _auth.currentUser?.uid;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  /// Método público para recarregar o usuário (usado na SplashScreen)
  Future<void> reloadUser(String uid) => _loadUserModel(uid);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _loadUserModel(credential.user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: 'user', // default: user, admin precisa mudar no Firestore
      );

      await _db.collection('users').doc(user.uid).set(user.toMap());
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  String _parseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Ocorreu um erro. Tente novamente.';
    }
  }
}
