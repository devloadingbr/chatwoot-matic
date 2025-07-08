# Chatwoot Development Guidelines

## Build / Test / Lint

- **Setup**: `bundle install && pnpm install`
- **Run Dev**: `pnpm dev` or `overmind start -f ./Procfile.dev`
- **Lint JS/Vue**: `pnpm eslint` / `pnpm eslint:fix`
- **Lint Ruby**: `bundle exec rubocop -a`
- **Test JS**: `pnpm test` or `pnpm test:watch`
- **Test Ruby**: `bundle exec rspec spec/path/to/file_spec.rb`
- **Single Test**: `bundle exec rspec spec/path/to/file_spec.rb:LINE_NUMBER`
- **Run Project**: `overmind start -f Procfile.dev`

## Code Style

- **Ruby**: Follow RuboCop rules (150 character max line length)
- **Vue/JS**: Use ESLint (Airbnb base + Vue 3 recommended)
- **Vue Components**: Use PascalCase
- **Events**: Use camelCase
- **I18n**: No bare strings in templates; use i18n
- **Error Handling**: Use custom exceptions (`lib/custom_exceptions/`)
- **Models**: Validate presence/uniqueness, add proper indexes
- **Type Safety**: Use PropTypes in Vue, strong params in Rails
- **Naming**: Use clear, descriptive names with consistent casing
- **Vue API**: Always use Composition API with `<script setup>` at the top

## Styling

- **Tailwind Only**:  
  - Do not write custom CSS  
  - Do not use scoped CSS  
  - Do not use inline styles  
  - Always use Tailwind utility classes  
- **Colors**: Refer to `tailwind.config.js` for color definitions

## General Guidelines

- MVP focus: Least code change, happy-path only
- No unnecessary defensive programming
- Break down complex tasks into small, testable units
- Iterate after confirmation
- Avoid writing specs unless explicitly asked
- Remove dead/unreachable/unused code
- Don’t write multiple versions or backups for the same logic — pick the best approach and implement it
- Don't reference Claude in commit messages

## Project-Specific

- **Translations**:
  - Only update `en.yml` and `en.json`
  - Other languages are handled by the community
  - Backend i18n → `en.yml`, Frontend i18n → `en.json`
- **Frontend**:
  - Use `components-next/` for message bubbles (the rest is being deprecated)

## Ruby Best Practices

- Use compact `module/class` definitions; avoid nested styles

## Project Architecture & Structure

### Backend (Ruby on Rails)
- **`app/models/`** - Data models (User, Account, Conversation, Message, etc.)
- **`app/controllers/`** - REST API controllers organized by version:
  - `api/v1/` - Main API
  - `api/v2/` - V2 API (reports)
  - `public/` - Public endpoints
- **`app/services/`** - Business logic (message processing, automation, etc.)
- **`app/jobs/`** - Async jobs (Sidekiq)
- **`app/listeners/`** - Event listeners for webhooks
- **`app/builders/`** - Complex object builders
- **`app/finders/`** - Complex queries
- **`app/policies/`** - Authorization (Pundit)

### Frontend (Vue.js)
- **`app/javascript/dashboard/`** - Main dashboard interface:
  - `components/` - Reusable Vue components
  - `components-next/` - New components (design system)
  - `api/` - API clients
  - `store/` - Vuex store
  - `routes/` - Routes
  - `i18n/` - Internationalization
- **`app/javascript/widget/`** - Embeddable chat widget
- **`app/javascript/portal/`** - Help center portal
- **`app/javascript/shared/`** - Shared components

### Configuration
- **`config/`** - Rails configurations
- **`lib/`** - Custom libraries
- **`db/`** - Migrations and schema

## Key Functionality Locations

### 📊 Telemetria
**Main Files:**
- **`lib/chatwoot_hub.rb`** - Main telemetry service sending metrics to Chatwoot Hub
- **`lib/chatwoot_exception_tracker.rb`** - Error and exception tracking
- **`lib/online_status_tracker.rb`** - User online presence control
- **`app/models/reporting_event.rb`** - Model for storing report events
- **`app/listeners/reporting_event_listener.rb`** - Listener for metric events
- **`app/controllers/api/v2/accounts/reports_controller.rb`** - Reports API
- **`config/newrelic.yml`** - New Relic APM configuration

### 🤖 Captain (AI Assistant)
**Backend:**
- **Models**: `enterprise/app/models/captain/` (assistant.rb, document.rb, assistant_response.rb)
- **Controllers**: `enterprise/app/controllers/api/v1/accounts/captain/` (assistants_controller.rb, documents_controller.rb, etc.)
- **Services**: `enterprise/app/services/captain/llm/` (assistant_chat_service.rb, embedding_service.rb)
- **Jobs**: `enterprise/app/jobs/captain/` (crawl_job.rb, response_builder_job.rb)
- **Core Library**: `enterprise/lib/captain/` (agent.rb, llm_service.rb, tool.rb)

**Frontend:**
- **Routes**: `app/javascript/dashboard/routes/dashboard/captain/captain.routes.js`
- **Composable**: `app/javascript/dashboard/composables/useCaptain.js`
- **Components**: `app/javascript/dashboard/components-next/captain/`
- **API Client**: `app/javascript/dashboard/api/captain/` (assistant.js, document.js, etc.)

### 👤 User Photos/Avatars
**Backend:**
- **Main Concern**: `app/models/concerns/avatarable.rb` - Core avatar logic
- **Models**: `app/models/user.rb` and `app/models/contact.rb` (include Avatarable)
- **Jobs**: 
  - `app/jobs/avatar/avatar_from_url_job.rb` - Download avatar via URL
  - `app/jobs/avatar/avatar_from_gravatar_job.rb` - Gravatar fetch
- **Controllers**: 
  - `app/controllers/api/v1/profiles_controller.rb` - User avatar management
  - `app/controllers/api/v1/accounts/contacts_controller.rb` - Contact avatar management

**Frontend:**
- **Main Components**:
  - `app/javascript/dashboard/components/widgets/Thumbnail.vue` - Most used avatar component
  - `app/javascript/dashboard/components-next/avatar/Avatar.vue` - Modern component
  - `app/javascript/dashboard/components/widgets/UserAvatarWithName.vue` - Avatar with name
- **Upload**: `app/javascript/dashboard/components/widgets/forms/AvatarUploader.vue`
- **Profile**: `app/javascript/dashboard/routes/dashboard/settings/profile/UserProfilePicture.vue`

**API Responses:**
- **`app/views/api/v1/models/_user.json.jbuilder`** - Includes `avatar_url`
- **`app/views/api/v1/models/_contact.json.jbuilder`** - Includes `thumbnail` (avatar_url)

## Core Logic Locations

1. **Message Processing**: `app/services/` (ex: `whatsapp/`, `telegram/`, `messages/`)
2. **Automation**: `app/services/automation_rules/`
3. **Integrations**: `app/services/` (ex: `instagram/`, `facebook/`, `linear/`)
4. **API Endpoints**: `app/controllers/api/v1/accounts/`
5. **Data Models**: `app/models/`
6. **Async Jobs**: `app/jobs/`
7. **User Interface**: `app/javascript/dashboard/`

The project follows Rails patterns with service architecture for business logic and a Vue.js SPA on the frontend. The avatar system supports direct upload, external URLs, automatic Gravatar, and fallback to initials when no image is available.

## 🛡️ Telemetria Desabilitada

A telemetria foi **permanentemente desabilitada** neste fork para garantir total controle sobre os dados:

### Modificações Realizadas:

1. **Arquivo de Configuração**: `.env.disable-telemetry` - Variáveis de ambiente para desabilitar telemetria
2. **Biblioteca Principal**: `lib/chatwoot_hub.rb` - Todos os métodos de telemetria retornam `nil` com logs informativos
3. **Agendamento**: `config/schedule.yml` - Job de telemetria comentado
4. **Job de Versão**: `app/jobs/internal/check_new_versions_job.rb` - Não executa sync com hub

### Funcionalidades Desabilitadas:
- ❌ Envio de métricas para `hub.2.chatwoot.com`
- ❌ Coleta de dados de uso e estatísticas
- ❌ Registro de instância no hub
- ❌ Push notifications via hub (use Firebase local)
- ❌ Configurações do Captain via hub

### Funcionalidades Mantidas:
- ✅ Todas as funcionalidades principais do chat
- ✅ Automação e integrações
- ✅ Push notifications locais (Firebase)
- ✅ Configurações locais do Captain
- ✅ Verificação de versão local

### Logs de Confirmação:
Todos os métodos desabilitados agora geram logs com prefixo `[TELEMETRY]` para confirmar que a telemetria está desativada.

### Conformidade Legal:
Esta modificação está em conformidade com a licença MIT do projeto, garantindo total liberdade de uso e modificação do código.

## 🖼️ Melhorias para Avatares do WhatsApp

Foi implementado suporte completo para avatares de clientes na integração com Evolution API e WhatsApp Cloud:

### Correções Implementadas:

1. **Processamento de Avatar no Webhook**: `app/services/whatsapp/incoming_message_base_service.rb` - Agora processa corretamente o avatar_url dos contatos
2. **Serviço de Normalização**: `app/services/whatsapp/evolution_api_service.rb` - Normaliza dados da Evolution API para compatibilidade
3. **Job de Download Melhorado**: `app/jobs/avatar/avatar_from_url_job.rb` - Download robusto com validação e tratamento de erros
4. **Atualização Inteligente**: `app/builders/contact_inbox_with_contact_builder.rb` - Atualiza avatares automaticamente

### Funcionalidades:
- ✅ **Avatares aparecem automaticamente** nas conversas
- ✅ **Compatibilidade** com Evolution API e WhatsApp Cloud
- ✅ **Atualização automática** quando o usuário muda a foto
- ✅ **Validação robusta** de URLs e tipos de arquivo
- ✅ **Logs detalhados** para debug e monitoramento
- ✅ **Performance otimizada** evitando downloads desnecessários

### Formatos Suportados:
- WhatsApp Cloud API oficial
- Evolution API
- 360Dialog
- Outras implementações que seguem o padrão

Ver `WHATSAPP_AVATAR_IMPROVEMENTS.md` para detalhes técnicos completos.