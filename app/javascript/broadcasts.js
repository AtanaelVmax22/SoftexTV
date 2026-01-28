document.addEventListener("DOMContentLoaded", function() {
  const broadcastCard = document.querySelector(".broadcast-card-desktop");

  // Adiciona um parâmetro de data/hora para evitar cache no carregamento da imagem
  const timestamp = new Date().getTime();
  const newBackgroundUrl = `/wallpapers/wallpaper.jpeg?${timestamp}`; // Parâmetro único para forçar atualização
  broadcastCard.style.backgroundImage = `url(${newBackgroundUrl})`;

  const cardsDesk = document.querySelectorAll(".broadcast-card-desktop");
  const cards = document.querySelectorAll(".broadcast-card");
  const editMenu = document.getElementById("edit-menu");
  const editLink = document.getElementById("edit-link");
  const deleteLink = document.getElementById("delete-link");

  cards.forEach(card => {
    card.addEventListener("click", (event) => {
      // Remove a classe 'selected' de todos os cards
      cards.forEach(c => {
        c.classList.remove("selected");
        c.classList.add("mirror-effect"); // Adiciona efeito espelho
      });

      // Adiciona a classe 'selected' ao card clicado
      card.classList.add("selected");
      card.classList.remove("mirror-effect"); // Remove efeito espelho

      const broadcastId = card.getAttribute("data-broadcast-id");
      const broadcastName = card.querySelector(".card-title").innerText;

      // Atualiza as informações do menu de edição
      editMenu.classList.remove("hidden");
      editLink.href = `/broadcasts/${broadcastId}/edit`;
      deleteLink.href = `/broadcasts/${broadcastId}`; // Adiciona a URL de exclusão no link de delete

      // Calcula a posição do card
      const cardRect = card.getBoundingClientRect();
      editMenu.style.top = `${cardRect.top + window.scrollY}px`; // Alinhado à parte superior do card
      editMenu.style.left = `${cardRect.right + window.scrollX + 100}px`; // À direita do card com um pequeno espaçamento

      // Impede a propagação do evento de clique para o documento
      event.stopPropagation();
    });
  });

  // Fecha o menu de edição ao clicar fora
  document.addEventListener("click", (event) => {
    if (!editMenu.contains(event.target)) {
      editMenu.classList.add("hidden");
      // Remove a classe 'selected' de todos os cards
      cards.forEach(c => {
        c.classList.remove("selected");
        c.classList.add("mirror-effect"); // Adiciona efeito espelho
      });
    }
  });

  
});
