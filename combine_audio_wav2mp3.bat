@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Audio File Combiner (Mono to Stereo)
echo ========================================
echo.

:: Get input folder
set /p INPUT_FOLDER="Enter the path to your audio files folder: "

:: Remove quotes if user added them
set INPUT_FOLDER=%INPUT_FOLDER:"=%

:: Check if folder exists
if not exist "%INPUT_FOLDER%" (
    echo Error: Folder does not exist!
    pause
    exit /b
)

:: Get output folder
set /p OUTPUT_FOLDER="Enter the path for output files: "
set OUTPUT_FOLDER=%OUTPUT_FOLDER:"=%

:: Get batch size
set /p BATCH_SIZE="How many files per batch? (e.g., 1000): "

echo.
echo Configuration:
echo   Input folder: %INPUT_FOLDER%
echo   Output folder: %OUTPUT_FOLDER%
echo   Batch size: %BATCH_SIZE%
echo.
set /p CONFIRM="Is this correct? (Y/N): "

if /i not "%CONFIRM%"=="Y" (
    echo Cancelled.
    pause
    exit /b
)

:: Create output folder
if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

:: Counter for batch number
set /a batch_num=1
set /a file_count=0

:: Create temporary file list
set LIST_FILE=%OUTPUT_FOLDER%\temp_list_%batch_num%.txt

if exist "%LIST_FILE%" del "%LIST_FILE%"

echo.
echo Starting processing...
echo.

:: Loop through all MP3 files
for %%F in ("%INPUT_FOLDER%\*.wav") do (
    echo file '%%F' >> "!LIST_FILE!"
    set /a file_count+=1
    
    :: When we reach BATCH_SIZE files, combine them
    if !file_count! == %BATCH_SIZE% (
        echo Processing batch !batch_num! ^(!file_count! files^)...
        
        :: Combine files and convert mono to stereo (-ac)
        ffmpeg -y -fflags +genpts -f concat -safe 0 -i "!LIST_FILE!" ^
            -ac 2 -ar 44100 -b:a 192k ^
            "%OUTPUT_FOLDER%\batch_!batch_num!.mp3" -loglevel error
        
        echo Batch !batch_num! complete.
        echo.
        
        :: Reset for next batch
        set /a batch_num+=1
        set /a file_count=0
        set LIST_FILE=%OUTPUT_FOLDER%\temp_list_!batch_num!.txt
    )
)

:: Process remaining files (last incomplete batch)
if !file_count! GTR 0 (
    echo Processing final batch !batch_num! ^(!file_count! files^)...
    :: Combine files and convert mono to stereo (-ac)
    ffmpeg -y -fflags +genpts -f concat -safe 0 -i "!LIST_FILE!" ^
        -ac 2 -ar 44100 -b:a 192k ^
        "%OUTPUT_FOLDER%\batch_!batch_num!.mp3" -loglevel error
    echo Final batch complete.
)

echo.
echo ========================================
echo Done. Processed !batch_num! batches.
echo Output files are in: %OUTPUT_FOLDER%
echo ========================================
echo.
pause
