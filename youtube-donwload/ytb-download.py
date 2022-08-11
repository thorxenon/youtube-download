from operator import index
from tkinter.filedialog import askopenfilename
from calendar import c
from tkinter import messagebox
from pytube import YouTube
import PySimpleGUI as psg
from PySimpleGUI import *
import moviepy.editor

psg.theme('DarkGray')
layout = [
    [psg.Image(source="C:/Users/pedro/Desktop/youtube-download/youtube-logo.png",key=1)],
    [psg.Text('Coloque o link do vídeo para Download.'),psg.Input(key="site")],
    [psg.Button('Baixar'), psg.Button('Converter')],
]
window = psg.Window('YoutubeDownloader', layout=layout, element_justification="c")

while True:

    eventos, valores = window.read()

    if eventos == psg.WINDOW_CLOSED:
        break
    if eventos == 'Baixar':
        if valores['site']:
            site = valores['site']
            yt = YouTube(site)
            yt.streams.get_highest_resolution().download()
            #videoName = [psg.Text(yt.video_id)]
            #channel = [psg.Text(yt.channel_url)]

            #layout.insert([videoName],[channel])
    if eventos == 'Converter':
        video = askopenfilename()
        video = moviepy.editor.VideoFileClip(video)
        som = video.audio
        som.write_audiofile("music.mp3")