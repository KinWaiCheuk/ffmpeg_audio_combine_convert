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
set /a total_seconds=0

:: Create temporary file list
set LIST_FILE=!OUTPUT_FOLDER!\temp_list_!batch_num!.txt
set TIMESTAMP_FILE=!OUTPUT_FOLDER!\timestamps_batch_!batch_num!.txt

:: Initialize files - use > to overwrite/create new
type nul > "!LIST_FILE!"

echo Batch !batch_num! - File to Timestamp Mapping > "!TIMESTAMP_FILE!"
echo ================================================ >> "!TIMESTAMP_FILE!"
echo. >> "!TIMESTAMP_FILE!"

echo.
echo Starting processing...
echo.

:: Loop through all MP3 files
for %%F in ("!INPUT_FOLDER!\*.mp3") do (
    echo file '%%F' >> "!LIST_FILE!"
    
    :: Get actual duration using ffprobe
    for /f "delims=" %%D in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%%F"') do (
        set duration=%%D
    )
    
    :: Convert to integer seconds (round down)
    for /f "tokens=1 delims=." %%S in ("!duration!") do set file_seconds=%%S
    
    :: Calculate current timestamp before adding
    set /a minutes=!total_seconds! / 60
    set /a seconds=!total_seconds! %% 60
    
    :: Format with leading zeros
    if !seconds! LSS 10 (set seconds=0!seconds!)
    if !minutes! LSS 10 (set minutes=0!minutes!)
    
    :: Write to timestamp file with actual duration
    echo [!minutes!:!seconds!] %%~nxF ^(!file_seconds!s^) >> "!TIMESTAMP_FILE!"
    
    :: Add to total
    set /a total_seconds+=!file_seconds!
    set /a file_count+=1
    
    :: When we reach BATCH_SIZE files, combine them
    if !file_count! == %BATCH_SIZE% (
        set /a final_minutes=!total_seconds! / 60
        set /a final_seconds=!total_seconds! %% 60
        if !final_seconds! LSS 10 (set final_seconds=0!final_seconds!)
        if !final_minutes! LSS 10 (set final_minutes=0!final_minutes!)
        
        echo. >> "!TIMESTAMP_FILE!"
        echo Total duration: !final_minutes!:!final_seconds! >> "!TIMESTAMP_FILE!"
        
        echo Processing batch !batch_num! ^(!file_count! files^)...
        
        @REM :: Combine files (mono)
        @REM ffmpeg -y -f concat -safe 0 -i "!LIST_FILE!" -c copy "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3" -loglevel error
        
        @REM :: Convert to stereo
        @REM ffmpeg -y -i "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3" -ac 2 "!OUTPUT_FOLDER!\batch_!batch_num!_stereo.mp3" -loglevel error
        
        @REM :: Delete mono version
        @REM del "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3"
        
        echo Batch !batch_num! complete.
        echo.
        
        :: Reset for next batch
        set /a batch_num+=1
        set /a file_count=0
        set /a total_seconds=0
        set LIST_FILE=!OUTPUT_FOLDER!\temp_list_!batch_num!.txt
        set TIMESTAMP_FILE=!OUTPUT_FOLDER!\timestamps_batch_!batch_num!.txt
        
        :: Initialize new list file
        type nul > "!LIST_FILE!"
        
        echo Batch !batch_num! - File to Timestamp Mapping > "!TIMESTAMP_FILE!"
        echo ================================================ >> "!TIMESTAMP_FILE!"
        echo. >> "!TIMESTAMP_FILE!"
    )
)

:: Process remaining files (last incomplete batch)
if !file_count! GTR 0 (
    set /a final_minutes=!total_seconds! / 60
    set /a final_seconds=!total_seconds! %% 60
    if !final_seconds! LSS 10 (set final_seconds=0!final_seconds!)
    if !final_minutes! LSS 10 (set final_minutes=0!final_minutes!)
    
    echo. >> "!TIMESTAMP_FILE!"
    echo Total duration: !final_minutes!:!final_seconds! >> "!TIMESTAMP_FILE!"
    
    echo Processing final batch !batch_num! ^(!file_count! files^)...
    @REM ffmpeg -y -f concat -safe 0 -i "!LIST_FILE!" -c copy "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3" -loglevel error
    @REM ffmpeg -y -i "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3" -ac 2 "!OUTPUT_FOLDER!\batch_!batch_num!_stereo.mp3" -loglevel error
    @REM del "!OUTPUT_FOLDER!\batch_!batch_num!_mono.mp3"
    echo Final batch complete.
)

echo.
echo ========================================
echo Done! Processed !batch_num! batches.
echo Output files are in: !OUTPUT_FOLDER!
echo ========================================
echo.
echo Check timestamps_batch_X.txt files for file-to-timestamp mapping.
pause