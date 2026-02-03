module ApplicationHelper
  def show_back_button?
    # Retorna TRUE se NÃO estiver em uma dessas páginas
    excluded_pages = [
      ['broadcasts', 'index'],
      ['users', 'new'],
      ['users', 'edit'],
      ['sessions', 'new'],
      ['license', 'new'], # Adicionei essa por segurança
      ['license', 'create']
    ]
    
    !excluded_pages.include?([controller_name, action_name])
  end
end