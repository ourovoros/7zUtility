@echo off
setlocal enabledelayedexpansion

:: Path to the 7-Zip executable
set "exe=C:\Program Files\7-Zip\7z.exe"

:: Temporary working directory
set "temp_dir=%~dp0$$temp$$"

:: Flag to check if temporary folder was created
set "temp_created=false"

:: Create the temporary directory if it doesn't exist
if not exist "%temp_dir%" (
    mkdir "%temp_dir%"
    set "temp_created=true"
)

:: Compress all matching files in the folder
for /R %%i in (*.*) do (
  :: Skip the $$temp$$ folder itself
  if /I not "%%~dpi"=="%temp_dir%\" (
    :: Process files
    if not "%%~xi"=="" (
      if /I "%%~xi"==".zip" call :compress_file "%%i"
      if /I "%%~xi"==".rar" call :compress_file "%%i"
      if /I "%%~xi"==".lzh" call :compress_file "%%i"
      if /I "%%~xi"==".cbz" call :compress_file "%%i"
    )
  )
)

:: Compress all subfolders, excluding $$temp$$ folder
for /D /R %%d in (*) do (
  if /I not "%%d"=="%temp_dir%" (
    call :compress_folder "%%d"
  )
)

:: Final cleanup - make sure to remove temp folder
echo Cleaning up temporary files...
:: Wait for a moment to ensure that 7z has finished processing
timeout /t 5 > nul

:: Perform the cleanup again after waiting
call :clean_up_temp
echo All processes are complete.
pause
exit /b

:: File compression process
:compress_file
set "src_file=%~1"
set "dest_file=%~dpn1.7z"

:: Debugging output for source and destination paths
echo Compressing file: "!src_file!" to "!dest_file!"

:: Extract the file to the temporary directory
"%exe%" x "!src_file!" -o"%temp_dir%" -y >nul
if errorlevel 1 (
  echo Failed to extract: "!src_file!"
  goto :clean_temp
)

:: Recompress into 7z format
"%exe%" a -t7z -mx=9 -m0=lzma2 "!dest_file!" "%temp_dir%\*" >nul
if errorlevel 1 (
  echo Failed to recompress: "!dest_file!"
  goto :clean_temp
)

:: Delete the original file (if not a .7z file)
if not "%~x1"==".7z" del /F /Q "!src_file!"

:: Clean up temporary directory
:clean_temp
:: Ensure the temporary directory is clean
echo Checking if temp directory exists: "%temp_dir%"
if exist "%temp_dir%" (
  echo Removing temp directory: "%temp_dir%"
  rmdir /S /Q "%temp_dir%"
)

:: If temp folder was not created, avoid re-creating it
if !temp_created! == true (
    echo Recreating the temp directory...
    mkdir "%temp_dir%"
)

exit /b

:: Folder compression process
:compress_folder
set "src_folder=%~1"
set "dest_file=%~dpn1.7z"

:: Debugging output for source and destination paths
echo Compressing folder: "!src_folder!" to "!dest_file!"

:: Check if the folder exists
if not exist "!src_folder!" (
  echo Folder does not exist: "!src_folder!"
  exit /b
)

"%exe%" a -t7z -mx=9 -m0=lzma2 "!dest_file!" "!src_folder!\*" >nul
if errorlevel 1 (
  echo Failed to compress folder: "!src_folder!"
)
exit /b

:: Cleanup process for temporary files
:clean_up_temp
:: Ensure the temporary directory is deleted if it exists
echo Trying to clean up the temporary directory...
set count=0
:delete_attempt
if exist "%temp_dir%" (
  echo Attempting to delete temp directory...
  rmdir /S /Q "%temp_dir%"
  set /a count+=1
  if %count% lss 5 (
    timeout /t 1 > nul
    goto delete_attempt
  )
  echo Could not delete the temp directory after 5 attempts.
)
exit /b
