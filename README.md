# ChatApp - Aplicativo de Mensagens em Tempo Real

Aplicativo mobile de chat desenvolvido em Flutter com backend Supabase, seguindo as especificações do projeto da disciplina de Programação para Dispositivos Móveis.

## Características

- Autenticação com email e senha
- Interface moderna inspirada no WhatsApp
- Chat em tempo real (em desenvolvimento)
- Conversas individuais e em grupo (em desenvolvimento)
- Envio de mensagens de texto e mídia (em desenvolvimento)

## Tecnologias

- **Flutter** - Framework para desenvolvimento mobile
- **Supabase** - Backend as a Service (Auth, Database, Realtime, Storage)
- **Dart** - Linguagem de programação

## Configuração do Projeto

### 1. Pré-requisitos

- Flutter SDK (>=3.0.0)
- Dart SDK
- Conta no Supabase (gratuita)

### 2. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e crie uma conta
2. Clique em "New Project"
3. Preencha os dados:
   - Nome do projeto: `chatapp` (ou nome de sua preferência)
   - Database Password: escolha uma senha forte
   - Region: escolha a região mais próxima
4. Aguarde a criação do projeto (pode levar alguns minutos)

### 3. Obter Credenciais do Supabase

1. No dashboard do seu projeto, vá em **Settings** > **API**
2. Copie as seguintes informações:
   - **Project URL** (algo como: `https://xxxxx.supabase.co`)
   - **anon/public key** (chave pública para uso no app)

### 4. Configurar o Aplicativo

1. Clone ou baixe este projeto
2. Abra o arquivo `lib/main.dart`
3. Substitua as credenciais do Supabase:

\`\`\`dart
await Supabase.initialize(
url: 'SUA_URL_DO_SUPABASE', // Cole a Project URL aqui
anonKey: 'SUA_CHAVE_ANONIMA', // Cole a anon key aqui
);
\`\`\`

### 5. Instalar Dependências

\`\`\`bash
flutter pub get
\`\`\`

### 6. Executar o Aplicativo

\`\`\`bash
flutter run
\`\`\`

## Estrutura do Projeto

\`\`\`
lib/
├── main.dart # Ponto de entrada e configuração do Supabase
├── models/
│ └── conversation_model.dart # Modelo de dados das conversas
├── screens/
│ ├── login_screen.dart # Tela de login
│ ├── register_screen.dart # Tela de cadastro
│ └── home_screen.dart # Tela principal com lista de conversas
├── services/
│ └── auth_service.dart # Serviço de autenticação
└── widgets/
└── conversation_item.dart # Widget de item de conversa
\`\`\`

## Funcionalidades Implementadas

- ✅ Tela de login com validação
- ✅ Tela de cadastro de usuários
- ✅ Autenticação com Supabase Auth
- ✅ Logout com confirmação
- ✅ Interface de lista de conversas
- ✅ Verificação automática de sessão

## Próximos Passos (Conforme Cronograma)

### Semanas 3-4: Conversas e Mensagens

- [ ] Criar tabelas no Supabase (users, conversations, messages)
- [ ] Implementar tela de chat individual
- [ ] Envio e recebimento de mensagens em tempo real
- [ ] Upload de imagens

### Semana 5: Funcionalidades Adicionais

- [ ] Busca de usuários
- [ ] Criação de grupos
- [ ] Reações a mensagens
- [ ] Indicador de "digitando..."
- [ ] Status online/offline

### Semana 6: Testes e Ajustes

- [ ] Testes de funcionalidades
- [ ] Correção de bugs
- [ ] Otimizações de performance
- [ ] Documentação final

## Configuração do Banco de Dados (Próxima Etapa)

As tabelas necessárias serão criadas no Supabase SQL Editor:

- `profiles` - Perfis dos usuários
- `conversations` - Conversas individuais e grupos
- `messages` - Mensagens enviadas
- `conversation_participants` - Participantes das conversas

## Segurança

O projeto utiliza Row Level Security (RLS) do Supabase para garantir que:

- Usuários só acessem suas próprias conversas
- Mensagens sejam visíveis apenas para participantes
- Dados sensíveis sejam protegidos

## Licença

Projeto acadêmico - Programação para Dispositivos Móveis
