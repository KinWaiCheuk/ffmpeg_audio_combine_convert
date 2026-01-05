@echo off
setlocal enabledelayedexpansion

REM === Change these values as needed ===
set "prefix=Voice_"
set "ext=mp3"

set "start1=1"
set "end1=1000"

REM === Combine files from 1 to 1000 ===
>filelist1.txt (
  for /l %%i in (%start1%,1,%end1%) do (
    set "num=00000%%i"
    set "num=!num:~-5!"
    echo file 'Tools\UT2\Voice_mp3\!prefix!!num!.%ext%'
  )
)