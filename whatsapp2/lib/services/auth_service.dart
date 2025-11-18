import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool get isAuthenticated {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  String? get currentUserId {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;
    print('[v0] Auth check - Session: ${session != null}, User: ${user?.id}');
    return user?.id;
  }

  User? get currentUser {
    return _supabase.auth.currentSession?.user;
  }

  // Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Login com email e senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('[v0] Tentando fazer login com: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('[v0] Login bem-sucedido! User ID: ${response.user?.id}');
      
      if (response.user != null) {
        await _createProfileIfNotExists(response.user!);
        
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      return response;
    } catch (e) {
      print('[v0] Erro no login: $e');
      rethrow;
    }
  }

  // Cadastro com email e senha
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        await _createProfile(response.user!, name);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createProfile(User user, String name) async {
    try {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'name': name,
        'email': user.email,
        'avatar_url': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=26A69A&color=fff',
      });
    } catch (e) {
      // Ignorar erro se o perfil já existir
    }
  }

  Future<void> _createProfileIfNotExists(User user) async {
    try {
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        final name = user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'Usuário';
        await _createProfile(user, name);
      }
    } catch (e) {
      // Ignorar erro
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Recuperar senha
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
