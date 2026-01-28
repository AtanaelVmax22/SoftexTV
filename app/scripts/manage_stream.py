import psutil
import subprocess
import sys

def stop_ffmpeg_processes():
    """Parar todos os processos ffmpeg em execução."""
    for proc in psutil.process_iter(attrs=['pid', 'name']):
        if 'ffmpeg' in proc.info['name']:
            print(f"Parando o processo: {proc.info['pid']} - {proc.info['name']}")
            try:
                proc.terminate()  # Tenta terminar o processo
                proc.wait()  # Aguarda o processo ser finalizado
            except psutil.NoSuchProcess:
                print(f"Erro ao parar o processo {proc.info['pid']}. O processo não existe.")
            except psutil.AccessDenied:
                print(f"Sem permissão para encerrar o processo {proc.info['pid']}.")

def start_ffmpeg_stream(video, stream_url):
    """Iniciar um processo de streaming com ffmpeg."""
    command = [
        "C:\\nginx\\ffmpeg\\bin\\ffmpeg.exe", 
        "-stream_loop", "-1", "-re", 
        "-i", f"C:\\SoftexTV\\softex_tv\\public\\videos\\{video}", 
        "-vf", "scale=768:1366,setdar=9/16,transpose=1,setsar=1",  # Removendo aspas extras
        "-c:v", "libx264", 
        "-preset", "fast", 
        "-c:a", "aac", 
        "-b:a", "192k", 
        "-f", "flv", 
        stream_url
    ]
    
    try:
        subprocess.Popen(command)  # Inicia o comando em um novo processo
        print(f"Streaming iniciado para o vídeo: {video} na URL: {stream_url}")
    except FileNotFoundError:
        print("Erro: ffmpeg não encontrado no caminho especificado.")
    except Exception as e:
        print(f"Erro ao iniciar o processo de streaming: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Erro: Faltando argumento. Use 'start' ou 'stop'.")
        sys.exit(1)

    action = sys.argv[1]  # 'start' ou 'stop'
    
    if action == 'stop':
        stop_ffmpeg_processes()
    elif action == 'start':
        if len(sys.argv) < 4:
            print("Erro: Faltando parâmetros para 'start'.")
            sys.exit(1)
        video = sys.argv[2]
        stream_url = sys.argv[3]
        start_ffmpeg_stream(video, stream_url)
    else:
        print("Ação inválida. Use 'start' ou 'stop'.")
        sys.exit(1)
