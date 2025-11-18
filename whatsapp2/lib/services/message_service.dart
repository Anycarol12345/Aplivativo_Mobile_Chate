import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;
  String? get _currentUserEmail => _supabase.auth.currentUser?.email;

  // Buscar mensagens de uma conversa
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      print('[v0] Buscando mensagens para conversa: $conversationId');
      
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId);

      print('[v0] Resposta do Supabase: $response');

      if (response == null) return [];

      final messages = (response as List)
          .where((json) => json['is_deleted'] != true)
          .map((json) => Message.fromJson(json))
          .toList();

      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      print('[v0] Total de mensagens carregadas: ${messages.length}');
      return messages;
    } catch (e) {
      print('[v0] ERRO ao buscar mensagens: $e');
      rethrow;
    }
  }

  // Enviar mensagem
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      print('[v0] === INICIANDO ENVIO DE MENSAGEM ===');
      print('[v0] User ID: $_currentUserId');
      print('[v0] Email: $_currentUserEmail');
      print('[v0] Conversa: $conversationId');
      print('[v0] Conteúdo: $content');
      
      final userId = _currentUserId;
      
      if (userId == null) {
        print('[v0] ERRO: Usuário não está autenticado!');
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      String senderName = 'Usuário';
      try {
        print('[v0] Buscando perfil do usuário...');
        final userProfile = await _supabase
            .from('profiles')
            .select('name')
            .eq('id', userId)
            .maybeSingle();

        print('[v0] Perfil encontrado: $userProfile');

        if (userProfile != null && userProfile['name'] != null) {
          senderName = userProfile['name'];
        } else {
          senderName = _currentUserEmail?.split('@')[0] ?? 'Usuário';
        }
      } catch (e) {
        print('[v0] Erro ao buscar perfil, usando email: $e');
        senderName = _currentUserEmail?.split('@')[0] ?? 'Usuário';
      }

      print('[v0] Nome do remetente: $senderName');

      final messageData = {
        'conversation_id': conversationId,
        'sender_id': userId,
        'content': content,
        'type': type.toString().split('.').last,
      };

      print('[v0] Dados da mensagem: $messageData');
      print('[v0] Inserindo mensagem no banco...');

      final response = await _supabase
          .from('messages')
          .insert(messageData)
          .select()
          .single();

      print('[v0] Mensagem inserida com sucesso: ${response['id']}');

      print('[v0] Atualizando última mensagem da conversa...');
      await _supabase
          .from('conversations')
          .update({
            'last_message': content,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);

      print('[v0] === MENSAGEM ENVIADA COM SUCESSO ===');
      return Message.fromJson(response);
    } catch (e) {
      print('[v0] === ERRO AO ENVIAR MENSAGEM ===');
      print('[v0] Erro: $e');
      print('[v0] Tipo do erro: ${e.runtimeType}');
      rethrow;
    }
  }

  // Stream de mensagens em tempo real
  Stream<List<Message>> messagesStream(String conversationId) {
    print('[v0] Iniciando stream de mensagens para: $conversationId');
    
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((data) {
          print('[v0] Stream recebeu ${data.length} mensagens');
          final messages = data
              .where((json) => json['is_deleted'] != true)
              .map((json) => Message.fromJson(json))
              .toList();
          
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          return messages;
        })
        .handleError((error) {
          print('[v0] Erro no stream: $error');
        });
  }

  // Deletar mensagem
  Future<void> deleteMessage(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_deleted': true})
        .eq('id', messageId);
  }

  // Editar mensagem
  Future<void> editMessage(String messageId, String newContent) async {
    await _supabase
        .from('messages')
        .update({
          'content': newContent,
          'edited_at': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId);
  }
}
