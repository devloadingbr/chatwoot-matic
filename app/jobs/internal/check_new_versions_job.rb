class Internal::CheckNewVersionsJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    return unless Rails.env.production?

    # Telemetria desabilitada permanentemente
    Rails.logger.info "[TELEMETRY] CheckNewVersionsJob: Telemetry disabled - skipping hub sync"
    
    # Apenas define a versão local sem comunicação externa
    @instance_info = { 'version' => Chatwoot.config[:version] }
    update_version_info
  end

  private

  def update_version_info
    return if @instance_info['version'].blank?

    ::Redis::Alfred.set(::Redis::Alfred::LATEST_CHATWOOT_VERSION, @instance_info['version'])
  end
end

Internal::CheckNewVersionsJob.prepend_mod_with('Internal::CheckNewVersionsJob')
