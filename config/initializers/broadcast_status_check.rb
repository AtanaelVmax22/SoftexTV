Rails.application.config.after_initialize do
    Rails.logger.info "Verificando broadcasts órfãos após inicialização..."
    BroadcastStatusChecker.verify_all
  end
  