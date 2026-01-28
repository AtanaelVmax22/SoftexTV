const puppeteer = require('puppeteer');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

let ffmpegProcess;
let browser;
let page;

// Caminho para o arquivo PID
const pidFile = path.join(__dirname, 'ffmpeg.pid');

const start = async () => {
    const filePath = path.join(__dirname, 'overlay.html');

    console.log('Iniciando o processo de captura...');

    try {
        browser = await puppeteer.launch({ headless: true });
        console.log('Navegador iniciado.');

        page = await browser.newPage();
        console.log('Página criada.');

        await page.setViewport({ width: 1000, height: 300 });
        console.log('Viewport configurado.');

        await page.goto(`http://127.0.0.1:3000/widgets`);
        console.log('Página carregada.');

        const ffmpegCommand = `ffmpeg -y -loglevel verbose -f image2pipe -r 30 -i pipe:0 -vf "format=yuv420p" -c:v libx264 -preset veryfast -tune zerolatency -f flv rtmp://localhost/hls/widgets`;
        console.log('Iniciando o processo FFmpeg...');
        ffmpegProcess = spawn(ffmpegCommand, { shell: true });

        // Salva o PID do FFmpeg em um arquivo
        fs.writeFileSync(pidFile, ffmpegProcess.pid.toString());
        console.log(`PID do FFmpeg salvo: ${ffmpegProcess.pid}`);

        ffmpegProcess.stdout.on('data', (data) => {
            console.log(`FFmpeg stdout: ${data}`);
        });

        ffmpegProcess.stderr.on('data', (data) => {
            console.error(`FFmpeg stderr: ${data}`);
        });

        ffmpegProcess.on('close', (code) => {
            console.log(`FFmpeg saiu com código ${code}`);
        });

        const sendFrames = async () => {
            try {
                while (true) {
                    const screenshot = await page.screenshot({ encoding: 'binary' });
                    ffmpegProcess.stdin.write(screenshot);
                }
            } catch (error) {
                console.error('Erro ao enviar quadros para FFmpeg:', error);
            } finally {
                ffmpegProcess.stdin.end();
            }
        };

        await sendFrames();
    } catch (error) {
        console.error('Erro ao iniciar o processo:', error);
    }
};

const stop = () => {
    try {
        if (fs.existsSync(pidFile)) {
            const pid = parseInt(fs.readFileSync(pidFile, 'utf-8'), 10);
            console.log(`Encerrando processo FFmpeg com PID: ${pid}`);
            process.kill(pid); // Encerra o processo pelo PID
            fs.unlinkSync(pidFile); // Remove o arquivo PID
            console.log('Processo FFmpeg encerrado e arquivo PID removido.');

            if (browser) {
                browser.close();
                console.log('Navegador fechado.');
            }
        } else {
            console.log('Nenhum processo FFmpeg ativo ou PID não encontrado.');
        }
    } catch (error) {
        console.error('Erro ao interromper o processo FFmpeg:', error);
    }
};

const main = () => {
    const action = process.argv[2];
    console.log('Comando recebido:', action);

    if (action === 'start') {
        start();
    } else if (action === 'stop') {
        stop();
    } else {
        console.log('Comando inválido. Use "start" ou "stop".');
    }
};

main();
