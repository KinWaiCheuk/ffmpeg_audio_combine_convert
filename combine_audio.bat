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
set LIST_FILE=%OUTPUT_FOLDER%\temp_list_%batch_num%.txt
set TIMESTAMP_FILE=%OUTPUT_FOLDER%\timestamps_batch_%batch_num%.txt

if exist "%LIST_FILE%" del "%LIST_FILE%"
if exist "%TIMESTAMP_FILE%" del "%TIMESTAMP_FILE%"

echo Batch %batch_num% - File to Timestamp Mapping > "%TIMESTAMP_FILE%"
echo ================================================ >> "%TIMESTAMP_FILE%"
echo. >> "%TIMESTAMP_FILE%"

echo.
echo Starting processing...
echo.

:: Loop through all MP3 files
for %%F in ("%INPUT_FOLDER%\*.mp3") do (
    echo file '%%F' >> "%LIST_FILE%"
    
    :: Calculate timestamp (assuming 5 seconds per file)
    set /a minutes=!total_seconds! / 60
    set /a seconds=!total_seconds! %% 60
    
    :: Format with leading zeros
    if !seconds! LSS 10 (set seconds=0!seconds!)
    if !minutes! LSS 10 (set minutes=0!minutes!)
    
    :: Write to timestamp file
    echo [!minutes!:!seconds!] %%~nxF >> "%TIMESTAMP_FILE%"
    
    set /a file_count+=1
    set /a total_seconds+=5
    
    :: When we reach BATCH_SIZE files, combine them
    if !file_count! == %BATCH_SIZE% (
        echo. >> "%TIMESTAMP_FILE%"
        echo Total duration: !minutes!:!seconds! >> "%TIMESTAMP_FILE%"
        
        echo Processing batch !batch_num! ^(!file_count! files^)...
        
        :: Combine files (mono)
        ffmpeg -y -f concat -safe 0 -i "%LIST_FILE%" -c copy "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3" -loglevel error
        
        :: Convert to stereo
        ffmpeg -y -i "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3" -ac 2 "%OUTPUT_FOLDER%\batch_!batch_num!_stereo.mp3" -loglevel error
        
        :: Delete mono version
        del "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3"
        
        echo Batch !batch_num! complete.
        echo.
        
        :: Reset for next batch
        set /a batch_num+=1
        set /a file_count=0
        set /a total_seconds=0
        set LIST_FILE=%OUTPUT_FOLDER%\temp_list_!batch_num!.txt
        set TIMESTAMP_FILE=%OUTPUT_FOLDER%\timestamps_batch_!batch_num!.txt
        
        echo Batch !batch_num! - File to Timestamp Mapping > "!TIMESTAMP_FILE!"
        echo ================================================ >> "!TIMESTAMP_FILE!"
        echo. >> "!TIMESTAMP_FILE!"
    )
)

:: Process remaining files (last incomplete batch)
if !file_count! GTR 0 (
    set /a minutes=!total_seconds! / 60
    set /a seconds=!total_seconds! %% 60
    if !seconds! LSS 10 (set seconds=0!seconds!)
    if !minutes! LSS 10 (set minutes=0!minutes!)
    
    echo. >> "%TIMESTAMP_FILE%"
    echo Total duration: !minutes!:!seconds! >> "%TIMESTAMP_FILE%"
    
    echo Processing final batch !batch_num! ^(!file_count! files^)...
    ffmpeg -y -f concat -safe 0 -i "%LIST_FILE%" -c copy "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3" -loglevel error
    ffmpeg -y -i "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3" -ac 2 "%OUTPUT_FOLDER%\batch_!batch_num!_stereo.mp3" -loglevel error
    del "%OUTPUT_FOLDER%\batch_!batch_num!_mono.mp3"
    echo Final batch complete.
)

echo.
echo ========================================
echo Done! Processed !batch_num! batches.
echo Output files are in: %OUTPUT_FOLDER%
echo ========================================
echo.
echo Check timestamps_batch_X.txt files for file-to-timestamp mapping.
pause
```

**Changes made:**

1. **Keeps temp_list files** - No longer deletes them so you have a record
2. **Creates timestamp mapping files** - Each batch gets a `timestamps_batch_X.txt` file showing:
   - Timestamp in [MM:SS] format
   - Original filename
   - Total duration at the end

**Example of timestamps_batch_1.txt:**
```
Batch 1 - File to Timestamp Mapping
================================================

[00:00] Voice_00001.mp3
[00:05] Voice_00002.mp3
[00:10] Voice_00003.mp3
...
[83:15] Voice_01000.mp3

Total duration: 83:15