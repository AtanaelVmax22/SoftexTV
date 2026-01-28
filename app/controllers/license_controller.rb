class LicenseController < ApplicationController
    skip_before_action :check_license
  
    def new
    end
  
    def create
      token = params[:token]
  
      if LicenseValidator.valid_token?(token)
        File.write(Rails.root.join('.license_token'), token) # salva token localmente
        redirect_to root_path, notice: "Licença validada com sucesso!"
      else
        flash[:alert] = "Token inválido ou não autorizado."
        render :new, status: :unprocessable_entity
      end
    end
  end
  