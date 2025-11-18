-- Habilitar Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Usuários podem ver todos os perfis"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Usuários podem atualizar seu próprio perfil"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Perfis são criados automaticamente"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Políticas para conversations
CREATE POLICY "Usuários podem ver conversas das quais participam"
  ON conversations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = conversations.id
      AND user_id = auth.uid()
    )
    OR is_public = true
  );

CREATE POLICY "Usuários podem criar conversas"
  ON conversations FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Criadores podem atualizar conversas"
  ON conversations FOR UPDATE
  USING (auth.uid() = created_by);

-- Políticas para conversation_participants
CREATE POLICY "Usuários podem ver participantes de suas conversas"
  ON conversation_participants FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants cp
      WHERE cp.conversation_id = conversation_participants.conversation_id
      AND cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem adicionar participantes"
  ON conversation_participants FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = conversation_participants.conversation_id
      AND user_id = auth.uid()
    )
    OR user_id = auth.uid()
  );

CREATE POLICY "Usuários podem sair de conversas"
  ON conversation_participants FOR DELETE
  USING (user_id = auth.uid());

CREATE POLICY "Usuários podem atualizar seu status na conversa"
  ON conversation_participants FOR UPDATE
  USING (user_id = auth.uid());

-- Políticas para messages
CREATE POLICY "Usuários podem ver mensagens de suas conversas"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem enviar mensagens em suas conversas"
  ON messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM conversation_participants
      WHERE conversation_id = messages.conversation_id
      AND user_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem editar suas próprias mensagens"
  ON messages FOR UPDATE
  USING (
    auth.uid() = sender_id
    AND created_at > NOW() - INTERVAL '15 minutes'
  );

CREATE POLICY "Usuários podem deletar suas próprias mensagens"
  ON messages FOR DELETE
  USING (auth.uid() = sender_id);

-- Políticas para message_reactions
CREATE POLICY "Usuários podem ver reações de suas conversas"
  ON message_reactions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM messages m
      JOIN conversation_participants cp ON cp.conversation_id = m.conversation_id
      WHERE m.id = message_reactions.message_id
      AND cp.user_id = auth.uid()
    )
  );

CREATE POLICY "Usuários podem adicionar reações"
  ON message_reactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem remover suas reações"
  ON message_reactions FOR DELETE
  USING (auth.uid() = user_id);
