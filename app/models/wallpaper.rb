class Wallpaper < ApplicationRecord
    # Validar que a URL não pode ser vazia
    validates :url, presence: true
  end
  