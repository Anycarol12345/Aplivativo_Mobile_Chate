-- Função para criar perfil automaticamente após registro
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para obter ou criar conversa individual
CREATE OR REPLACE FUNCTION get_or_create_direct_conversation(other_user_id UUID)
RETURNS UUID AS $$
DECLARE
  conversation_id UUID;
BEGIN
  -- Procurar conversa existente entre os dois usuários
  SELECT c.id INTO conversation_id
  FROM conversations c
  WHERE c.is_group = false
  AND EXISTS (
    SELECT 1 FROM conversation_participants cp1
    WHERE cp1.conversation_id = c.id AND cp1.user_id = auth.uid()
  )
  AND EXISTS (
    SELECT 1 FROM conversation_participants cp2
    WHERE cp2.conversation_id = c.id AND cp2.user_id = other_user_id
  )
  LIMIT 1;

  -- Se não existir, criar nova conversa
  IF conversation_id IS NULL THEN
    INSERT INTO conversations (is_group, created_by)
    VALUES (false, auth.uid())
    RETURNING id INTO conversation_id;

    -- Adicionar ambos os participantes
    INSERT INTO conversation_participants (conversation_id, user_id)
    VALUES (conversation_id, auth.uid()), (conversation_id, other_user_id);
  END IF;

  RETURN conversation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para atualizar last_seen do usuário
CREATE OR REPLACE FUNCTION update_user_last_seen()
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET last_seen = NOW(), is_online = true
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para limpar mensagens antigas (política de retenção de 12 meses)
CREATE OR REPLACE FUNCTION cleanup_old_messages()
RETURNS void AS $$
BEGIN
  DELETE FROM messages
  WHERE created_at < NOW() - INTERVAL '12 months';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
