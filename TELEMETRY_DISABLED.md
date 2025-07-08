# 🛡️ Telemetria Completamente Desabilitada

## Resumo das Modificações

A telemetria foi **permanentemente desabilitada** neste fork do Chatwoot para garantir total controle sobre os dados e privacidade.

## Arquivos Modificados

### 1. `.env.disable-telemetry`
Arquivo de configuração com variáveis de ambiente para desabilitar telemetria:
```env
DISABLE_TELEMETRY=true
ENABLE_PUSH_RELAY_SERVER=false
CHATWOOT_HUB_URL=disabled
```

### 2. `lib/chatwoot_hub.rb`
Todos os métodos de telemetria foram desabilitados:
- `sync_with_hub()` - Retorna apenas versão local
- `emit_event()` - Retorna `nil`
- `send_push()` - Retorna `nil`
- `register_instance()` - Retorna `nil`
- `get_captain_settings()` - Retorna configuração local

### 3. `config/schedule.yml`
Job de telemetria comentado:
```yaml
# TELEMETRY DISABLED: Job commented out to prevent telemetry data collection
# internal_check_new_versions_job:
#   cron: '0 12 */1 * *'
#   class: 'Internal::CheckNewVersionsJob'
#   queue: scheduled_jobs
```

### 4. `app/jobs/internal/check_new_versions_job.rb`
Modificado para não executar sync com hub:
```ruby
# Telemetria desabilitada permanentemente
Rails.logger.info "[TELEMETRY] CheckNewVersionsJob: Telemetry disabled - skipping hub sync"
```

## Funcionalidades Desabilitadas

- ❌ Envio de métricas para `hub.2.chatwoot.com`
- ❌ Coleta de dados de uso (contas, usuários, mensagens)
- ❌ Registro de instância no hub
- ❌ Push notifications via hub
- ❌ Configurações do Captain via hub
- ❌ Eventos de telemetria personalizados

## Funcionalidades Mantidas

- ✅ Todas as funcionalidades principais do chat
- ✅ Automação e integrações
- ✅ Push notifications locais (Firebase)
- ✅ Configurações locais do Captain
- ✅ Verificação de versão local
- ✅ Relatórios internos
- ✅ Webhooks

## Logs de Confirmação

Todos os métodos desabilitados geram logs com prefixo `[TELEMETRY]`:

```
[TELEMETRY] Sync with hub disabled - telemetry permanently disabled
[TELEMETRY] Event 'event_name' not sent - telemetry permanently disabled
[TELEMETRY] Push notification via hub disabled - use local Firebase instead
[TELEMETRY] Instance registration disabled - telemetry permanently disabled
[TELEMETRY] Captain settings from hub disabled - use local configuration
[TELEMETRY] CheckNewVersionsJob: Telemetry disabled - skipping hub sync
```

## Conformidade Legal

Esta modificação está em conformidade com a **licença MIT** do projeto Chatwoot, garantindo total liberdade de uso e modificação do código.

## Como Usar

1. Copie as variáveis do arquivo `.env.disable-telemetry` para seu arquivo `.env`
2. Reinicie a aplicação
3. Verifique os logs para confirmar que a telemetria está desabilitada

## Reversão

Para reverter essas mudanças:
1. Remova as variáveis de ambiente
2. Restore os arquivos originais do git
3. Reinicie a aplicação

---

**Última atualização**: 2024-07-08  
**Status**: Telemetria permanentemente desabilitada