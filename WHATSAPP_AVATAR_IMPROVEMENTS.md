# 🖼️ Melhorias para Avatares do WhatsApp/Evolution API

## Problema Resolvido

A versão oficial do Chatwoot **não processava adequadamente os avatares** dos contatos vindos da Evolution API e outras implementações do WhatsApp. As fotos dos clientes não apareciam nas conversas.

## Correções Implementadas

### 1. **Processamento de Avatar no Webhook** (`app/services/whatsapp/incoming_message_base_service.rb`)

**Antes:**
```ruby
contact_attributes: { 
  name: contact_params.dig(:profile, :name), 
  phone_number: "+#{@processed_params[:messages].first[:from]}" 
}
```

**Depois:**
```ruby
# Normalizar dados de contato (útil para Evolution API)
normalized_contact = Whatsapp::EvolutionApiService.normalize_contact_data(contact_params)

# Adicionar avatar_url se disponível (Evolution API e WhatsApp Cloud enviam)
avatar_url = Whatsapp::EvolutionApiService.extract_avatar_url(normalized_contact)
if avatar_url.present?
  contact_attributes[:avatar_url] = avatar_url
  Rails.logger.info "WhatsApp avatar URL found for contact #{waid}: #{avatar_url}"
end
```

### 2. **Serviço de Normalização Evolution API** (`app/services/whatsapp/evolution_api_service.rb`)

Novo serviço que:
- Normaliza dados de contato da Evolution API
- Extrai avatar_url de diferentes campos possíveis
- Suporta múltiplos formatos de dados
- Valida URLs de avatar

**Campos suportados para avatar:**
- `profile.profile_pic_url` (WhatsApp Cloud)
- `profile.avatar_url` (Evolution API)
- `profile.profilePicUrl` (formato camelCase)
- `avatar_url` (nível raiz)
- `profilePicUrl` (nível raiz)
- `photo` (alternativo)

### 3. **Job de Download Melhorado** (`app/jobs/avatar/avatar_from_url_job.rb`)

**Melhorias:**
- ✅ Validação robusta de URLs
- ✅ Limpeza de parâmetros de autenticação
- ✅ Headers apropriados para download
- ✅ Validação de tipo de arquivo
- ✅ Geração de nome de arquivo quando ausente
- ✅ Logging detalhado para debug
- ✅ Tratamento de erros específicos

### 4. **Atualização Inteligente de Avatares** (`app/builders/contact_inbox_with_contact_builder.rb`)

**Melhorias:**
- ✅ Atualiza avatares automaticamente se não existirem
- ✅ Reatualiza avatares antigos (mais de 7 dias)
- ✅ Evita downloads desnecessários
- ✅ Suporte a avatares dinâmicos da Evolution API

## Compatibilidade

As melhorias são **retrocompatíveis** e funcionam com:

- ✅ **WhatsApp Cloud API** oficial
- ✅ **Evolution API** 
- ✅ **360Dialog**
- ✅ Outras implementações que seguem o padrão

## Logs de Debug

Para monitorar o processamento de avatares:

```bash
# Logs de avatar encontrado
tail -f log/development.log | grep "WhatsApp avatar URL found"

# Logs de download de avatar
tail -f log/development.log | grep "Avatar updated"

# Logs de erro
tail -f log/development.log | grep "Exception downloading avatar"
```

## Formatos de Dados Suportados

### Evolution API
```json
{
  "contacts": [{
    "wa_id": "5511999999999",
    "profile": {
      "name": "João Silva",
      "profile_pic_url": "https://example.com/avatar.jpg"
    }
  }]
}
```

### WhatsApp Cloud
```json
{
  "contacts": [{
    "wa_id": "5511999999999", 
    "profile": {
      "name": "João Silva",
      "profile_pic_url": "https://graph.facebook.com/avatar.jpg"
    }
  }]
}
```

### Formato Alternativo
```json
{
  "contacts": [{
    "wa_id": "5511999999999",
    "name": "João Silva",
    "avatar_url": "https://example.com/avatar.jpg"
  }]
}
```

## Resultado

- 🖼️ **Avatares aparecem automaticamente** nas conversas
- 🔄 **Atualização automática** quando o usuário muda a foto
- 🛠️ **Compatível** com Evolution API e WhatsApp Cloud
- 📝 **Logs detalhados** para debug e monitoramento
- ⚡ **Performance otimizada** evitando downloads desnecessários

---

**Testado com:** Evolution API v1.5+, WhatsApp Cloud API, 360Dialog
**Compatibilidade:** Mantém funcionamento com todas as implementações existentes