@echo off
setlocal enabledelayedexpansion

ffmpeg -f concat -safe 0 -i filelist1.txt -c copy output_part1.mp3