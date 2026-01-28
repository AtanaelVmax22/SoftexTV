class PagesController < ApplicationController
    skip_before_action :check_license
  
    def licenca_invalida
      render layout: false # ou use um layout customizado se preferir
    end
  end
  