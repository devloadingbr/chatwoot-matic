class Avatar::AvatarFromUrlJob < ApplicationJob
  queue_as :low

  def perform(avatarable, avatar_url)
    return unless avatarable.respond_to?(:avatar)
    return if avatar_url.blank?

    # Limpar e validar URL
    cleaned_url = clean_avatar_url(avatar_url)
    return if cleaned_url.blank?

    avatar_file = Down.download(
      cleaned_url,
      max_size: 15 * 1024 * 1024,
      headers: download_headers
    )
    
    if valid_image?(avatar_file)
      avatarable.avatar.attach(
        io: avatar_file, 
        filename: avatar_file.original_filename || generate_filename(cleaned_url),
        content_type: avatar_file.content_type || 'image/jpeg'
      )
      Rails.logger.info "Avatar updated for #{avatarable.class.name} #{avatarable.id}"
    end
  rescue Down::NotFound => e
    Rails.logger.warn "Avatar not found for #{avatarable.class.name} #{avatarable.id}: #{avatar_url}"
  rescue Down::Error, StandardError => e
    Rails.logger.error "Exception downloading avatar for #{avatarable.class.name} #{avatarable.id} from #{avatar_url}: #{e.message}"
  end

  private

  def valid_image?(file)
    return false if file.blank?
    return false if file.size > 15 * 1024 * 1024 # 15MB limit

    # Verificar se é uma imagem válida por content-type
    content_type = file.content_type
    return false unless content_type&.start_with?('image/')

    # Verificar extensões válidas
    filename = file.original_filename || ''
    valid_extensions = %w[.jpg .jpeg .png .gif .webp .bmp]
    return true if valid_extensions.any? { |ext| filename.downcase.end_with?(ext) }

    # Se não tem extensão mas o content-type é válido, aceitar
    content_type.start_with?('image/')
  end

  def clean_avatar_url(url)
    return nil if url.blank?
    
    # Remover espaços e caracteres especiais
    cleaned = url.strip
    
    # Verificar se é uma URL válida
    return nil unless cleaned.match?(/\Ahttps?:\/\//)
    
    # Remover parâmetros de autenticação que podem expirar
    uri = URI.parse(cleaned)
    
    # Para URLs do WhatsApp, manter apenas parâmetros essenciais
    if uri.host&.include?('whatsapp')
      params = URI.decode_www_form(uri.query || '')
      # Manter apenas parâmetros essenciais (não tokens de autenticação)
      essential_params = params.reject { |key, _| key.match?(/token|auth|signature/i) }
      uri.query = essential_params.empty? ? nil : URI.encode_www_form(essential_params)
    end
    
    uri.to_s
  rescue URI::InvalidURIError => e
    Rails.logger.warn "Invalid avatar URL: #{url} - #{e.message}"
    nil
  end

  def download_headers
    {
      'User-Agent' => 'Chatwoot/1.0 (Avatar Downloader)',
      'Accept' => 'image/*,*/*;q=0.8'
    }
  end

  def generate_filename(url)
    uri = URI.parse(url)
    filename = File.basename(uri.path)
    
    # Se não tem extensão, adicionar .jpg como padrão
    filename += '.jpg' unless filename.include?('.')
    
    filename.presence || "avatar_#{Time.current.to_i}.jpg"
  rescue
    "avatar_#{Time.current.to_i}.jpg"
  end
end
