from tkinter import Tk, Label, Button, Entry, filedialog, messagebox, Frame
from pytube import YouTube
from PIL import Image, ImageTk
import os
import sys
import subprocess
import imageio_ffmpeg
import yt_dlp
import traceback

# Função para baixar o vídeo do YouTube
def baixar_video():
    link = entrada_link.get()
    if not link:
        messagebox.showerror("Erro", "Por favor, insira o link do vídeo.")
        return

    try:
        ydl_opts = {
            'outtmpl': '%(title)s.%(ext)s',
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
        }
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([link])
        messagebox.showinfo("Sucesso", "Download concluído!")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao baixar o vídeo: {e}")
        print(traceback.format_exc())

# Função para converter vídeo em áudio
def converter_audio():
    video_path = filedialog.askopenfilename(filetypes=[("Arquivos de Vídeo", "*.mp4;*.mkv;*.avi")])
    if not video_path:
        return

    try:
        # Extrai o áudio usando pydub
        audio_path = video_path.rsplit('.', 1)[0] + ".mp3"
        ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()
        subprocess.run([
            ffmpeg_path,"-y","-i", video_path, "-vn", "-acodec","libmp3lame", audio_path
        ], check=True)
        messagebox.showinfo("Sucesso", f"Áudio salvo em: {audio_path}")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao converter vídeo: {e}")

# Configuração da interface gráfica com tkinter
janela = Tk()
janela.title("YouTube Downloader")

# Definitive resource loading: when bundled with PyInstaller (--onefile), extra files
# included with --add-data are available inside sys._MEIPASS. We MUST load the image
# from that location. If the file isn't present, fail loudly and tell the user to
# rebuild including the resource.
base_path = getattr(sys, '_MEIPASS', None) or os.path.dirname(os.path.abspath(__file__))
logo_path = os.path.join(base_path, 'youtube-logo.png')
if not os.path.isfile(logo_path):
    # Clear failure: do not fallback silently or show placeholder. Inform how to include the file.
    err_msg = (
        f"Recurso ausente: {logo_path}\n\n"
        "Para corrigir, coloque 'youtube-logo.png' ao lado de 'ytb-download.py' e reconstrua o execu-tavel com:\n"
        "pyinstaller --onefile --windowed --add-data \"youtube-logo.png;.\" ytb-download.py\n"
        "(ou, se usar pasta assets: --add-data \"assets;assets\")"
    )
    try:
        # Try to show a GUI message if possible
        messagebox.showerror("Recurso ausente", err_msg)
    except Exception:
        # Fallback to console
        print(err_msg)
    # Stop immediately so the issue isn't masked
    raise FileNotFoundError(err_msg)

pill_img = Image.open(logo_path).resize((250, 100), Image.LANCZOS)
tk_img = ImageTk.PhotoImage(pill_img)
Label(janela, image=tk_img).pack(pady=10)

# Elementos da interface
Label(janela, text="Coloque o link do vídeo para Download:").pack(pady=10)
entrada_link = Entry(janela, width=50)
entrada_link.pack(pady=5)

frame_botoes = Frame(janela)
frame_botoes.pack(pady=10)

btn_download = Button(frame_botoes, text="Baixar", command=baixar_video)
btn_download.pack(side="left", padx=5)
btn_convert = Button(frame_botoes, text="Converter Vídeo em Áudio", command=converter_audio)
btn_convert.pack(side="left", padx=5)

# Inicia o loop da interface
janela.mainloop()