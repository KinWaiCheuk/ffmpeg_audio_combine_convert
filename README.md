# Usage

## Combining multiple short mp3 files into one larger mp3 file
Double click `combine_audio.bat` to run the script. Follow the on-screen prompts to specify the input folder containing the mp3 files, the output folder for the combined files, and the batch size (number of files to combine per output file). The script will process the files in batches and create combined mp3 files in the specified output folder.

## Combining multiple short wav files into one larger mp3 file with mono to stereo conversion
Double click `combine_audio_wav2mp3.bat` to run the script. Same as `combine_audio.bat`. It throws error related to timestamps:

> [mp3 @ 00000192b6184f00] Application provided invalid, non monotonically increasing dts to muxer in stream 0: 68750785 >= 68745562

but the output mp3 files are playable.

## Padding filename with leading zeros using PowerShell
Open PowerShell and run the following command, replacing "your_folder" with the path to your target folder:

```powershell
filename_padding.ps1 "your_folder"
```