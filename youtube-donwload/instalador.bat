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

REM Gera o executável com PyInstaller (inclui youtube-logo.png como recurso)
REM Usa o python do venv e passa o caminho absoluto para garantir que o arquivo seja encontrado
if not exist "%~dp0youtube-logo.png" (
    echo Erro: arquivo "youtube-logo.png" nao encontrado em %~dp0
    echo Coloque o arquivo ao lado de instalador.bat e ytb-download.py e rode novamente.
    pause
    exit /b
)

"%~dp0venv\Scripts\python.exe" -m PyInstaller --onefile --windowed --add-data "%~dp0youtube-logo.png;." ytb-download.py

echo Pronto! O executável está na pasta dist\
pause