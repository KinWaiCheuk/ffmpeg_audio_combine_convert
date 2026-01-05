@echo off
setlocal

set "INPUT_DIR=Tools\UT3\Voice"
set "OUTPUT_DIR=Tools\UT3\Voice_mp3"

FOR %%b IN ("Tools\UT3\Voice\*.WAV") DO (
    set "INFILE=%%b"
    set "BASENAME=%%~nb"
    call :convert
)

goto :eof

:convert
REM Run ffmpeg to convert with resample and timestamp fix
ffmpeg -i "%INFILE%" -codec:a libmp3lame -qscale:a 2 "%OUTPUT_DIR%\%BASENAME%.mp3"
goto :eof