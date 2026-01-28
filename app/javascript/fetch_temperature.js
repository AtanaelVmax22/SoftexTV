const puppeteer = require('puppeteer');

async function fetchTemperature() {
    const url = 'http://localhost:3000/widgets/clima';

    // Inicia o navegador
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    try {
        // Acessa a página
        await page.goto(url);

        // Aguarda o iframe carregar
        await page.waitForSelector('iframe'); // Aguarda o iframe estar presente

        // Obtém o iframe
        const iframeElement = await page.$('iframe');

        // Acessa o conteúdo do iframe
        const iframe = await iframeElement.contentFrame();

        // Agora, dentro do iframe, busca a temperatura
        const temperature = await iframe.$eval('.temp', el => el.textContent.trim());

        // Fecha o navegador
        await browser.close();

        console.log("", temperature); // Exibe no terminal
        return temperature;
    } catch (error) {
        console.error('Erro ao buscar a temperatura:', error);

        // Fecha o navegador em caso de erro
        await browser.close();

        return '--';
    }
}

// Chama a função para obter e exibir a temperatura
fetchTemperature();
