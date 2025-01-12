@echo off
set exe="C:\Program Files\7-Zip\7z.exe"

for /R %%i in (*) do  (
rem  if /I "%%~xi"==".7z" call :再圧縮 "%%i"
  if /I "%%~xi"==".zip" call :再圧縮 "%%i"
  if /I "%%~xi"==".rar" call :再圧縮 "%%i"
  if /I "%%~xi"==".lzh" call :再圧縮 "%%i"
  if /I "%%~xi"==".cbz" call :再圧縮 "%%i"
)

cd "%~p0"
goto :EOF

:再圧縮
echo %1
cd %~p1
%exe% x -o$$temp$$ %1 >> NUL
cd $$temp$$
%exe% a -t7z -mx=9 -m0=lzma2 "%~p1%~n1.7z" * >> NUL
cd ..
rmdir /S /Q $$temp$$
if exist "%~p1%~n1.7z" if not "%~x1"==".7z" del /F /Q %1

goto :EOF