class ApplicationController < ActionController::Base

  
  include Pundit
    before_action :set_locale
  
    before_action :authenticate_user!  # se estiver usando Devise
    before_action :check_license, unless: :skip_license_check?
  
    private
  


    def set_locale
      I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
      session[:locale] = I18n.locale
    end
  
    def change_locale
      session[:locale] = params[:locale] if params[:locale].present?
      redirect_to request.referer || root_path, locale: session[:locale]
    end
  
    def default_url_options
      { locale: I18n.locale }
    end

    private
    def check_license
      unless LicenseValidator.valid?
        redirect_to licenca_path
      end
    end

    def skip_license_check?
      controller_name.in?(%w[sessions passwords registrations license]) ||
        devise_controller?
    end
    # Define o idioma com base nos parâmetros ou na sessão
    def set_locale
      I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
      session[:locale] = I18n.locale # Salva o idioma na sessão
    end
end
