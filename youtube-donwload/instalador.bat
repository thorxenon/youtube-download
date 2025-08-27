@echo off
REM Verifica se o Python está instalado
where python >nul 2>nul
if errorlevel 1 (
    echo Python não está instalado. Instale o Python antes de continuar.
    pause
    exit /b
)

REM Cria o ambiente virtual
python -m venv venv

REM Ativa o ambiente virtual
call venv\Scripts\activate

REM Atualiza pip e instala as dependências
python -m pip install --upgrade pip
python -m pip install yt-dlp imageio-ffmpeg pyinstaller

REM Executa o programa uma vez para baixar o ffmpeg e testar dependências
python ytb-download.py

REM Gera o executável com PyInstaller
pyinstaller --onefile --windowed ytb-download.py

echo Pronto! O executável está na pasta dist\
pause