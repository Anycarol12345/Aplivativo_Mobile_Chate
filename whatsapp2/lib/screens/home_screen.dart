import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../widgets/conversation_item.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart'; // Importando tela de chat

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  final List<Conversation> conversations = [
    Conversation(
      id: '1',
      contactName: 'Maria Silva',
      lastMessage: 'Oi! Tudo bem? Vamos nos encontrar hoje?',
      time: '14:32',
      profileImageUrl: '',
      unreadCount: 3,
      isOnline: true,
    ),
    Conversation(
      id: '2',
      contactName: 'João Santos',
      lastMessage: 'Obrigado pela ajuda!',
      time: '13:15',
      profileImageUrl: '',
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '3',
      contactName: 'Ana Costa',
      lastMessage: 'Você viu o documento que enviei?',
      time: '11:48',
      profileImageUrl: '',
      unreadCount: 1,
      isOnline: true,
    ),
  ];

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sair: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color(0xFF26A69A),
        title: const Text(
          'ChatApp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Busca em desenvolvimento')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Configurações'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sair', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 72,
            color: Colors.grey[200],
          ),
          itemBuilder: (context, index) {
            return ConversationItem(
              conversation: conversations[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      conversation: conversations[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nova conversa em desenvolvimento')),
          );
        },
        backgroundColor: const Color(0xFF26A69A),
        elevation: 4,
        child: const Icon(
          Icons.message,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
