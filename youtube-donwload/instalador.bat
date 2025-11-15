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

REM Verifica se o ffmpeg está disponível no sistema; se não, tenta baixar e instalar localmente no venv
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo ffmpeg nao encontrado no sistema. Tentando baixar um build estatico e instalar localmente no venv...
    set "FF_DIR=%~dp0ffmpeg"
    if not exist "%FF_DIR%" mkdir "%FF_DIR%"
    set "FF_ZIP=%FF_DIR%\ffmpeg.zip"
    set "FOUND_FFMPEG="

    REM Lista de mirrors (tenta cada um em sequencia)
    set "URL1=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    set "URL2=https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-release-essentials.zip"

    echo Tentativa 1: %URL1%
    powershell -Command "try { Invoke-WebRequest -Uri '%URL1%' -OutFile '%FF_ZIP%'; exit 0 } catch { exit 1 }"
    if not errorlevel 1 (
        echo Download 1 concluido. Extraindo...
        powershell -Command "Expand-Archive -Path '%FF_ZIP%' -DestinationPath '%FF_DIR%' -Force"
        for /f "delims=" %%i in ('dir /b /s "%FF_DIR%\ffmpeg.exe" 2^>nul') do set "FOUND_FFMPEG=%%i"
    ) else (
        echo Falha no download 1, tentando mirror 2...
    )

    if not defined FOUND_FFMPEG (
        echo Tentativa 2: %URL2%
        powershell -Command "try { Invoke-WebRequest -Uri '%URL2%' -OutFile '%FF_ZIP%'; exit 0 } catch { exit 1 }"
        if not errorlevel 1 (
            echo Download 2 concluido. Extraindo...
            powershell -Command "Expand-Archive -Path '%FF_ZIP%' -DestinationPath '%FF_DIR%' -Force"
            for /f "delims=" %%i in ('dir /b /s "%FF_DIR%\ffmpeg.exe" 2^>nul') do set "FOUND_FFMPEG=%%i"
        ) else (
            echo Falha no download 2.
        )
    )

    if defined FOUND_FFMPEG (
        echo Copiando ffmpeg para venv\Scripts
        copy /Y "%FOUND_FFMPEG%" "%~dp0venv\Scripts\ffmpeg.exe" >nul 2>nul
        REM tenta localizar ffprobe e copiar tambem
        set "FOUND_FFPROBE="
        for /f "delims=" %%j in ('dir /b /s "%FF_DIR%\ffprobe.exe" 2^>nul') do set "FOUND_FFPROBE=%%j"
        if defined FOUND_FFPROBE copy /Y "%FOUND_FFPROBE%" "%~dp0venv\Scripts\ffprobe.exe" >nul 2>nul
        echo ffmpeg instalado localmente no venv\Scripts
        REM Atualiza PATH para garantir que o ffmpeg local seja encontrado na sessao
        set "PATH=%~dp0venv\Scripts;%PATH%"
    ) else (
        echo Nao foi possivel baixar/instalar ffmpeg automaticamente.
        echo Tente instalar ffmpeg manualmente ou verifique conexao/restricoes de rede.
        echo Mirrors tentados:
        echo  - %URL1%
        echo  - %URL2%
        pause
        exit /b
    )
)

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