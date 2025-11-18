-- Configurar bucket de storage para avatares
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Configurar bucket de storage para arquivos de mensagens
INSERT INTO storage.buckets (id, name, public)
VALUES ('message-files', 'message-files', false)
ON CONFLICT (id) DO NOTHING;

-- Políticas de storage para avatares
CREATE POLICY "Avatares são públicos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Usuários podem fazer upload de seus avatares"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Usuários podem atualizar seus avatares"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Usuários podem deletar seus avatares"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Políticas de storage para arquivos de mensagens
CREATE POLICY "Usuários podem ver arquivos de suas conversas"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'message-files'
    AND EXISTS (
      SELECT 1 FROM conversation_participants cp
      WHERE cp.user_id = auth.uid()
      AND cp.conversation_id::text = (storage.foldername(name))[1]
    )
  );

CREATE POLICY "Usuários podem fazer upload de arquivos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'message-files'
    AND EXISTS (
      SELECT 1 FROM conversation_participants cp
      WHERE cp.user_id = auth.uid()
      AND cp.conversation_id::text = (storage.foldername(name))[1]
    )
  );
