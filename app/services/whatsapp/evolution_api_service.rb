class Whatsapp::EvolutionApiService
  # Serviço específico para processar dados da Evolution API
  # que podem ter formato ligeiramente diferente do WhatsApp Cloud oficial
  
  def self.normalize_contact_data(contact_data)
    return contact_data unless contact_data.present?
    
    # Normalizar dados de contato da Evolution API
    normalized = contact_data.deep_dup
    
    # Garantir que o profile está presente
    normalized[:profile] ||= {}
    
    # Evolution API pode enviar avatar em diferentes campos
    avatar_url = extract_avatar_url(contact_data)
    if avatar_url.present?
      normalized[:profile][:profile_pic_url] = avatar_url
    end
    
    # Garantir que o nome está presente
    normalized[:profile][:name] ||= contact_data[:name] || contact_data[:pushname]
    
    normalized
  end
  
  def self.extract_avatar_url(contact_data)
    profile = contact_data[:profile] || {}
    
    # Tentar diferentes campos onde o avatar pode estar
    avatar_url = profile[:profile_pic_url] ||
                 profile[:avatar_url] ||
                 profile[:profilePicUrl] ||
                 contact_data[:avatar_url] ||
                 contact_data[:profilePicUrl] ||
                 contact_data[:photo]
    
    # Limpar e validar URL
    return nil if avatar_url.blank?
    
    # Garantir que é uma URL válida
    avatar_url = avatar_url.strip
    return nil unless avatar_url.match?(/\Ahttps?:\/\//)
    
    # Log para debug
    Rails.logger.debug "Evolution API avatar URL extracted: #{avatar_url}"
    
    avatar_url
  end
  
  def self.process_message_data(message_data)
    return message_data unless message_data.present?
    
    # Normalizar dados de mensagem da Evolution API
    normalized = message_data.deep_dup
    
    # Evolution API pode enviar dados em formato diferente
    # Normalizar para o formato esperado pelo Chatwoot
    
    # Garantir que contacts está presente e normalizado
    if normalized[:contacts].present?
      normalized[:contacts] = normalized[:contacts].map do |contact|
        normalize_contact_data(contact)
      end
    end
    
    normalized
  end
end